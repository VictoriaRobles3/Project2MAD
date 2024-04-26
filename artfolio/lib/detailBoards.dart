import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailBoardsPage extends StatelessWidget {
  final Map<String, dynamic> boardDetails;

  DetailBoardsPage({required this.boardDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Board Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Image.network(
                boardDetails['boardURL'],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${boardDetails['Fname']} ${boardDetails['Lname']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              boardDetails['description'],
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Posted at: ${DateFormat('yyyy-MM-dd HH:mm:ss').format((boardDetails['timeOfBoard'] as Timestamp).toDate())}',
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
