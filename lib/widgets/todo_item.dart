import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';

class TodoItem extends StatelessWidget{
  final ToDo todo;

  const TodoItem({Key? key, required this.todo}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.lime,
        leading: const Icon(Icons.check_box, color: Colors.limeAccent,),
        title: Text(
            todo.todoTitle!
        ),
      ),
    );
  }

}