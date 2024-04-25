import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    // Pour le fond en général
    background: Colors.white,
    // Pour le reste de l'application
    primary: Colors.blue.shade500,
    secondary: Colors.blue.shade300,
    tertiary: Colors.grey.shade600,
    // Pour le fond dans la description d'une tâche
    onBackground: Colors.grey.shade300,
  )

);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      // Pour le fond en général
      background: Colors.grey.shade800,
      // Pour le reste de l'application
      primary: Colors.blue.shade500,
      secondary: Colors.blue.shade300,
      tertiary: Colors.grey.shade600,
      // Pour le fond dans la description d'une tâche
      onBackground: Colors.grey.shade900,
    )
);
