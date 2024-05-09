import 'package:flutter/material.dart';
import 'package:todolist/themes/theme.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = lightMode;
  bool _light = true;

  ThemeData get themeData => _themeData;
  bool get light => _light;

  // Change le theme et notifie les classes qui "écoutent" que le theme a été changé
  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  // Change le thème de l'application
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