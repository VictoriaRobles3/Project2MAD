import 'dart:io';
import 'package:artfolio/addNewPost.dart';
import 'package:artfolio/detailPosts.dart';
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
  List<Map<String, dynamic>> _posts = [];

  String imageURL = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchUserData();
    _fetchPosts();
  }

  void _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
    }
  }

  Future<void> _fetchPosts() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('posts')
        .orderBy('timeOfPost', descending: true)
        .get();

    setState(() {
      _posts = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    });
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      final senderName = userDoc.get('firstName') + ' ' + userDoc.get('lastName');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .collection('friendRequests')
          .add({
        'senderId': _currentUser!.uid,
        'senderName': senderName,
        'receiverId': receiverId,
        'status': 'pending',
        'timeOfRequest': FieldValue.serverTimestamp(),
      });

      print('Friend request sent successfully!');
    } catch (e) {
      print('Error sending friend request: $e');
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

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('posts')
          .doc(postId)
          .delete();

      await _fetchPosts();
    } catch (e) {
      print('Error deleting post: $e');
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
      setState(() {});
      print('Profile picture uploaded and URL saved to database successfully!');
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
  }

  Future<void> _showDeleteConfirmation(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _deletePost(postId);
    }
  }
  
  /*

  Widget _buildUserListItem(DocumentSnapshot document){
  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
  if(_auth.currentUser!.uid != document.id){
    return ListTile(
      title: Text(data['email'].toString()),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(
          receiverUserEmail: data['email'].toString(),
          receiverUserID: document.id,
        ),));
      },
    );
  } else {
    return Container();
  }
}



Widget _buildUserList(){
  return SingleChildScrollView(
    child: Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Text("Error");
            }
            if(snapshot.connectionState == ConnectionState.waiting){
              return Text("loading...");
            }
            return ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs.map<Widget>((doc) => _buildUserListItem(doc)).toList(),
            );
          }
        ),
      ],
    ),
  );
}

*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
        /*  IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context){
                  return _buildUserList();
                }
             /* Navigator.push(
                context,
               // MaterialPageRoute(builder: (context) => FriendRequestPage()),
                MaterialPageRoute(builder: (context) => seeUsersPage()),

              ); */
              
              );
            },
            icon: Icon(Icons.person_sharp),
          ), */
        ],
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
                      Expanded(
                        child: Column(
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
                      ),
                      SizedBox(width: 20),
                    /*  IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () {
                          _sendFriendRequest(_currentUser!.uid);
                        },
                      ), */
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
                    child: Text('Update Profile Picture', style: TextStyle(color:Theme.of(context).colorScheme.onSurface),),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPostsPage(postDetails: post, userFirstName: '${post['firstName']}',userLastName: '${post['lastName']}', postId: '${post['id']}',),
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
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            _showDeleteConfirmation(post['id']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : _currentUser != null
              ? Center(child: CircularProgressIndicator())
              : Text(''),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewPost()),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
