import 'package:flutter/material.dart';
import 'package:todolist/screens/home.dart';
import 'package:todolist/themes/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      theme: lightMode,
      darkTheme: darkMode,
      home: HomePage(),
    );
  }
}
