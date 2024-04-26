import 'package:artfolio/userService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:artfolio/themes/themeProvider.dart';
import 'package:artfolio/splashScreen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();
  final _auth = FirebaseAuth.instance;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _userService.getUserData(user.uid);
      if (userDoc.exists) {
        final firstName = userDoc.get('firstName');
        final lastName = userDoc.get('lastName');
        final dob = userDoc.get('dob');
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
        _dobController.text = DateFormat('yyyy-MM-dd').format(dob.toDate());
        _selectedDate = dob.toDate();
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user != null) {
        await _userService.updateUserData(
          user.uid,
          _firstNameController.text,
          _lastNameController.text,
        );
        if (_selectedDate != null) {
          await _userService.updateDOB(
            user.uid,
            Timestamp.fromDate(_selectedDate!),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User data updated successfully!'),
          ),
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await user.updatePassword(_passwordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password updated successfully!'),
            ),
          );
          _passwordController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating password: $e'),
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                ),
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _updateUserData,
                child: Text('Save Changes', style: TextStyle(color:Theme.of(context).colorScheme.onSurface),),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updatePassword,
                child: Text('Change Password', style: TextStyle(color:Theme.of(context).colorScheme.onSurface),),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<ThemeProvider>(context, listen: false)
              .toggleTheme();
        },
        child: Icon(Icons.brightness_4),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}