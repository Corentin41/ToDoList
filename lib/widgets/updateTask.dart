import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:todolist/model/task.dart';
import 'package:todolist/screens/home.dart';


import '../database/task_db.dart';

class UpdateTask extends StatefulWidget {
  final Task task;

  const UpdateTask({super.key, required this.task});

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {


  // Liste des tâches et la BDD
  Future<List<Task>>? futureTasks;
  final taskDB = TaskDB();


  // Pour le BottomSheet
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  // Initialiser les valeur contenues dans une tâche
  String _taskName = '';
  String _taskDesc = '';
  int _taskPriority = 2;
  String _lat = '';
  String _lng = '';


  // Booléen permettant de vérifier si l'adresse saisie est correcte
  bool _testAddress = true;


  // Contiennent les valeurs dans le form
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();


  @override
  initState() {
    super.initState();
    // Initialiser le niveau de priorité de la tâche à modifier
    _taskPriority = widget.task.priority;
    // Récupérer l'adresse (s'il y a une adresse en BDD)
    _lat = widget.task.lat!;
    _lng = widget.task.lng!;
    _addressController.text = widget.task.address!;
  }


  // Pour afficher la map centrée sur l'adresse entrée précédemment
  TileLayer get openStreetMapTilelayer =>
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la tâche'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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



                    // Champ pour modifier le titre de la tâche
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
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
                        // Afficher le titre précédemment entré par l'utilisateur
                        initialValue: widget.task.name,
                        onSaved: (nameValue) {
                          _taskName = nameValue!;
                        },
                      ),
                    ),



                    // Champ pour modifier la description
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 5,
                        //controller: _descController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Description"
                        ),
                        // Afficher la description précédemment entrée par l'utilisateur
                        initialValue: widget.task.description,
                        onSaved: (descValue) {
                          _taskDesc = descValue!;
                        },
                      ),
                    ),



                    // Champ pour modifier la date
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: TextField(
                        controller: _dateController,
                        // Afficher la date dans le champ s'il y avait déjà une date, sinon afficher un label
                        decoration: checkDate(widget.task) == true
                            ? InputDecoration(border: const OutlineInputBorder(), hintText: widget.task.date.toString())
                            : const InputDecoration(border: OutlineInputBorder(), labelText: 'Date d\'échéance'),
                        // Pour modifier la date, on doit cliquer sur le champ qui va ouvir une dialog
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
                      ),
                    ),



                    // Champ pour modifier l'adresse
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: _addressController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Adresse"
                        ),
                      ),
                    ),



                    // Modifier le niveau de priorité de la tâche
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Row(
                        children: [
                          const Text(
                              "Changer le niveau de priorité : ",
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          IconButton(
                            // Si la tâche est prioritaire (priority à 1) alors afficher une étoile pleine
                            icon: Icon(_taskPriority == 1 ? Icons.star : Icons.star_border,
                                color: Colors.blueAccent
                            ),
                            // Au click, changer le niveau de priorité (1 pour prioritaire et 2 pour secondaire)
                            onPressed: () {
                              setState(() {
                                if (_taskPriority == 2) {
                                  _taskPriority = 1;
                                } else {
                                  _taskPriority = 2;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),



                    // Boutons pour confirmer ou annuler la modification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Bouton pour confirmer la modification
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () async {
                                // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  // Si la date n'a pas été modifiée alors prendre la date déjà enregistrée en BDD
                                  if (_dateController.text.isEmpty) {
                                    _dateController.text = widget.task.date.toString();
                                  }

                                  // Si l'adresse a été modifiée et n'est pas vide alors vérifier qu'elle existe
                                  if (_addressController.text != widget.task.address) {
                                    if (_addressController.text.isNotEmpty) {
                                      // Récupérer les coordonnées à partir de l'adresse entrée
                                      await testAddress();
                                      if (_testAddress == false) {
                                        // Afficher une AlertDialog custom avec le package QuickAlert
                                        return QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.warning,
                                            title: 'Attention',
                                            text: 'Vous avez saisi une adresse incorrecte ou inexistante',
                                            confirmBtnText: 'OK'
                                        );
                                      }
                                    }
                                  }

                                  // Modification de la tâche dans la BDD
                                  taskDB.update(
                                    id: widget.task.id,
                                    name: _taskName,
                                    description: _taskDesc,
                                    priority: _taskPriority,
                                    date: _dateController.text.toString(),
                                    lat: _lat,
                                    lng: _lng,
                                    address: _addressController.text.toString(),
                                  );
                                  // Retourner sur la page d'affichage des tâches
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                                }
                              },
                              child: const Text('modifier',
                                style: TextStyle(color: Colors.white),)),
                        ),



                        // Bouton pour annuler la modification de tâche
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              // Retourner sur la page d'affichage des tâches
                              Navigator.pop(context);
                            },
                            child: const Text('annuler',
                              style: TextStyle(color: Colors.white),),
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
  }



  // Fonction pour vérifier si l'utilisateur a entré une date ou non
  bool checkDate(Task task) {
    if (task.date != null && task.date!.isNotEmpty) {
      return true;
    }
    return false;
  }



  // Fonction qui permet de vérifier si l'adresse entrée existe
  Future<bool> testAddress() async {
    try {
      List<Location> locations = await locationFromAddress(_addressController.text);
      _lat = locations.last.latitude.toString();
      _lng = locations.last.longitude.toString();
      _testAddress = true;
    } catch(e) {
      _testAddress = false;
    }
    return _testAddress;
  }

}