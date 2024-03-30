import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/todo_db.dart';
import '../model/todo.dart';
import '../widgets/display_todo_widget.dart';

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

  @override
  void initState() {
    super.initState();
    // Récupérer toutes les tâches stockées en BDD
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
                  final todoList = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Column(
                      children: [
                        Expanded(
                            child: ListView(
                              children: [
                                // Afficher chaque tâche présente dans la liste des tâches
                                for (Todo todoo in todoList)
                                  DisplayTodo(todo: todoo,),
                              ],
                            ),
                        ),
                      ],
                    ),
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
        child: const Icon(Icons.add),
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
                    // Champ pour entrer le nom de la tâche·
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
                          labelText: 'Date', filled: true),
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Bouton pour ajouter la tâche
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () {
                                // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  // Si oui, alors ajout de la tâche dans la BDD
                                  setState(() {
                                    // Appel à la méthode create de la BDD pour enregistrer la tâche
                                    todoDB.create(title: _todoName, date: _dateController.text);
                                    _dateController.text = '';
                                    // Récupérer toutes les tâches
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
      backgroundColor: Colors.lime,
      title: const Text('Mes tâches'),
    );
  }

}