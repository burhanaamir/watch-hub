import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:watch_hub1/admin_store%20page.dart';
import 'package:watch_hub1/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Productadd extends StatefulWidget {
  const Productadd({super.key});




  @override
  State<Productadd> createState() => _ProductaddState();
}

class _ProductaddState extends State<Productadd> {

  final TextEditingController _pnameController = TextEditingController();
  final TextEditingController _ppriceController = TextEditingController();
  final TextEditingController _psdescriptionController = TextEditingController();
  final TextEditingController _pldescriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _image;

  Uint8List? webImage;

  Future<void> _pickImage() async {
    if(kIsWeb){
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        var convertedFile = await pickedFile.readAsBytes();

        setState(() {
          webImage = convertedFile;
        });
      }

    }
    else{
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  void addProductwithImage(BuildContext context)async{
    String userID = Uuid().v1();

    if(kIsWeb){
      UploadTask uploadTask = FirebaseStorage.instance.ref().child("UserImage").child(userID).putData(webImage!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      addProduct(userID, imageUrl, context);
    }
    else{
      UploadTask uploadTask = FirebaseStorage.instance.ref().child("UserImage").child(userID).putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      addProduct(userID, imageUrl, context);
    }
  }

  void addProduct(String userID, String imageUrl, BuildContext context) async {


    await _firestore.collection('product').doc(userID).set({
      "id" : userID,
      'name': _pnameController.text,
      'price': _ppriceController,
      'sdes': _psdescriptionController.text,
      'ldes': _pldescriptionController.text,
      'Color': _colorController.text,
      'image': imageUrl,
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => AStorePage(),));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  _pickImage();
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: webImage != null ? MemoryImage(webImage!) : null, // Replace with your logo
                  child: webImage == null ? Icon(Icons.add_a_photo) : null,
                )
              ),
              SizedBox(height: 20),
              TextField(
                controller: _pnameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _ppriceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.price_check_sharp),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _psdescriptionController,
                decoration: InputDecoration(
                  labelText: 'Short description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _pldescriptionController,
                decoration: InputDecoration(
                  labelText: 'long description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message_outlined),
                ),
                obscureText: false,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
                obscureText: false,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  addProductwithImage(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Add Product'),
              ),

            ],
          ),
        ),
      ),
    );


  }
}
