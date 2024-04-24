import 'package:artfolio/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'userService.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordEditable = false;
  bool _isDateOfBirthEditable = false;

  String _dateOfBirth = "";

  final UserService _userService = UserService();
  User? _currentUser;
  DocumentSnapshot? _userData;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  bool _isFirstNameEditable = false;
  bool _isLastNameEditable = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUserData();
  }

  void _getCurrentUser() async {
    _currentUser = await _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
    }
  }

  Future<void> _loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        Timestamp dobTimestamp = userDoc['dob'];

        setState(() {
          _dateOfBirth = DateFormat('yyyy-MM-dd').format(dobTimestamp.toDate());
          _dobController.text = _dateOfBirth;
          print("Retrieved DOB: $_dateOfBirth");
        });
      } else {
        print("No DOB found in user document");
      }
    }
  }

  void _fetchUserData() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    final docSnapshot = await usersCollection.doc(_currentUser!.uid).get();
    if (docSnapshot.exists) {
      setState(() {
        _userData = docSnapshot;
        _firstNameController.text = _userData!['firstName'];
        _lastNameController.text = _userData!['lastName'];
      });
    } else {
      print('User data not found.');
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          if (_isPasswordEditable && _passwordController.text.isNotEmpty) {
            await currentUser.updatePassword(_passwordController.text);
          }
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
            'dob': Timestamp.fromDate(DateTime.parse(_dateOfBirth)),
          });
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Information updated successfully!'),
          ));
        }
      } catch (e) {
        print('Error updating information: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error updating information: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: _userData != null
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableField(
                    'First Name',
                    _firstNameController,
                    _isFirstNameEditable,
                    () {
                      setState(() {
                        _isFirstNameEditable = true;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  _buildEditableField(
                    'Last Name',
                    _lastNameController,
                    _isLastNameEditable,
                    () {
                      setState(() {
                        _isLastNameEditable = true;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${_currentUser!.email}',
                    style: GoogleFonts.podkova(
                      textStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildEditablePasswordField(),
                  SizedBox(height: 10),
                  _buildDobField(),
                  SizedBox(height: 10),
                  Text(
                    'Registration Date: ${DateFormat('dd-MM-yyy').format((_userData!['registrationDatetime'] as Timestamp).toDate())}',
                    style: GoogleFonts.podkova(
                      textStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 50),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateUserData,
                      child: Text(
                        'Update user information',
                        style: GoogleFonts.podkova(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 235, 109, 109),
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 253, 239, 252),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SplashScreen()),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          "Sign out",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _currentUser != null
              ? CircularProgressIndicator()
              : Text(''),
    );
  }

  Widget _buildDobField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _dobController,
            style: GoogleFonts.podkova(
              textStyle: TextStyle(fontSize: 22),
            ),
            enabled: _isDateOfBirthEditable,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            _isDateOfBirthEditable = !_isDateOfBirthEditable;
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              setState(() {
                _dateOfBirth = DateFormat('yyyy-MM-dd').format(selectedDate);
                _dobController.text = _dateOfBirth;
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 253, 239, 252),
          ),
          child: Text(
            'Edit',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 235, 109, 109),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditablePasswordField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            style: GoogleFonts.podkova(
              textStyle: TextStyle(fontSize: 25),
            ),
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isPasswordEditable = !_isPasswordEditable;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 253, 239, 252),
          ),
          child: Text(
            'Edit',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 235, 109, 109),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isEditable,
    VoidCallback onPressed,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            enabled: isEditable,
            style: GoogleFonts.podkova(
              textStyle: TextStyle(fontSize: 25),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 253, 239, 252),
          ),
          child: Text(
            'Edit',
            style: GoogleFonts.podkova(
              textStyle: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 235, 109, 109),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
