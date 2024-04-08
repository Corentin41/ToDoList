import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import '../database/todo_db.dart';
import '../model/todo.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  // Liste de tâches et la BDD
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();

  // Pour le BottomSheet
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  // Pour reset le nom de la tâche et la date dans le formulaire de création de tâche
  String _todoName = '';
  String _date = '';
  String _adress = '';
  String _lat = '';
  String _lng = '';

  @override
  void initState() {
    super.initState();
    // Récupérer toutes les tâches stockées en BDD lors de l'arrivée sur la page
    fetchTodos();
  }

  // Fonction qui permet de récupérer toutes les tâches stockées en BDD
  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      body: Stack(
        children: [
          // La liste des tâches
          FutureBuilder<List<Todo>>(
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

                        // Si la tâche est terminée alors elle est grisée
                        child: Card(
                          color: todo.isDone == 0
                          ? Colors.lime
                          : Colors.grey,

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

                            subtitle: checkDate(todo),

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
                                            builder: (BuildContext context) {
                                              return updateTodo(todo);
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
                                            });
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
          )
        ],
      ),



      // Le bouton pour ajouter une nouvelle tâche
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          // Au click afficher le BottomSheet pour créer une tâche
          showModalBottomSheet(
            constraints: const BoxConstraints(maxWidth: double.maxFinite),
            context: context,
            builder: (BuildContext context) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Champ pour entrer le nom de la tâche
                    Padding(
                      padding: EdgeInsets.only(left: 10),
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
                        onSaved: (titleValue) {
                          _todoName = titleValue!;
                        },
                      ),
                    ),

                    // Champ pour entrer la date
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                          labelText: 'Date d\'échéance', filled: true),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? dateTime =
                        await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100));
                        if (dateTime != null) {
                          setState(() {
                            _dateController.text =
                            dateTime.toString().split(" ")[0];
                          });
                        }
                      },
                      onChanged: (dateValue) {
                        _date = dateValue;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                        ),
                        onChanged: (adress){
                          _adress = adress;
                        },
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Bouton pour ajouter la tâche
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () async {
                                if(_adress.isNotEmpty){
                                  List<Location> locations = await locationFromAddress(_adress);
                                  _lat = locations.last.latitude.toString();
                                  _lng = locations.last.longitude.toString();
                                }

                                // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  // Si oui, alors ajout de la tâche dans la BDD
                                  setState(() {
                                    // Appel à la méthode create de la BDD pour enregistrer la tâche
                                    todoDB.create(title: _todoName, date: _dateController.text, lat: _lat, lng: _lng);
                                    _dateController.text = '';
                                    _lat = '';
                                    _lng = '';
                                    // Rafraîchir l'affichage des tâches
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
                              _dateController.text = '';
                              Navigator.pop(context);
                            },
                            child: const Text('annuler', style: TextStyle(color: Colors.white),),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            }
          );
        },
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
  Widget? checkDate(Todo todo) {
    if (todo.date != null && todo.date!.isNotEmpty) {
      return Text(todo.date!);
    }
    return null;
  }


  TileLayer get openStreetMapTilelayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  );



  // Fonction pour modifier une tâche
  Form updateTodo(Todo todo) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 1er enfant : titre de la tâche
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "titre",
              ),
              validator: (titleValue) {
                if (titleValue == null || titleValue.isEmpty) {
                  titleValue = todo.title;
                  _todoName = todo.title!;
                  return null;
                }
                return null;
              },
              initialValue: todo.title,
              onSaved: (titleValue) {
                _todoName = titleValue!;
              },
            ),
          ),

          // 2e enfant : la date
          TextField(
            controller: _dateController,
            decoration: InputDecoration(labelText: todo.date, filled: true),
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
                          // Appel à la méthode update de la BDD pour mettre à jour la tâche
                          todoDB.update(id: todo.id, title: _todoName, date: _dateController.text);
                          _dateController.text = '';
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
                    _dateController.text = '';
                    Navigator.pop(context);
                  },
                  child: const Text('annuler', style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          )
        ],
      ),
    );
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