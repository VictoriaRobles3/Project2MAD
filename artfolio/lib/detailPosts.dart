import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPostsPage extends StatefulWidget {
  final Map<String, dynamic> postDetails;
  final String userFirstName;
  final String userLastName;
  final String postId;

  DetailPostsPage({
    required this.postDetails,
    required this.userFirstName,
    required this.userLastName,
    required this.postId,
  });

  @override
  _DetailPostsPageState createState() => _DetailPostsPageState();
}

class _DetailPostsPageState extends State<DetailPostsPage> {
  final _commentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
    User? _currentUser;


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

    void _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print('ERROR, null user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Image.network(
                widget.postDetails['postURL'],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${widget.postDetails['firstName']} ${widget.postDetails['lastName']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.postDetails['description'],
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Posted on: ${DateFormat('yyyy-MM-dd HH:mm').format((widget.postDetails['timeOfPost'] as Timestamp).toDate())}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Leave a comment...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
  child: StreamBuilder<QuerySnapshot>(
  stream: _firestore
    .collection('users')
    .doc(_currentUser!.uid)
    .collection('posts')
    .doc(widget.postId)
    .collection('comments')
    .orderBy('timeOfComment', descending: true)
    .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (snapshot.data == null) {
      return Center(child: Text('Loading...'));
    } else if (snapshot.data!.docs.isEmpty){
      return Center(child: Text('No comments yet.'));
    } else {
      print('Comments Snapshot: ${snapshot.data!.docs}');
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final comment = snapshot.data!.docs[index];
          final firstName = comment['firstName'];
          final lastName = comment['lastName'];
          return ListTile(
            title: Text(
              '$firstName $lastName',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,),
            ),
            subtitle: Text(comment['comment'], style: TextStyle(fontSize: 18,),),
            trailing: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(
                (comment['timeOfComment'] as Timestamp).toDate(),
              ),
            ),
          );
        },
      );
    }
  },
),

),
          ],
        ),
      ),
    );
  }

  void _postComment() async {
    final user = _auth.currentUser;
    if (user != null) {
      final comment = _commentController.text.trim();
      if (comment.isNotEmpty) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        final firstName = userData?['firstName'] ?? '';
        final lastName = userData?['lastName'] ?? '';

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .add({
          'comment': comment,
          'firstName': firstName,
          'lastName': lastName,
          'timeOfComment': FieldValue.serverTimestamp(),
        });
        _commentController.clear();
      }
    }
  }
}
