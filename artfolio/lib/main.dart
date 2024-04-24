import 'package:artfolio/splashScreen.dart';
import 'package:artfolio/themes/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MainApp(),
    ),
  );
}


class MainApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: SplashScreen(
        backgroundColor: Color.fromARGB(255, 244, 248, 255),
        duration: Duration(seconds: 2),
      ), 
    );
  }
}
