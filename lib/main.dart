import 'package:flutter/material.dart';
import 'package:todolist/screens/home.dart';
import 'package:todolist/screens/todos_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      home: TodosPage(),
    );
  }
}
