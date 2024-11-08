import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:todolist/model/task.dart';
import 'package:todolist/home.dart';
import '../database/task_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateTask extends StatefulWidget {

  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {

  // Liste des tâches et la BDD
  Future<List<Task>>? futureTasks;
  final taskDB = TaskDB();

  // Pour vérifier que le champ titre n'est pas vide
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Contiennent les valeurs dans le form
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Initialiser les valeur contenues dans une tâche
  String _taskName = '';
  String _taskDesc = '';
  int _taskPriority = 2; // Par défaut, les tâches sont secondaires (priorité niv 2)
  String _lat = '';
  String _lng = '';

  // Booléen permettant de vérifier si l'adresse saisie est correcte
  bool _testAddress = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addTask),
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

                    // Champ pour saisir le titre
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: AppLocalizations.of(context).name
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context).addName;
                          }
                          else {
                            return null;
                          }
                        },
                        // Sauvegarder le titre de la tâche
                        onSaved: (nameValue) {
                          _taskName = nameValue!;
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
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: AppLocalizations.of(context).desc
                        ),
                        // Sauvegarder la description de la tâche
                        onSaved: (descValue) {
                          _taskDesc = descValue!;
                        },
                      ),
                    ),

                    // Champ pour saisir la date
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: AppLocalizations.of(context).dueDate
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
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: AppLocalizations.of(context).address
                        ),
                      ),
                    ),

                    // Définir le niveau de priorité de la tâche
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: Row(
                        children: [
                          Text(
                              AppLocalizations.of(context).setPriority,
                              style: const TextStyle(fontWeight: FontWeight.bold)),

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

                                // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  // Vérifier que l'utilisateur a une connexion Internet pour vérifier l'adresse
                                  if (_addressController.text.isNotEmpty) {
                                    bool checkInternet = await InternetConnectionChecker().hasConnection;
                                    if (checkInternet == false) {
                                      return QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: AppLocalizations.of(context).networkAlertTitle,
                                          text: AppLocalizations.of(context).networkAlertContent,
                                          confirmBtnText: AppLocalizations.of(context).ok
                                      );
                                    }
                                  }

                                  // Vérifier que s'il y a une adresse alors elle existe
                                  await testAddress();

                                  // Si l'adresse saisie n'existe pas alors retourner une AlertDialog
                                  if (_addressController.text.isNotEmpty && _testAddress == false) {
                                    // Afficher une AlertDialog custom avec le package QuickAlert
                                    return QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.warning,
                                      title: AppLocalizations.of(context).warning,
                                      text: AppLocalizations.of(context).wrongAddress,
                                      confirmBtnText: AppLocalizations.of(context).ok
                                    );
                                  }

                                  // Ajout de la tâche dans la BDD
                                  taskDB.create(
                                      name: _taskName,
                                      description: _taskDesc,
                                      priority: _taskPriority,
                                      date: _dateController.text,
                                      lat: _lat,
                                      lng: _lng,
                                      address: _addressController.text
                                  );
                                  // Retourner sur la page d'affichage des tâches
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                                }
                              },
                              child: Text(AppLocalizations.of(context).add, style: const TextStyle(color: Colors.white),)),
                        ),

                        // Bouton pour annuler la création de tâche
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context).cancel, style: const TextStyle(color: Colors.white)),
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