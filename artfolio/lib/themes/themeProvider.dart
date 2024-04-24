import 'package:artfolio/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = lightMode;
  
  ThemeData get themeData => _themeData;
  
  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme(){
    if(_themeData == lightMode){
      themeData = darkMode;
    }
    else{
      themeData = lightMode;
    }
  }
}