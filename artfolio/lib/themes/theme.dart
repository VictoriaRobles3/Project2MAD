import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
    colorScheme: ColorScheme.light(
    background:Color.fromARGB(255, 244, 248, 255),
    primary: Color.fromARGB(255, 178, 205, 253),
    secondary: Color.fromARGB(255, 244, 191, 187),
    onBackground: Color.fromARGB(255, 235, 249, 232),
    onSurface: Colors.black,  //onSurface textColor lightMode

  )
);


ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Color.fromARGB(255, 113, 116, 111),
    secondary: Color.fromARGB(255, 249, 118, 3),
    onBackground: Color.fromARGB(255, 88, 96, 99),
    onSurface: Colors.white, //onSurface textColor darkMode

  )
);
