import 'package:flutter/material.dart';
import 'package:todolist/themes/theme.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = lightMode;
  bool _light = true;

  ThemeData get themeData => _themeData;
  bool get light => _light;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme(){
    if(_themeData == lightMode){
      themeData = darkMode;
      _light = false;
    }else{
      themeData = lightMode;
      _light = true;
    }
  }
}