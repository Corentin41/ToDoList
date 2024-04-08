import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/todo_db.dart';
import '../model/todo.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {

  // Liste des tâches et la BDD
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();


  // Pour le BottomSheet
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Pour la saisie de la date
  final TextEditingController _dateController = TextEditingController();


  // Initialisation du titre et description
  String _todoName = '';
  String _todoDesc = '';
  // Par défaut, les tâches sont secondaires (priorité niv 2)
  int _todoPriority = 2;
  // Champs pour l'adresse
  String _adress = '';
  String _lat = '';
  String _lng = '';
  
  // Liste qui contient les titres pour trier la liste des tâches
  List<String> myPrefs = ['Priorité','Date de création','Date d\'échéance'];
  // Initialiser le choix du tri de la liste à niveau de Priorité
  String _sortPref = ''; // Pour l'affichage
  String _orderBy = ''; // Pour la BDD

  @override
  void initState() {
    super.initState();
    // Récupérer le tri de la liste (SharedPrefs)
    _getSortPref().then((result) {
      setState(() {
        // Si pas de prefs alors par défaut mettre à niveau de Priorité
        if (_sortPref.isEmpty) {
          _sortPref = 'Priorité';
        }
        // Récupérer toutes les tâches stockées en BDD lors de l'arrivée sur la page
        fetchTodos();
      });
    });
  }


  // Fonction qui permet de récupérer toutes les tâches stockées en BDD
  void fetchTodos() async {
    // Récupérer le choix du tri de la liste provenant des SharedPrefs
    await _getSortPref();
    setState(()  {
      // Adapter le nom du _sortPref pour pouvoir le passer dans la requête SQL
      if (_sortPref == 'Priorité') {
        _orderBy = 'priority';
      }
      else if (_sortPref == 'Date d\'échéance') {
        _orderBy = 'date';
      }
      else if (_sortPref == 'Date de création') {
        _orderBy = 'created_at';
      }
      // Afficher la liste triée en fonction du _sortPref
      futureTodos = todoDB.fetchAll(_orderBy);
    });
  }


  // Récupérer depuis les SharedPreferences le choix du tri de la liste
  Future<String> _getSortPref() async {
    final prefs = await SharedPreferences.getInstance();
    _sortPref = prefs.getString('sortPref') ?? "Priorité";
    return _sortPref;
  }


  // Stocker dans les SharedPreferences le choix du tri de la liste
  Future<void> _saveSortPref(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sortPref', value);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      body: Stack(
        children: [

          // Bouton pour trier la liste des tâches
          Container(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownMenu<String>(
                // Afficher le nom du tri par défaut
                hintText: _sortPref,
                onSelected: (String? value) {
                  setState(() {
                    // Sauvegarder le choix en SharedPrefs et rafraîchir la todoliste en conséquence
                    _saveSortPref(value.toString());
                    fetchTodos();
                  });
                },
                // Contient les différents choix pour trier la liste
                dropdownMenuEntries: myPrefs.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
            ),
          ),


          // Affichage de la liste des tâches
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: FutureBuilder<List<Todo>>(
              future: futureTodos,
              builder: (context, snapshot) {
                // Afficher un loader en attendant de charger toutes les tâches
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Récupérer toutes les données
                else {
                  // S'il n'y a aucune tâche enregistrée en BDD alors afficher un message
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune tâche', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
                  }
                  // Sinon récupérer les tâchs pour les afficher sous forme de liste
                  else {
                    final todos = snapshot.data!;
                    return ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        // Identifier chaque tâche avec son index
                        final todo = todos[index];

                        // Affichage de chaque tâche
                        return Container(
                          margin: const EdgeInsets.all(5),

                          // Couleur de fond des tâches
                          child: Card(
                            color: todo.priority == 1
                                ? todo.isDone == 0
                            // Tâche prioritaire en cours => orange
                                ? Colors.orange
                            // Tâche prioritaire terminée => grey
                                : Colors.grey
                                : todo.isDone == 0
                            // Tâche en cours => lime
                                ? Colors.lime
                            // Tâche terminée => grey
                                : Colors.grey,
                            // Si la tâche est terminée alors elle est grisée

                            child: ListTile(
                              // Au click sur la tâche on change son état (terminée = 1 / en cours = 0)
                              onTap: () {
                                setState(() {
                                  if (todo.isDone == 0) {
                                    todo.isDone = 1;
                                  } else {
                                    todo.isDone = 0;
                                  }
                                  // Appel à la méthode update de la BDD pour mettre à jour la tâche
                                  todoDB.update(id: todo.id, isDone: todo.isDone);
                                  // Rafraichîr l'affichage pour mettre les tâches terminées en bas
                                  fetchTodos();
                                });
                              },

                              // Icon indiquant si la tâche est terminée ou non
                              leading: Icon(
                                // Si la tâche est terminée (isDone à 1) alors afficher une check_box pleine
                                todo.isDone == 0 ? Icons.check_box_outline_blank : Icons.check_box,
                                color: Colors.blueAccent,
                              ),

                              // Affiche le titre de la tâche
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  // Si la tâche est terminée (isDone à 1) alors barrer le titre
                                  decoration: todo.isDone == 1 ? TextDecoration.lineThrough : null,
                                ),
                              ),

                              // Appeler la fonction checkDate pour afficher ou non la date en sous-titre
                              subtitle: checkDate(todo) == true
                                  ? Text(
                                todo.date!,
                                style: TextStyle(
                                  // Si la tâche est terminée (isDone à 1) alors barrer le titre
                                  decoration: todo.isDone == 1 ? TextDecoration.lineThrough : null,
                                ),
                              )
                                  : null,

                              // Affichage de la date : bouton modifier et bouton supprimer
                              trailing: Container(
                                height: 45,
                                width: 120,
                                child: Row(
                                  children: [

                                    // 1er enfant : modifier la tâche
                                    Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(5)),
                                      child: IconButton(
                                        color: Colors.white,
                                        iconSize: 16,
                                        icon: const Icon(Icons.edit),
                                        // Appel à la fonction updateTodo
                                        onPressed: () {
                                          showModalBottomSheet(
                                              context: context,
                                              // Pour quitter la modification d'une tâche il faut cliquer sur le bouton annuler
                                              isDismissible: false,
                                              builder: (BuildContext context) {
                                                return updateTodo(todo);
                                                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                                  return updateTodo(todo);
                                                });
                                              });
                                        },
                                      ),
                                    ),

                                    // 2e enfant : supprimer la tâche
                                    Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(5)),
                                      child: IconButton(
                                        color: Colors.white,
                                        iconSize: 16,
                                        icon: const Icon(Icons.delete),
                                        // Appel à la fonction deleteTodo
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return deleteTodo(todo);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
          )
        ],
      ),







      // Ajouter une nouvelle tâche
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            // Au click afficher le BottomSheet pour créer une tâche
            showModalBottomSheet(
              constraints: const BoxConstraints(maxWidth: double.maxFinite),
              context: context,
              // Pour quitter l'ajout d'une tâche il faut cliquer sur le bouton annuler
              isDismissible: false,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Champ pour entrer le nom de la tâche
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                              ),
                              validator: (titleValue) {
                                if (titleValue == null || titleValue.isEmpty) {
                                  return 'Titre requis';
                                }
                                return null;
                              },
                              // Sauvegarder le titre de la tâche
                              onSaved: (titleValue) {
                                _todoName = titleValue!;
                              },
                            ),
                          ),

                          // Champ pour entrer la description de la tâche
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextFormField(
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(labelText: 'Description de la tâche'),
                              // Sauvegarder la description de la tâche
                              onSaved: (titleValue) {
                                _todoDesc = titleValue!;
                              },
                            ),
                          ),

                          // Champ pour entrer la date
                          TextField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              labelText: 'Date d\'échéance',
                              filled: true,
                            ),
                            // Pour ajouter la date, on doit cliquer sur le champ qui va ouvir une dialog
                            readOnly: true,
                            onTap: () async {
                              final DateTime? dateTime = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              // S'il y a une date sélectionnée alors on pourra l'enregistrer en BDD
                              if (dateTime != null) {
                                setState(() {
                                  _dateController.text = dateTime.toString().split(" ")[0];
                                });
                              }
                            },
                            // Sauvegarder la date de la tâche
                            onChanged: (dateValue) {
                              _dateController.text = dateValue;
                            },
                          ),


                          // Champ pour l'adresse
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Adresse'),
                              onChanged: (adress){
                                _adress = adress;
                              },
                            ),
                          ),


                          // Définir le niveau de priorité de la tâche
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                const Text(
                                    "Définir en tant que tâche prioritaire : ",
                                    style: TextStyle(fontWeight: FontWeight.bold)),

                                IconButton(
                                  // Si la tâche est prioritaire (priority à 1) alors afficher une étoile pleine
                                  icon: Icon(_todoPriority == 1 ? Icons.star : Icons.star_border,
                                      color: Colors.blueAccent
                                  ),
                                  // Au click, changer le niveau de priorité (1 pour prioritaire et 2 pour secondaire)
                                  onPressed: () {
                                    setState(() {
                                      if (_todoPriority == 2) {
                                        _todoPriority = 1;
                                      } else {
                                        _todoPriority = 2;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),


                          // Boutons pour ajouter une tâche ou annuler l'ajout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              // Bouton pour ajouter la tâche
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () async {

                                      // Pour l'adresse
                                      if(_adress.isNotEmpty) {
                                        List<Location> locations = await locationFromAddress(_adress);
                                        _lat = locations.last.latitude.toString();
                                        _lng = locations.last.longitude.toString();
                                        print(_lat);
                                      }

                                      // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        // Si oui, alors ajout de la tâche dans la BDD
                                        setState(() {
                                          // Appel à la méthode create de la BDD pour enregistrer la tâche
                                          todoDB.create(
                                              title: _todoName,
                                              description: _todoDesc,
                                              priority: _todoPriority,
                                              date: _dateController.text.toString(),
                                              lat: _lat,
                                              lng: _lng
                                          );

                                          // Remettre à vide les champs
                                          _dateController.text = '';
                                          _todoPriority = 2;
                                          _lat = '';
                                          _lng = '';
                                          // Rafraîchir l'affichage des tâches et fermer le showModalBottomSheet
                                          fetchTodos();
                                          Navigator.pop(context);
                                        });
                                      }
                                    },
                                    child: const Text('ajouter', style: TextStyle(color: Colors.white),)),
                              ),

                              // Bouton pour fermer le showModalBottomSheet
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    // Remettre à vide les champs
                                    _dateController.text = '';
                                    _todoPriority = 2;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('annuler', style: TextStyle(color: Colors.white),),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
                );
              },
            );
          }
      ),
    );
  }

  // Fonction pour créer l'AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.green,
      title: const Text('Mes tâches', style: TextStyle(color: Colors.black)),
    );
  }
  

  // Fonction pour vérifier si l'utilisateur a entré une date ou non
  bool checkDate(Todo todo) {
    if (todo.date != null && todo.date!.isNotEmpty) {
      return true;
    }
    return false;
  }


  TileLayer get openStreetMapTilelayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  );









  // Fonction pour modifier une tâche
  StatefulBuilder updateTodo(Todo todo) {
    // Initialiser la valeur de priorité en fonction de la priorité stockée en BDD
    _todoPriority = todo.priority;
    // Retourner un StatefulBuilder pour mettre à jour l'icône seulement dans le Form et pas dans toute la page
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ pour modifier le titre de la tâche
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Titre de la tâche",
                  ),
                  // Afficher un message d'erreur si le champ du titre est vide
                  validator: (titleValue) {
                    if (titleValue == null || titleValue.isEmpty) {
                      return "Titre requis";
                    }
                    return null;
                  },
                  // Afficher le titre précédemment entré par l'utilisateur
                  initialValue: todo.title,
                  onSaved: (titleValue) {
                    _todoName = titleValue!;
                  },
                ),
              ),

              // Champ pour modifier la description de la tâche
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextFormField(
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description de la tâche'),
                  // Afficher la description précédemment entrée par l'utilisateur
                  initialValue: todo.description,
                  onSaved: (titleValue) {
                    _todoDesc = titleValue!;
                  },
                ),
              ),

              // Champ pour modifier la date
              TextField(
                controller: _dateController,
                // Afficher la date dans le champ s'il y avait déjà une date, sinon afficher un label
                decoration: checkDate(todo) == true
                    ? InputDecoration(hintText: todo.date.toString(), filled: true,)
                    : const InputDecoration(labelText: 'Date d\'échéance', filled: true),
                // Pour modifier la date, on doit cliquer sur le champ qui va ouvir une dialog
                readOnly: true,
                onTap: () async {
                  final DateTime? dateTime = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100));
                  if (dateTime != null) {
                    setState(() {
                      _dateController.text = dateTime.toString().split(" ")[0];
                    });
                  }
                },
              ),

              // Adresse
              todo.lat!.isNotEmpty ? Container(
                padding: const EdgeInsets.all(10),
                height: 240,
                child: FlutterMap(
                  options: MapOptions(
                      initialCenter: LatLng(todo.getDoubleLat(),todo.getDoubleLng()),
                      initialZoom: 11),
                  children: [
                    openStreetMapTilelayer
                  ],
                ),
              ) : Container(
                  padding: const EdgeInsets.all(10),
                  height: 240,
                  child: Text("pas d'adresse renseignée")
              ),



              // Champ pour modifier le niveau de priorité de la tâche
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const Text(
                        "Changer le niveau de priorité de la tâche : ",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    IconButton(
                      // Si la tâche est prioritaire (priority à 1) alors afficher une étoile pleine
                      icon: Icon(_todoPriority == 1 ? Icons.star : Icons.star_border,
                          color: Colors.blueAccent
                      ),
                      // Au click, changer le niveau de priorité (1 pour prioritaire et 2 pour secondaire)
                      onPressed: () {
                        setState(() {
                          if (_todoPriority == 2) {
                            _todoPriority = 1;
                          } else {
                            _todoPriority = 2;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Les boutons pour valider ou annuler la modification
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Bouton pour confirmer la modification de la tâche
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // Si oui, alors mettre à jour la tâche dans la BDD
                            setState(() {
                              // Si la date n'a pas été modifiée alors prendre la date déjà enregistrée en BDD
                              if (_dateController.text.isEmpty) {
                                _dateController.text = todo.date.toString();
                              }
                              // Appel à la méthode update de la BDD pour mettre à jour la tâche
                              todoDB.update(id: todo.id, title: _todoName, description: _todoDesc, priority: _todoPriority, date: _dateController.text.toString());
                              // Remettre à vide les champs
                              _dateController.text = '';
                              _todoPriority = 2;
                              _lat = '';
                              _lng = '';
                              // Rafraîchir l'affichage des tâches
                              fetchTodos();
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: const Text('modifier', style: TextStyle(color: Colors.white),)),
                  ),

                  // Bouton pour fermer le showModalBottomSheet et annuler la modification
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        // Remettre à vide les champs
                        _dateController.text = '';
                        _todoPriority = 2;
                        _lat = '';
                        _lng = '';
                        Navigator.pop(context);
                      },
                      child: const Text('annuler', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );
    });
  }






  // Fonction pour supprimer une tâche
  deleteTodo(Todo todo) {
    return AlertDialog(

      title: const Center(child: Text('Supprimer la tâche')),

      actionsAlignment: MainAxisAlignment.center,
      actions: [
        // Confirmer la supression de la tâche
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            setState(() {
              // Appel à la méthode delete de la BDD pour supprimer la tâche
              todoDB.delete(todo.id);
              // Rafraîchir l'affichage des tâches
              fetchTodos();
              Navigator.pop(context);
            });
          },
          child: const Text('Confirmer', style: TextStyle(color: Colors.white),),
        ),

        // Annuler et fermer la popup
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            // Logique à exécuter lorsque l'utilisateur appuie sur le bouton
            Navigator.of(context).pop();
          },
          child: const Text('Annuler',
            style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }

}