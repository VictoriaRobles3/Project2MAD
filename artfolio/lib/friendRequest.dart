import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  List<Map<String, dynamic>> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchFriendRequests();
  }

  void _getCurrentUser() {
    _currentUser = _auth.currentUser;
  }

  Future<void> _fetchFriendRequests() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('friendRequests')
        .orderBy('timeOfRequest', descending: true)
        .get();

    setState(() {
      _friendRequests = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> _acceptFriendRequest(String requestId, String senderId) async {
    try {
      await FirebaseFirestore.instance.collection('friends').add({
        'userId1': _currentUser!.uid,
        'userId2': senderId,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('friendRequests')
          .doc(requestId)
          .update({'status': 'accepted'});

      await _fetchFriendRequests();
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('friendRequests')
          .doc(requestId)
          .update({'status': 'rejected'});

      await _fetchFriendRequests();
    } catch (e) {
      print('Error rejecting friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: _friendRequests.isEmpty
          ? Center(child: Text('No friend requests'))
          : ListView.builder(
              itemCount: _friendRequests.length,
              itemBuilder: (context, index) {
                final request = _friendRequests[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(request['senderName'][0]),
                  ),
                  title: Text(request['senderName']),
                  subtitle: Text(request['message']),
                  trailing: request['status'] == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _acceptFriendRequest(request['id'], request['senderId']);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _rejectFriendRequest(request['id']);
                              },
                            ),
                          ],
                        )
                      : Text(request['status']),
                );
              },
            ),
    );
  }
}