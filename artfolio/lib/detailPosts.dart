import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPostsPage extends StatefulWidget {
  final String postId;

  const DetailPostsPage({required this.postId});

  @override
  _DetailPostsPageState createState() => _DetailPostsPageState();
}

class _DetailPostsPageState extends State<DetailPostsPage> {
  Map<String, dynamic>? _postData;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  Future<void> _fetchPostData() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final postDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('posts')
        .doc(widget.postId)
        .get();

    if (postDoc.exists) {
      final authorId = postDoc.get('authorId');
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .get();

      setState(() {
        _postData = postDoc.data() as Map<String, dynamic>;
        _userName = '${userData['firstName']} ${userData['lastName']}';
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: _postData != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(
                      _postData!['postURL'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _postData!['description'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Posted by: $_userName',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
