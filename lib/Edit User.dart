import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  Uint8List? webImage;
  String? imageUrl;
  User? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (!userDoc.exists) {
        throw Exception('User data not found in Firestore');
      }

      setState(() {
        _nameController.text = userDoc['name'] ?? '';
        _genderController.text = userDoc['gender'] ?? '';
        _ageController.text = userDoc['age'] ?? '';
        _locationController.text = userDoc['location'] ?? '';
        imageUrl = userDoc['image'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (kIsWeb) {
      if (pickedFile != null) {
        var convertedFile = await pickedFile.readAsBytes();
        setState(() {
          webImage = convertedFile;
        });
      }
    } else {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> updateProfileWithImage(BuildContext context) async {
    try {
      if (webImage != null || _image != null) {
        String uploadPath = "UserImage/${user!.uid}";
        UploadTask uploadTask;

        if (kIsWeb) {
          uploadTask = FirebaseStorage.instance.ref().child(uploadPath).putData(webImage!);
        } else {
          uploadTask = FirebaseStorage.instance.ref().child(uploadPath).putFile(_image!);
        }

        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      updateUserProfile(imageUrl ?? '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  void updateUserProfile(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        'name': _nameController.text,
        'gender': _genderController.text,
        'age': _ageController.text,
        'location': _locationController.text,
        'image': imageUrl,
      });
      Navigator.pop(context); // Go back to the previous screen after update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: webImage != null
                      ? MemoryImage(webImage!) as ImageProvider
                      : (imageUrl != null ? NetworkImage(imageUrl!) : null),
                  child: webImage == null && imageUrl == null ? Icon(Icons.add_a_photo) : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateProfileWithImage(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
