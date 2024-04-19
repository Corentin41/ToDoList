import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade50,
    primary: Colors.blue.shade500,
    secondary: Colors.blue.shade300,
    tertiary: Colors.grey.shade600

  )

);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade800,
      primary: Colors.blue.shade500,
      secondary: Colors.blue.shade300,
      tertiary: Colors.grey.shade600


    )
);
