import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';
import 'package:todolist/widgets/todo_item.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  String _name = '';
  String _date = '';

  List<ToDo> toDoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [

            // 1er enfant : la liste des tâches
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: const Text('Tâches :'),
                          ),

                          // Appel aux différentes méthodes créées dans todo_item
                          for (ToDo todoo in toDoList)
                            TodoItem(
                              todo: todoo,
                              onToDoChanged: _handleToDoChange,
                              onDeleteItem: _deleteToDoItem,
                              onEditItem: _editToDoItem,
                            ),
                        ],
                      ))
                ],
              ),
            ),


            // 2e enfant : la bouton pour ajouter une tâche
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                  backgroundColor: Colors.lime,
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                        constraints:
                            const BoxConstraints(maxWidth: double.maxFinite),
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
                                      if (titleValue == null ||
                                          titleValue.isEmpty) {
                                        return 'enter something';
                                      }
                                      return null;
                                    },
                                    onSaved: (titleValue) {
                                      print(titleValue);
                                      _name = titleValue!;
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
                                  children: [

                                    // Bouton pour ajouter la tâche
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // Si la validation réussit, accédez aux valeurs du formulaire
                                            // à l'aide de la méthode save() et effectuez des actions nécessaires
                                            _formKey.currentState!.save();

                                            // Utilisez les valeurs du formulaire comme nécessaire
                                            // par exemple, enregistrez-les dans une base de données, envoyez-les à un serveur, etc.
                                            // _name contiendra la valeur du champ de texte nom, _email la valeur du champ de texte email, etc.

                                            setState(() {
                                              int l = toDoList.length + 1;
                                              ToDo newToDo = ToDo(
                                                  id: l.toString(),
                                                  todoTitle: _name,
                                                  date: _dateController.text);
                                              toDoList.add(newToDo);
                                              _dateController.text = '';
                                              Navigator.pop(context);
                                            });
                                          }
                                        },
                                        child: const Text('ajouter',
                                        style: TextStyle(color: Colors.white),)),

                                    // Bouton pour fermer le showModalBottomSheet
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () {
                                        _dateController.text = '';
                                        Navigator.pop(context);
                                      },
                                      child: const Text('fermer',
                                      style: TextStyle(color: Colors.white),),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        });
                  }),
            )
          ],
        ));
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      toDoList.removeWhere((item) => item.id == id);
    });
  }

  void _editToDoItem(ToDo todo) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return _buildEditForm(todo);
        });
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.lime,
      title: const Text('ToDo List'),
    );
  }








  // Editer une tâche
  Form _buildEditForm(ToDo todo) {
    return Form(
      key: _formKey,
      child: Column(
        children: [

          // 1er enfant : titre de la tâche
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "titre",
              ),
              validator: (titleValue) {
                if (titleValue == null || titleValue.isEmpty) {
                  titleValue = todo.todoTitle;
                  _name = todo.todoTitle!;
                  return null;
                }
                return null;
              },
              initialValue: todo.todoTitle,
              onSaved: (titleValue) {
                _name = titleValue!;
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

          // Les boutons pour valider ou annuler la modification
          Row(
            children: [
              // Bouton modifier
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      setState(() {
                        Iterable<ToDo> item =
                            toDoList.where((item) => item.id == todo.id);

                        if (_name != todo.todoTitle!) {
                          item.first.todoTitle = _name;
                        }

                        print(_dateController.text);
                        if (_dateController.text.isEmpty) {
                          item.first.date = todo.date;
                        } else {
                          item.first.date = _dateController.text;
                        }

                        _dateController.text = '';
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: const Text('modifier',
                  style: TextStyle(color: Colors.white),)),

              // Bouton annuler
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    _dateController.text = '';
                    Navigator.pop(context);
                  },
                  child: const Text('annuler',
                    style: TextStyle(color: Colors.white),)),
            ],
          )
        ],
      ),
    );
  }
}
