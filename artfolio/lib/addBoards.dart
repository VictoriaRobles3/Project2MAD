import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddBoard extends StatefulWidget {
  @override
  _AddBoardState createState() => _AddBoardState();
}

class _AddBoardState extends State<AddBoard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  final TextEditingController _descriptionController = TextEditingController();

  String? _postImageUrl;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = _auth.currentUser;
  }

  Future<void> _createPost() async {
    if (_postImageUrl == null || _descriptionController.text.isEmpty) {
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      final firstName = userDoc.get('firstName');
      final lastName = userDoc.get('lastName');

      await FirebaseFirestore.instance
          .collection('boards')
          .add({
        'boardURL': _postImageUrl,
        'description': _descriptionController.text,
        'Fname': firstName,
        'Lname': lastName,
        'timeOfBoard': FieldValue.serverTimestamp(),
      });

      _descriptionController.clear();

      Navigator.of(context).pop();
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Board'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: _postImageUrl != null
                  ? Image.network(_postImageUrl!, width: double.infinity, height: 200, fit: BoxFit.cover)
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.add_a_photo, size: 40),
                      ),
                    ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter board description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              child: Text('Post New Board'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('board_images/${_currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}');
      await storageRef.putFile(file);
      _postImageUrl = await storageRef.getDownloadURL();
      setState(() {});
    }
  }
}