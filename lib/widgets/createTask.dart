import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:todolist/model/todo.dart';
import 'package:todolist/screens/todos_page.dart';

import '../database/todo_db.dart';

class CreateTask extends StatefulWidget {

  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {


  // Liste des tâches et la BDD
  Future<List<Todo>>? futureTasks;
  final taskDB = TodoDB();

  // Pour le BottomSheet
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Par défaut, les tâches sont secondaires (priorité niv 2)
  int _todoPriority = 2;

  // Contiennent les valeurs dans le form
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  //String _address = '';
  String _lat = '';
  String _lng = '';



  @override
  void initState() {
    super.initState();
    loadTasks();
  }


  loadTasks() async {
    String sortPref = 'priority';
    futureTasks = taskDB.fetchAll(sortPref);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une tâche'),
      ),
      body: Padding(
        // Espace entre l'AppBar et le Form
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [



                    // Champ pour saisir le titre
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: _titleController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Nom"
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir un nom';
                          }
                          else {
                            return null;
                          }
                        },
                        // Sauvegarder le titre de la tâche
                        onSaved: (value) {
                          _titleController.text = value!;
                        },
                      ),
                    ),



                    // Champ pour saisir la description
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 5,
                        controller: _descController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Description"
                        ),
                      ),
                    ),



                    // Champ pour saisir la date
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Date d\'échéance"
                        ),
                        readOnly: true,
                        // Pour ajouter la date, on doit cliquer sur le champ qui va ouvir une dialog
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
                    ),



                    // Champ pour saisir l'adresse
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: _addressController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Adresse"
                        ),
                        onChanged: (address){
                          //_address = address;
                        },
                      ),
                    ),



                    // Définir le niveau de priorité de la tâche
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
                                if(_addressController.text.toString().isNotEmpty) {
                                  List<Location> locations = await locationFromAddress(_addressController.text);
                                  _lat = locations.last.latitude.toString();
                                  _lng = locations.last.longitude.toString();
                                }

                                // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  // Si oui, alors ajout de la tâche dans la BDD
                                  // Appel à la méthode create de la BDD pour enregistrer la tâche
                                  taskDB.create(
                                      title: _titleController.text.toString(),
                                      description: _descController.text.toString(),
                                      priority: _todoPriority,
                                      date: _dateController.text.toString(),
                                      lat: _lat,
                                      lng: _lng
                                  );
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TodosPage()));

                                  // Remettre à vide les champs
                                  _titleController.clear();
                                  _descController.clear();
                                  _dateController.clear();
                                  _todoPriority = 2;
                                  _lat = '';
                                  _lng = '';
                                  // Rafraîchir l'affichage des tâches et fermer le showModalBottomSheet
                                  //loadTasks();
                                  //Navigator.pop(context);
                                }
                              },
                              child: const Text('ajouter', style: TextStyle(color: Colors.white),)),
                        ),

                        // Bouton pour annuler la création de tâche
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              // Remettre à vide les champs et quitter la page
                              _dateController.clear();
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
              )
            ],
          ),
        ),
      ),
    );


    /*return showModalBottomSheet(
        constraints: const BoxConstraints(maxWidth: double.maxFinite),
        context: context,
        // Pour quitter l'ajout d'une tâche il faut cliquer sur le bouton annuler
        isDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Text("coucou"),
                )
              }
          );
        }
    );*/
  }
}

    /*return SingleChildScrollView(
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
  }*/