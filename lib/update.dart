import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub1/admin_store%20page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Productupdate extends StatefulWidget {
  const Productupdate({
    super.key,
    required this.ID,
    required this.pname,
    required this.pprice,
    required this.psdes,
    required this.pldes,
    required this.color,
    required this.image,
  });

  final String ID;
  final String pname;
  final String pprice;
  final String psdes;
  final String pldes;
  final String color;
  final String image;

  @override
  State<Productupdate> createState() => _ProductupdateState();
}

class _ProductupdateState extends State<Productupdate> {
  final TextEditingController _pnameController = TextEditingController();
  final TextEditingController _ppriceController = TextEditingController();
  final TextEditingController _psdescriptionController = TextEditingController();
  final TextEditingController _pldescriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _image;
  Uint8List? webImage;
  String? imageUrl;

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

  Future<void> addProductwithImage(BuildContext context) async {
    if (webImage != null || _image != null) {
      String uploadPath = "UserImage/${widget.ID}";
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = FirebaseStorage.instance.ref().child(uploadPath).putData(webImage!);
      } else {
        uploadTask = FirebaseStorage.instance.ref().child(uploadPath).putFile(_image!);
      }

      TaskSnapshot taskSnapshot = await uploadTask;
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    Productdata(image: imageUrl ?? widget.image);
  }

  void Productdata({required String image}) async {
    await FirebaseFirestore.instance.collection("product").doc(widget.ID).update({
      'name': _pnameController.text,
      'price': _ppriceController.text,
      'sdes': _psdescriptionController.text,
      'ldes': _pldescriptionController.text,
      'Color': _colorController.text,
      'image': image,
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AStorePage()));
  }

  Future<void> deleteProduct(BuildContext context) async {
    await FirebaseFirestore.instance.collection("product").doc(widget.ID).delete();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AStorePage()));
  }

  @override
  void initState() {
    _pnameController.text = widget.pname;
    _colorController.text = widget.color;
    _psdescriptionController.text = widget.psdes;
    _pldescriptionController.text = widget.pldes;
    _ppriceController.text = widget.pprice;
    super.initState();
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
                onTap: () {
                  _pickImage();
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: webImage != null
                      ? MemoryImage(webImage!)
                      : NetworkImage(widget.image) as ImageProvider,
                  child: webImage == null ? Icon(Icons.add_a_photo) : null,
                ),
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
                  labelText: 'Long description',
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
                onPressed: () {
                  addProductwithImage(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('UPDATE PRODUCT'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  deleteProduct(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  primary: Colors.red,
                ),
                child: Text('DELETE PRODUCT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
