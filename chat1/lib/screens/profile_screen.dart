import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat1/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../../core/themes/color.dart';
import '../../core/themes/constants.dart';
import '../widgets/profile_list_item.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileScreen> {
  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData() async {
    final userDetails = FirebaseAuth.instance.currentUser;
    if (userDetails != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(userDetails.uid)
          .get();
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> _updateProfileImage(File image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('user_images').child('${user.uid}.jpg');
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      // Update image URL in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'imageURL': imageUrl,
      });

      // Refresh the state to reflect the new image
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final image = File(pickedFile.path);
      await _updateProfileImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error fetching user data'));
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: Text('User data not found'));
          }

          final userData = userSnapshot.data!.data();
          if (userData == null) {
            return Center(child: Text('User data is empty'));
          }

          return Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xff304157),
                                  borderRadius: BorderRadius.circular(10)),
                              height: 40,
                              width: 40,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: AvatarImage(imageUrl: userData['imageURL']),
                    ),
                    SizedBox(height: 30),
                    Text(
                      userData['username'],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins"),
                    ),
                    Text(
                      userData['email'],
                      style: TextStyle(
                          fontWeight: FontWeight.w300, fontSize: 15),
                    ),
                    SizedBox(height: 12),
                    ProfileListItems(),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class AvatarImage extends StatelessWidget {
  final String? imageUrl;

  const AvatarImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      padding: EdgeInsets.all(8),
      decoration: avatarDecoration,
      child: Container(
        decoration: avatarDecoration,
        padding: EdgeInsets.all(3),
        child: CircleAvatar(
          radius: 70,
          backgroundImage: imageUrl == null || imageUrl!.isEmpty
              ? AssetImage('assets/image/avatar.png')
              : CachedNetworkImageProvider(imageUrl!),
        ),
      ),
    );
  }
}

class ProfileListItems extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: <Widget>[
          ProfileListItem(
            icon: LineAwesomeIcons.user_shield,
            text: 'Privacy',
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.question_circle,
            text: 'Help & Support',
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.cog,
            text: 'Settings',
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.user_plus,
            text: 'Invite a Friend',
          ),
          GestureDetector(
            onTap: () => _logout(context),
            child: ProfileListItem(
              icon: LineAwesomeIcons.alternate_sign_out,
              text: 'Logout',
              hasNavigation: false,
            ),
          ),
        ],
      ),
    );
  }
}
