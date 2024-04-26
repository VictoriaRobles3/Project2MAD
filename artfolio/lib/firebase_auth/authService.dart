import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthenticationService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<User?> registerUser(String email, String password, String firstName,
      String lastName, DateTime selectedDateOfBirth,) async {

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);


      Timestamp dateOfBirthTimeStamp = Timestamp.fromDate(selectedDateOfBirth);
      await _usersCollection.doc(credential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'registrationDatetime': Timestamp.now(),
        'dob': dateOfBirthTimeStamp,
        'uid' : credential.user!.uid,
        'email': email,
      });

      return credential.user;
    } catch (e) {
      print("Error in user registration process: $e");
      return null;
    }
  }

  Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
          _usersCollection.doc(credential.user!.uid).set({
            'uid': credential.user!.uid,
            'email': email,
          }, SetOptions(merge: true));
      return credential.user;
    } catch (e) {
      print("Error in user sign in process: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
