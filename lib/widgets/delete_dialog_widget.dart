/*import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';
import 'package:todolist/screens/todos_page.dart';
import 'package:todolist/widgets/display_todo_widget.dart';

import '../database/todo_db.dart';
import '../screens/home.dart';

class DeleteDialog extends StatefulWidget {
  final Todo todo;

  const DeleteDialog({super.key, required this.todo});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  // Liste des tâches et la BDD
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();

  // Fonction qui permet de récupérer toutes les tâches stockées en BDD
  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              todoDB.delete(widget.todo.id);
              // Récupérer toutes les tâches
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


}*/