import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';
import 'package:todolist/widgets/todo_item.dart';

class Home extends StatelessWidget {

   Home({Key? key}) : super(key:key);

  final todosList = ToDo.todoList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
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
                      child: const Text('Tâches',),
                    ),
                    for (ToDo todo in todosList)
                      TodoItem(todo: todo,),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.lime,
      title: const Text('ToDo List'),
    );
  }
}