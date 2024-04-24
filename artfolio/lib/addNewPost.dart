import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddNewPost extends StatefulWidget {
  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
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
    // Show an error message if the image or description is missing
    return;
  }

  try {
    // Get the current user's first and last name
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
    final firstName = userDoc.get('firstName');
    final lastName = userDoc.get('lastName');

    // Create a new post document in the "posts" subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('posts')
        .add({
      'postURL': _postImageUrl,
      'description': _descriptionController.text,
      'firstName': firstName,
      'lastName': lastName,
      'timeOfPost': FieldValue.serverTimestamp(),
    });

    // Clear the description input field
    _descriptionController.clear();

    // Navigate back to the previous screen or perform any other desired action
    Navigator.of(context).pop();
  } catch (e) {
    print('Error creating post: $e');
    // Show an error message to the user
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Post'),
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
                hintText: 'Enter post description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              child: Text('Post'),
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
    final storageRef = FirebaseStorage.instance.ref().child('post_images/${_currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}');
    await storageRef.putFile(file);
    _postImageUrl = await storageRef.getDownloadURL();
    setState(() {});
  }
}
}