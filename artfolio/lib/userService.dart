import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> registerUser(String firstName, String lastName, DateTime dateOfBirth) async {
    try {
      await usersCollection.add({
        'firstName': firstName,
        'lastName': lastName,
        'registrationDatetime': Timestamp.now(),
        'dob': Timestamp.fromDate(dateOfBirth),
      });
      print('User registered successfully!');
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  Future<void> updateUserData(String userId, String firstName, String lastName) async {
    try {
      await usersCollection.doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
      });
      print('User data updated successfully!');
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  Future<void> updateDOB(String userId, Timestamp dob) async {
    try {
      await usersCollection.doc(userId).update({
        'dob': dob,
      });
      print('Date of Birth updated successfully!');
    } catch (e) {
      print('Error updating Date of Birth: $e');
      throw e;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String userId) async {
  return await usersCollection.doc(userId).get() as DocumentSnapshot<Map<String, dynamic>>;
}
}
