import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';

class TodoItem extends StatelessWidget{
  final ToDo todo;
  final onToDoChanged;
  final onDeleteItem;
  final onEditItem;

  const TodoItem({Key? key, required this.todo, required this.onToDoChanged, required this.onDeleteItem, required this.onEditItem}) : super(key:key);

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
        leading: Icon(
          todo.isDone? Icons.check_box : Icons.check_box_outline_blank,
          color: Colors.blueAccent,),
        title: Text(
          todo.todoTitle!,
          style: TextStyle(
            fontSize: 24,
            decoration: todo.isDone? TextDecoration.lineThrough : null,
          ),
        ),

        subtitle: checkDate(todo),

        trailing: Container(
          height: 35,
          width: 100,

          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: IconButton(
                  color: Colors.white,
                  iconSize: 16,
                  icon: const Icon(Icons.edit),
                  onPressed: (){
                    onEditItem(todo);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: IconButton(
                  color: Colors.white,
                  iconSize: 16,
                  icon: const Icon(Icons.delete),
                  onPressed: (){
                    onDeleteItem(todo.id);
                  },
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

}

Widget? checkDate(ToDo todo) {
  if(todo.date != null && todo.date!.isNotEmpty){
    return Text(todo.date!);
  }
  return null;
}