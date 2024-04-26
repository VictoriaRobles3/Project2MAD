import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPostsPage extends StatefulWidget {
  final Map<String, dynamic> postDetails;
  final String userFirstName;
  final String userLastName;
  final String postId;

DetailPostsPage({required this.postDetails, required this.userFirstName, required this.userLastName, required this.postId,
});

  @override
  _DetailPostsPageState createState() => _DetailPostsPageState();
}

class _DetailPostsPageState extends State<DetailPostsPage> {
  final _commentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.postDetails['description'],
              style: TextStyle(
                fontSize: 16,
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
    .doc(widget.postDetails['userId'])
    .collection('posts')
    .doc(widget.postId)
    .collection('comments')
    .orderBy('timeOfComment', descending: true)
    .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final comment = snapshot.data!.docs[index];
          final firstName = comment['firstName'];
          final lastName = comment['lastName'];
          return ListTile(
            title: Text(
              '$firstName $lastName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(comment['comment']),
            trailing: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(
                (comment['timeOfComment'] as Timestamp).toDate(),
              ),
            ),
          );
        },
      );
    } else {
      return Center(child: CircularProgressIndicator());
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