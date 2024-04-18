import 'package:artfolio/homePage.dart';
import 'package:artfolio/splashScreen.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}


class MainApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: HomePage(),
    /*  home: SplashScreen(
        backgroundColor: Color.fromARGB(255, 244, 248, 255),
        duration: Duration(seconds: 2),
      ), */ 
    );
  }
}
