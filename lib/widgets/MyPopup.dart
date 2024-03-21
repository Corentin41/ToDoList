import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';

import '../screens/home.dart';

class MyPopup extends StatefulWidget {
  // Initialisation de l'objet ToDo
  final ToDo todo;

  const MyPopup({super.key, required this.todo});

  @override
  State<MyPopup> createState() => _MyPopupState();
}

class _MyPopupState extends State<MyPopup> {
  bool checkBoxValue = false;
  TextEditingController textFieldController = TextEditingController();

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
              // Supprimer l'item todo
            },
            child: const Text('Confirmer',
            style: TextStyle(color: Colors.white),),
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


}