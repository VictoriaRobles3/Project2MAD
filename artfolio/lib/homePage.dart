import 'package:artfolio/chatPage.dart';
import 'package:artfolio/detailBoards.dart';
import 'package:artfolio/detailPosts.dart';
import 'package:artfolio/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _buildUserList();
                },
              );
            },
            icon: Icon(Icons.message_sharp),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuPage()),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('boards').snapshots(),
        builder: (context, boardSnapshot) {
          if (boardSnapshot.hasError) {
            return Center(
              child: Text('Error: ${boardSnapshot.error}'),
            );
          }

          if (boardSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final boards = boardSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .collection('posts')
                .orderBy('timeOfPost', descending: true)
                .snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${postSnapshot.error}'),
                );
              }

              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final posts = postSnapshot.data!.docs;

              return ListView.builder(
                itemCount: boards.length + posts.length,
                itemBuilder: (context, index) {
                  if (index < boards.length) {
                    final board = boards[index];
                    final boardURL = board.get('boardURL');
                    final description = board.get('description');
                    final firstName = board.get('Fname');
                    final lastName = board.get('Lname');
                    final timeOfBoard = board.get('timeOfBoard');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBoardsPage(
                              boardDetails: {
                                'boardURL': boardURL,
                                'Fname': firstName,
                                'Lname': lastName,
                                'description': description,
                                'timeOfBoard': timeOfBoard,
                              },
                              boardId: board.id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: Image.network(
                                  boardURL,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '$firstName $lastName',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(description),
                              SizedBox(height: 8),
                              if (timeOfBoard != null)
                                Text(
                                  'Posted at: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timeOfBoard.toDate())}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    final post = posts[index - boards.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPostsPage(
                                    postDetails: post.data() as Map<String, dynamic>,
                                    userFirstName: '${post['firstName']}',
                                    userLastName: '${post['lastName']}',
                                    postId: post.id,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Image.network(
                                    post['postURL'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${post['firstName']} ${post['lastName']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(post['description']),
                                          SizedBox(height: 4),
                                          Text(
                                            DateFormat('yyyy-MM-dd HH:mm').format((post['timeOfPost'] as Timestamp).toDate()),
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  /*  IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteConfirmation(post.id);
                                      },
                                    ), */
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
     /* floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddBoard()),
            );
          },
          child: Icon(Icons.add),
        ),
      ), */
    );
  }

  

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    if (_auth.currentUser!.uid != document.id) {
      return ListTile(
        title: Text(data['email'].toString()),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: data['email'].toString(),
                receiverUserID: document.id,
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget _buildUserList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Error");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("loading...");
              }
              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map<Widget>((doc) => _buildUserListItem(doc)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBoard(String boardId) async {
    try {
      await FirebaseFirestore.instance.collection('boards').doc(boardId).delete();
    } catch (e) {
      print('Error deleting board: $e');
    }
  }
}
