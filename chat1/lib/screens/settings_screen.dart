import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _inputController = TextEditingController();
  String _enteredName = '';
  late DocumentSnapshot userProfile;
  final _imagePicker = ImagePicker();
  bool _isImageUpdated = false;
  late PickedFile _image;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  // Fetch user profile from Firestore
  Future<void> _getUserProfile() async {
    final userUID = FirebaseAuth.instance.currentUser!.uid;
    userProfile = await FirebaseFirestore.instance.collection('users').doc(userUID).get();
    _inputController.text = userProfile['username'];
  }

  // Method to pick image from gallery or camera
  void _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 300,
    );
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile as PickedFile;
        _isImageUpdated = true;
      });
    }
  }


  // Update user profile with new data
  Future<void> _updateUserProfile(BuildContext context) async {
    final userDetails = FirebaseAuth.instance.currentUser;
    if (_isImageUpdated) {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('${userDetails!.uid}.jpg');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Updating'),
          content: CircularProgressIndicator(),
        ),
      );
      await ref.putFile(File(_image.path));
      final imageURL = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(userDetails.uid).update({'imageURL': imageURL});
      Navigator.of(context).pop(); // pop AlertDialog
    }
    if (_enteredName.trim().isNotEmpty && userProfile['username'] != _enteredName) {
      await FirebaseFirestore.instance.collection('users').doc(userDetails!.uid).update({'username': _enteredName});
    }
    Navigator.of(context).pop(); // close settings screen
  }

  // Show bottom sheet for selecting image source
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) => SafeArea(
        child: Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Display image based on source
  ImageProvider _displayImage() {
    if (_isImageUpdated) {
      return FileImage(File(_image.path));
    } else if (userProfile['imageURL'] != '') {
      return CachedNetworkImageProvider(userProfile['imageURL']);
    } else {
      return AssetImage('assets/comic.gif');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _buildSettingsBody(context),
    );
  }

  // Widget for settings body
  Widget _buildSettingsBody(BuildContext context) {
    return FutureBuilder(
      future: _getUserProfile(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _displayImage(),
                      child: TextButton.icon(
                        icon: Icon(Icons.image_outlined),
                        label: Text('Add/change'),
                        onPressed: () {
                          _showPicker(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _inputController,
                    maxLength: 50,
                    style: TextStyle(fontSize: 25),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: TextStyle(fontSize: 14),
                      hintText: 'Enter new name',
                      hintStyle: TextStyle(fontSize: 18),
                      icon: Icon(Icons.face_outlined),
                    ),
                    onChanged: (value) => _enteredName = value,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text('Update'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                      onPressed: () => _updateUserProfile(context),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
