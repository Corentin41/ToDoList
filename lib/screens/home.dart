import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';
import 'package:todolist/widgets/todo_item.dart';

class Home extends StatefulWidget {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   Home({Key? key}) : super(key:key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  final TextEditingController _dateController = TextEditingController();
  final todosList = ToDo.todoList();
  String _name = '';
  String _date = '';

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
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                            labelText: 'Date',
                            filled: true
                        ),
                        readOnly: true,
                        onTap : () async {
                          final DateTime? dateTime = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100)
                          );
                          if(dateTime != null){
                            setState(() {
                              _dateController.text = dateTime.toString().split(" ")[0];
                            });
                          }
                        },
                        onChanged: (value) {
                          _date = value;
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
                            onPressed: () {
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