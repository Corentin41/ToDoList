/*import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';

import '../database/todo_db.dart';
import 'delete_dialog_widget.dart';

class DisplayTodo extends StatefulWidget {
  final Todo todo;

  const DisplayTodo({Key? key, required this.todo}) : super(key: key);

  @override
  State<DisplayTodo> createState() => _DisplayTodoState();
}

class _DisplayTodoState extends State<DisplayTodo> {
  // Liste de tâches et la BDD
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();

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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(

        onTap: () {
          // Changer valeur isDone pour indiquer que la tâche est terminée
          widget.todo.isDone = !widget.todo.isDone;
        },

        // Background qui entoure la tâche
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.lime,

        // Case à cocher pour indiquer qu'une tâche est terminée
        leading: widget.todo.isDone == false
            ? const Icon(Icons.check_box_outline_blank, color: Colors.blueAccent)
            : const Icon(Icons.check_box, color: Colors.blueAccent),

        // Titre de la tâche
        title: Text(
          widget.todo.title!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 20, decoration: widget.todo.isDone ? TextDecoration.lineThrough : null),
        ),

        // Sous-titre de la tâche : la date
        subtitle: checkDate(widget.todo),

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
                    // Modifier la tâche
                    onPressed: () {
                      /*showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return updateTodo(todo);
                          });*/
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
                    onPressed: () async {
                      // Supprimer la tâche
                      await todoDB.delete(widget.todo.id);
                      // Rafraîchir l'affichage
                      fetchTodos();
                      // Appeler la popup pour demander confirmation de la supression
                      /*showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteDialog(todo: todo,);
                        },
                      );*/
                    },
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}



// Fonction pour vérifier si l'utilisateur a entré une date ou non
Widget? checkDate(Todo todo) {
  if (todo.date != null && todo.date!.isNotEmpty) {
    return Text(todo.date!);
  }
  return null;
}
*/