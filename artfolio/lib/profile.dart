import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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

  String imageURL = '';

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
        imageURL = _userData!['profilePictureUrl'] ?? '';

      });
    } else {
      print('User data not found.');
    }
  }

  Future<void> _uploadImage(File file) async {
    String uniqueID = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('profileImages');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueID);

    try {
      await referenceImageToUpload.putFile(file);
      imageURL = await referenceImageToUpload.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({
        'profilePictureUrl': imageURL,
      });
      setState(() {
        
      });
      print('Profile picture uploaded and URL saved to database successfully!');
    } catch (e) {
      print('Error uploading profile picture: $e');
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      imageURL.isNotEmpty ? NetworkImage(imageURL) : null,
                  child: imageURL.isEmpty
                      ? IconButton(
                          icon: Icon(Icons.add_a_photo),
                          onPressed: () async {
                            ImagePicker imagePicker = ImagePicker();
                            XFile? file = await imagePicker.pickImage(
                                source: ImageSource.gallery);
                            print('${file?.path}');

                            if (file == null) return;
                            await _uploadImage(File(file.path));
                          },
                        )
                      : null,
                ),
                SizedBox(width: 20),
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
            ElevatedButton(
              onPressed: () async {
                ImagePicker imagePicker = ImagePicker();
                XFile? file = await imagePicker.pickImage(
                    source: ImageSource.gallery);
                print('${file?.path}');

                if (file == null) return;
                await _uploadImage(File(file.path));
              },
              child: Text('Update Profile Picture'),
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

