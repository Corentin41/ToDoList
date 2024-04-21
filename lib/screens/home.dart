import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/widgets/displayTask.dart';
import 'package:todolist/widgets/updateTask.dart';

import '../database/task_db.dart';
import '../model/task.dart';
import '../widgets/createTask.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Liste des tâches et la BDD
  Future<List<Task>>? futureTasks;
  final taskDB = TaskDB();

  // Liste qui contient les titres pour trier la liste des tâches
  List<String> myPrefs = ['Priorité','Date de création','Date d\'échéance'];
  // Initialiser le choix du tri de la liste à niveau de Priorité
  String _sortPref = ''; // Pour l'affichage
  bool _displayPref = true; // pour l'affichage des tâches terminées
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
        loadTasks();
      });
    });
  }

  // Fonction qui permet de récupérer toutes les tâches stockées en BDD
  void loadTasks() async {

    // Récupérer le choix du tri de la liste provenant des SharedPrefs
    await _getSortPref();

    // Récupérer le choix de l'affichage des tâches terminées provenant des SharedPrefs
    await _getDisplayPref();

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
      futureTasks = taskDB.fetchAll(_orderBy);
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

  Future<bool> _getDisplayPref() async {
    final prefs = await SharedPreferences.getInstance();
    _displayPref = prefs.getBool('displayPref') ?? true;
    return _displayPref;
  }

  Future<void> _saveDisplayPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('displayPref', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // Affichage de la liste des tâches
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: FutureBuilder<List<Task>>(
                future: futureTasks,
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
                      final tasks = snapshot.data!;
                      // Affichage des tâches
                      return ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          // Identifier chaque tâche avec son index
                          final task = tasks[index];

                          // Possibilité de supprimer une tâche par glissement
                          return Dismissible(
                            key: ValueKey<int>(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              child: const Icon(Icons.delete_forever, color: Colors.white),
                            ),
                            // Supprimer une tâche et rafraîchir la liste
                            onDismissed: (DismissDirection direction) {
                              setState(() {
                                taskDB.delete(task.id);
                                loadTasks();
                              });
                            },
                            child: ( !_displayPref && task.isDone==1) ? Container() : Container(
                              margin: const EdgeInsets.all(5),

                              // Couleur de fond des tâches
                              child: Card(
                                color: task.priority == 1
                                    ? task.isDone == 0
                                // Tâche prioritaire en cours => orange
                                    ? Colors.orange.shade300
                                // Tâche prioritaire terminée => grey
                                    : Colors.grey
                                    : task.isDone == 0
                                // Tâche en cours => lime
                                    ? Theme.of(context).colorScheme.secondary
                                // Tâche terminée => grey
                                    : Theme.of(context).colorScheme.tertiary,
                                // Si la tâche est terminée alors elle est grisée

                                child: ListTile(
                                  // Au click sur la tâche peut voir les détails
                                  onTap: () {
                                    DisplayTask.showTask(context, task);
                                  },



                                  // Icon indiquant si la tâche est terminée ou non
                                  leading: IconButton(
                                    // Si la tâche est terminée (isDone à 1) alors afficher une check_box pleine
                                    icon: task.isDone == 0
                                        ? const Icon(Icons.check_box_outline_blank)
                                        : const Icon(Icons.check_box),
                                    color: task.isDone == 1 ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.background,

                                    // Au click sur la box on change l'état de la tâche (terminée = 1 / en cours = 0)
                                    onPressed: () {
                                      setState(() {
                                        if (task.isDone == 0) {
                                          task.isDone = 1;
                                        } else {
                                          task.isDone = 0;
                                        }
                                        // Appel à la méthode update de la BDD pour mettre à jour la tâche
                                        taskDB.update(id: task.id, isDone: task.isDone);
                                        // Rafraichîr l'affichage pour mettre les tâches terminées en bas
                                        loadTasks();
                                      });
                                    },
                                  ),



                                  // Affiche le titre de la tâche
                                  title: Text(
                                    task.name,
                                    style: TextStyle(
                                      color: task.isDone == 1 ? Colors.white : Colors.black,
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      // Si la tâche est terminée (isDone à 1) alors barrer le titre
                                      decoration: task.isDone == 1 ? TextDecoration.lineThrough : null,
                                    ),
                                  ),



                                  // Appeler la fonction checkDate pour afficher ou non la date en sous-titre
                                  subtitle: checkDate(task) == true
                                      ? Text(
                                    task.date!,
                                    style: TextStyle(
                                      color: task.isDone == 1 ? Colors.white : Colors.black,
                                      // Si la tâche est terminée (isDone à 1) alors barrer le titre
                                      decoration: task.isDone == 1 ? TextDecoration.lineThrough : null,
                                    ),
                                  )
                                      : null,



                                  // Bouton pour supprimer avec confirmation
                                  trailing: Container(
                                    margin: const EdgeInsets.only(left: 5,top: 10,bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: IconButton(
                                      color: Colors.white,
                                      iconSize: 16,
                                      icon: const Icon(Icons.delete),
                                      // Appel à la fonction deleteTask
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return deleteTask(task);
                                          },
                                        );
                                      },
                                    ),
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.black),
          // Au click afficher le BottomSheet pour créer une tâche
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTask()));
          },
        )
    );
  }

  // Fonction pour créer l'AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text('Mes tâches'),
      // Désactiver la possibilité de retour lors de l'affichage des tâches
      automaticallyImplyLeading: false,
      actions: [
        Builder(builder: (context){
          return IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                            height: 400,
                            width: double.maxFinite,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text('Quel ordre pour l\'affichage des tâches ?'),
                                  DropdownMenu<String>(
                                    // Afficher le nom du tri par défaut
                                    hintText: _sortPref,
                                    onSelected: (String? value) {
                                      setState(() {
                                        // Sauvegarder le choix en SharedPrefs et rafraîchir la liste des tâches en conséquence
                                        _saveSortPref(value.toString());
                                        loadTasks();
                                      });
                                    },
                                    // Contient les différents choix pour trier la liste
                                    dropdownMenuEntries: myPrefs.map<DropdownMenuEntry<String>>((String value) {
                                      return DropdownMenuEntry<String>(value: value, label: value);
                                    }).toList(),
                                  ),

                                  const Text('Afficher les tâches terminées ?'),
                                  Switch(
                                    // This bool value toggles the switch.
                                    value: _displayPref,
                                    onChanged: (bool value) {
                                      // This is called when the user toggles the switch.
                                      setState(() {
                                        _saveDisplayPref(value);
                                        loadTasks();
                                      });
                                    },
                                  ),
                                  ElevatedButton(
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ),
                            )
                        );
                      });

                    },
                );
          },
          icon: const Icon(Icons.settings)
          );
        })
      ],
    );
  }



  // Fonction pour vérifier si l'utilisateur a entré une date ou non
  bool checkDate(Task task) {
    if (task.date != null && task.date!.isNotEmpty) {
      return true;
    }
    return false;
  }



  // Pour afficher la map
  TileLayer get openStreetMapTilelayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  );



  // Fonction pour supprimer une tâche
  deleteTask(Task task) {
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
              taskDB.delete(task.id);
              // Rafraîchir l'affichage des tâches
              loadTasks();
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
            Navigator.pop(context);
          },
          child: const Text('Annuler',
            style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }

}
