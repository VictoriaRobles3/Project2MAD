import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  DocumentSnapshot? _userData;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
    }
  }

  void _fetchUserData() async {
    final DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
    if (docSnapshot.exists) {
      setState(() {
        _userData = docSnapshot;
      });
    } else {
      print('User data not found.');
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Text(
                      'Add Profile Picture',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),

                      Text(
                        '${_userData!['firstName']} ${_userData!['lastName']}',
                        style: GoogleFonts.jetBrainsMono(
                          textStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Birthday: ${DateFormat('dd-MM-yyyy').format((_userData!['dob'] as Timestamp).toDate())}',
                        style: GoogleFonts.jetBrainsMono(
                          textStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'User since: ${DateFormat('dd-MM-yyyy').format((_userData!['registrationDatetime'] as Timestamp).toDate())}',
                        style: GoogleFonts.jetBrainsMono(
                          textStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            )
          : _currentUser != null
              ? Center(child: CircularProgressIndicator())
              : Text(''),
    );
  }
}
