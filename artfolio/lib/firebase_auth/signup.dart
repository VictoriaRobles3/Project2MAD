import 'package:artfolio/firebase_auth/authService.dart';
import 'package:artfolio/firebase_auth/container.dart';
import 'package:artfolio/firebase_auth/login.dart';
import 'package:artfolio/homePage.dart';
import 'package:artfolio/userService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  final AuthenticationService _auth = AuthenticationService();

  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.macondoTextTheme(),
      ),
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 244, 248, 255),
        body: SingleChildScrollView( 
          child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "New User?\nCreate an account!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.macondo(
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _firstNameController,
                  hintText: 'First Name',
                  isPassword: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _lastNameController,
                  hintText: 'Last Name',
                  isPassword: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: 'Email',
                  isPassword: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text("Date of Birth: "),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        _selectedDateOfBirth != null
                            ? DateFormat('yMMMMd').format(_selectedDateOfBirth!)
                            : "Select Date",
                        style: TextStyle(color: Color.fromARGB(255, 0, 68, 85)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: _signUp,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 173, 215, 252),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?\t"),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text("Log in",
                            style: TextStyle(
                                color: Color.fromARGB(255, 252, 101, 19),
                                fontWeight: FontWeight.bold)))
                  ],
                )
              ],
            ),
          ),
        )),
      ),
    );

  }

  void _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );

  if (pickedDate != null) {
    setState(() {
      _selectedDateOfBirth = pickedDate;
    });
  }
}


  void _signUp() async {
  String firstName = _firstNameController.text;
  String lastName = _lastNameController.text;
  String email = _emailController.text;
  String password = _passwordController.text;

  if (!_isValidEmail(email)) {
    print("Invalid email address format");
    return;
  }
  if (_selectedDateOfBirth == null) {
    print("Please select a date of birth");
    return;
  }


  User? user = await _auth.registerUser(
      email, password, firstName, lastName, _selectedDateOfBirth!);

  if (user != null) {
    await UserService().registerUser(firstName, lastName, _selectedDateOfBirth!);

    print("Account created successfully!");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  } else {
    print("Error. Cannot register user.");
  }
}

bool _isValidEmail(String email) {
  return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}
}
