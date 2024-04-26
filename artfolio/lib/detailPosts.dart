import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPostsPage extends StatelessWidget {
  final Map<String, dynamic> postDetails;

  DetailPostsPage({required this.postDetails});

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
                postDetails['postURL'],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${postDetails['firstName']} ${postDetails['lastName']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              postDetails['description'],
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Posted on: ${DateFormat('yyyy-MM-dd HH:mm').format((postDetails['timeOfPost'] as Timestamp).toDate())}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
