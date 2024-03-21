import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';

import 'MyPopup.dart';

class TodoItem extends StatelessWidget {
  final ToDo todo;
  final onToDoChanged;
  final onDeleteItem;
  final onEditItem;

  const TodoItem(
      {Key? key,
      required this.todo,
      required this.onToDoChanged,
      required this.onDeleteItem,
      required this.onEditItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          onToDoChanged(todo);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.lime,

        // Case à cocher pour indiquer qu'une tâche est terminée
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: Colors.blueAccent,
        ),

        // Titre de la tâche
        title: Text(
          todo.todoTitle!,
          style: TextStyle(
            fontSize: 20,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),

        // Sous-titre de la tâche : la date
        subtitle: checkDate(todo),

        // Contient les 2 options (pour modifier ou supprimer la tâche)
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
                    onPressed: () {
                      onEditItem(todo);
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
                    onPressed: () {

                      // Appeler la popup
                      /*showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return MyPopup(todo: todo,);
                        },
                      );*/

                      // Supprimer un todo sans la popup
                      onDeleteItem(todo.id);

                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

// Fonction pour vérifier si l'utilisateur a entré une date ou non
Widget? checkDate(ToDo todo) {
  if (todo.date != null && todo.date!.isNotEmpty) {
    return Text(todo.date!);
  }
  return null;
}
