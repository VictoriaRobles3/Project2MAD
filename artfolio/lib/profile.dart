import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'userService.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
  }

  void _getCurrentUser() async {
    _currentUser = await _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
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
    try {
      await _userService.updateUserData(
        _currentUser!.uid,
        _firstNameController.text,
        _lastNameController.text,
      );
      _fetchUserData();
      print('User data updated successfully!');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
                ],
              ),
            )
          : _currentUser != null
              ? CircularProgressIndicator()
              : Text(''),
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
