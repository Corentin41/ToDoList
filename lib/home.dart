import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/main.dart';
import 'package:todolist/themes/theme_provider.dart';
import 'package:todolist/screens/displayTask.dart';
import 'database/task_db.dart';
import 'model/task.dart';
import 'screens/createTask.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Liste des tâches et la BDD
  Future<List<Task>>? futureTasks;
  final taskDB = TaskDB();

  // Listes qui contiennent les valeurs des DropDownMenu (tri de la liste et traduction de l'app)
  List<String> mySortPrefs = ['Priorité','Date de création','Date d\'échéance'];
  List<String> languages = ['Français','English','Español'];
  
  // Initialiser les SharedPrefs
  String _sortPref = ''; // Pour le tri de la liste
  bool _displayPref = true; // Pour l'affichage des tâches terminées
  String _themePref = ''; // Pour le thème de l'app
  String _currentLanguage = ''; // Pour la langue de l'app
  String _orderBy = '';// Pour la BDD
  
  @override
  void initState() {
    super.initState();
    // Récupérer les sharedPrefs afin d'initialiser l'application
    _getSortPref().then((sortValue) {
        _getLanguagePref().then((languageValue) {
          _getThemePref().then((themeValue) {
            setState(() {
              if (_sortPref.isEmpty) {
                _sortPref = AppLocalizations.of(context).priority;
              }

              if(_themePref.isEmpty){
                var brightness = MediaQuery.of(context).platformBrightness;
                bool isDarkMode = brightness == Brightness.dark;

                // Si il y a pas de sharedPref d'enregistré, on applique le theme du telephone a l'application
                if(isDarkMode && Provider.of<ThemeProvider>(context,listen: false).light == true){
                  Provider.of<ThemeProvider>(context,listen: false).toggleTheme();
                  _saveThemePref('dark');
                }else{
                  _saveThemePref('light');
                }
              }else{
                if(_themePref == 'dark'){
                  Provider.of<ThemeProvider>(context,listen: false).toggleTheme();
                }
              }
              // Recharger la liste des tâches et traduire les options dans le DropDownMenu
              loadTasks();
              translateSortPrefs();
            });
          });
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
      if (_sortPref == AppLocalizations.of(context).priority) {
        _orderBy = 'priority';
      }
      else if (_sortPref == AppLocalizations.of(context).creationDate) {
        _orderBy = 'created_at';
      }
      else if (_sortPref == AppLocalizations.of(context).dueDate) {
        _orderBy = 'date';
      }
      // Afficher la liste triée en fonction du _sortPref
      futureTasks = taskDB.fetchAll(_orderBy);
    });
  }

  
  // Récupérer depuis les SharedPreferences le choix du tri de la liste
  Future<String> _getSortPref() async {
    final prefs = await SharedPreferences.getInstance();
    _sortPref = prefs.getString('sortPref') ?? AppLocalizations.of(context).priority;
    return _sortPref;
  }

  // Stocker dans les SharedPreferences le choix du tri de la liste
  Future<void> _saveSortPref(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sortPref', value);
  }

  // Récupérer depuis les SharedPreferences le choix de la langue
  Future<String> _getLanguagePref() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('languagePref') ?? "fr";
    switch(_currentLanguage){
      case "en" :
        _currentLanguage = languages[1];
      case "es" :
        _currentLanguage = languages[2];
      default : // fr
        _currentLanguage = languages[0];
    }
    return _currentLanguage;
  }

  // Stocker dans les SharedPreferences le choix de la langue
  Future<void> _saveLanguagePref(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languagePref', value);
  }

  // Récupérer depuis les SharedPreferences le choix d'affichage des tâches terminées
  Future<bool> _getDisplayPref() async {
    final prefs = await SharedPreferences.getInstance();
    _displayPref = prefs.getBool('displayPref') ?? true;
    return _displayPref;
  }

  // Stocker dans les SharedPreferences le choix d'affichage des tâches terminées
  Future<void> _saveDisplayPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('displayPref', value);
  }

  // Récupérer depuis les SharedPreferences le choix du theme
  Future<String> _getThemePref() async{
    final prefs = await SharedPreferences.getInstance();
    _themePref = prefs.getString('themePref') ?? '';
    return _themePref;
  }

  // Stocker dans les SharedPreferences le choix du theme
  Future<void> _saveThemePref(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themePref', value);
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
                      return Center(child: Text(AppLocalizations.of(context).noTask, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
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
                                // Afficher un message indiquant que la tâche a été supprimée
                                notifDelete();
                              });
                            },
                            
                            // Si la tâche est terminée et que le choix est de ne pas les afficher alors ne rien retourner
                            child: (!_displayPref && task.isDone == 1) ? Container() : Container(
                              margin: const EdgeInsets.all(5),

                              // Couleur de fond des tâches
                              child: Card(
                                color: task.priority == 1
                                    ? task.isDone == 0
                                // Tâche prioritaire en cours => orange
                                    ? Colors.orange.shade300
                                // Tâche prioritaire terminée => gris foncé
                                    : Theme.of(context).colorScheme.tertiary
                                    : task.isDone == 0
                                // Tâche en cours => lime
                                    ? Theme.of(context).colorScheme.secondary
                                // Tâche terminée => gris clair
                                    : Colors.grey,
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

                                    // Au clique sur la box on change l'état de la tâche (terminée = 1 / en cours = 0)
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
                                        // Afficher une AlertDialog custom avec le package QuickAlert
                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: AppLocalizations.of(context).deleteTask,
                                            text: AppLocalizations.of(context).confirmDeleteTask,
                                            confirmBtnText: AppLocalizations.of(context).delete,
                                            confirmBtnColor: Colors.red,
                                            cancelBtnText: AppLocalizations.of(context).cancel,
                                            onConfirmBtnTap: () {
                                              setState(() {
                                                // Appel à la méthode delete de la BDD pour supprimer la tâche
                                                taskDB.delete(task.id);
                                                // Rafraîchir l'affichage des tâches
                                                loadTasks();
                                                // Afficher un message indiquant que la tâche a été supprimée
                                                notifDelete();
                                                Navigator.pop(context);
                                              });
                                            }
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

  // Fonction pour créer l'AppBar et afficher les settings de l'application
  AppBar _buildAppBar() {
    // Récupérer la taille de l'écran
    Size size = MediaQuery.of(context).size;
    translateSortPrefs();

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(AppLocalizations.of(context).myTasks),
      automaticallyImplyLeading: false,
      actions: [
        Builder(builder: (context){
          return IconButton(
              onPressed: () {
                // Afficher les settings dans un BottomSheet
                showModalBottomSheet(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  isScrollControlled: true,
                  constraints: const BoxConstraints(maxWidth: double.maxFinite),
                  context: context,
                  builder: (BuildContext context) {
                    // Retourner un context propre au BottomSheet
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {

                        // Détails du BottomSheet
                        return Container(
                            // Hauteur du BottomSheet des settings (moitié de la page)
                            height: size.height * 0.5,
                            child: Container(
                              decoration: const BoxDecoration(
                                // Arrondir les bords supérieurs du BottomSheet
                                borderRadius: BorderRadius.only(topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // En-tête du BottomSheet
                                  SizedBox(
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 20, right: 20),
                                      child: Column(
                                        children: [

                                          // Affichage d'une petite barre
                                          Padding(
                                            padding: const EdgeInsets.only(left: 150, top: 20, right: 150, bottom: 20),
                                            child: Container(
                                              height: 8,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                              ),
                                            ),
                                          ),

                                          // Titre de l'en-tête
                                          Text(
                                            AppLocalizations.of(context).settings,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ),

                                          // Affichage d'une petite barre pour séparer l'en-tête du contenu
                                          Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Container(
                                              height: 1,
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Contenu du BottomSheet
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            // Trier la liste
                                            Text(AppLocalizations.of(context).whichDisplayOrder),
                                            // DropDown pour sélectionner le tri de la liste
                                            DropdownMenu<String>(
                                              // Afficher le nom du tri par défaut
                                              initialSelection: _sortPref.toString(),
                                              onSelected: (String? value) {
                                                setState(() {
                                                  // Sauvegarder le choix en SharedPrefs et rafraîchir la liste des tâches en conséquence
                                                  _saveSortPref(value.toString());
                                                  loadTasks();
                                                });
                                              },
                                              // Contient les différents choix pour trier la liste
                                              dropdownMenuEntries: mySortPrefs.map<DropdownMenuEntry<String>>((String value) {
                                                return DropdownMenuEntry<String>(value: value, label: value);
                                              }).toList(),
                                            ),

                                            // Afficher ou non les tâches terminées
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(AppLocalizations.of(context).displayCompletedTasks),
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
                                                ],
                                              ),
                                            ),

                                            // Choisir le thème de l'application
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(AppLocalizations.of(context).darkMode),
                                                  Switch(
                                                    // This bool value toggles the switch.
                                                    value: !Provider.of<ThemeProvider>(context).light,
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _getThemePref().then((themeValue){
                                                          Provider.of<ThemeProvider>(context,listen: false).toggleTheme();
                                                          if(themeValue=='light'){
                                                            _saveThemePref('dark');
                                                          }else{
                                                            _saveThemePref('light');
                                                          }
                                                        });
                                                        // Fermer le BottomSheet après mise à jour
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Choisir la langue de l'application
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(AppLocalizations.of(context).language),
                                                  DropdownMenu<String>(
                                                    // Afficher le nom du tri par défaut
                                                    label: Text(_currentLanguage),
                                                    onSelected: (String? value) {
                                                      setState(() {
                                                        // Sauvegarder le choix en SharedPrefs et rafraîchir la liste des tâches en conséquence
                                                        switch(value.toString()){
                                                          case "Français":
                                                            MainApp.setLocale(context, const Locale('fr'));
                                                            _saveLanguagePref("fr").then((result)  {
                                                              _currentLanguage = value.toString();
                                                              translateSortPrefs();
                                                            });
                                                          case "English":
                                                            MainApp.setLocale(context, const Locale('en'));
                                                            _saveLanguagePref("en").then((result)  {
                                                              _currentLanguage = value.toString();
                                                              translateSortPrefs();
                                                            });
                                                          case "Español":
                                                            MainApp.setLocale(context, const Locale('es'));
                                                            _saveLanguagePref("es").then((result)  {
                                                              _currentLanguage = value.toString();
                                                              translateSortPrefs();
                                                            });
                                                        }
                                                        // Fermer le BottomSheet après mise à jour
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    // Contient les différents choix pour trier la liste
                                                    dropdownMenuEntries: languages.map<DropdownMenuEntry<String>>((String value) {
                                                      return DropdownMenuEntry<String>(value: value, label: value);
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                        );
                      },
                    );
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

  // Fonction pour informer que la tâche a bien été supprimée
  notifDelete() {
    // Afficher un message indiquant que la tâche a été supprimée
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(AppLocalizations.of(context).taskDeleted),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Traduit la liste des options de tri de la liste et sauvegarde la préférences en fonction de la lanque actuelle de l'application
  void translateSortPrefs() {
    int i = getSortIndex();

    mySortPrefs[0] = AppLocalizations.of(context).priority;
    mySortPrefs[1] = AppLocalizations.of(context).creationDate;
    mySortPrefs[2] = AppLocalizations.of(context).dueDate;

    _saveSortPref(mySortPrefs[i]).then((value) {
        _sortPref = mySortPrefs[i];
    });
  }

  // Récupère l'indice du choix selectionné dans la liste des options de tri pour la traduction
  int getSortIndex(){
    int i = mySortPrefs.indexWhere((element) => element == _sortPref);
    if(i==-1){
      _saveSortPref(mySortPrefs[0]).then((value) {
        _sortPref = mySortPrefs[0];
      });
      return 0;
    }
   return i;
  }
}
