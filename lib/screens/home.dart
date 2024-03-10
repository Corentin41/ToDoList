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
      body: Stack(
        children: [
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
          ElevatedButton(onPressed: (){
            showModalBottomSheet(context: context, builder: (BuildContext context){
              return Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty){
                            return 'enter something';
                          }
                          return null;
                        },
                      ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        filled: true
                      ),
                      readOnly: true,
                      onTap : () {
                        _selectDate(context);
                      },
                    ),
                    Row(children: [
                      ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: const Text('close')
                      ),
                      ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: const Text('add')
                      ),
                    ],)
                    ],
                  )
              );
            });
          }, child: const Text('data'))
        ],
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