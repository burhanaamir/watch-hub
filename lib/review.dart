import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewRatingPage extends StatefulWidget {
  @override
  _ReviewRatingPageState createState() => _ReviewRatingPageState();
}

class _ReviewRatingPageState extends State<ReviewRatingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  double _rating = 0.0;
  TextEditingController _reviewController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    user = _auth.currentUser;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty || _rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please provide a rating and a review.'),
      ));
      return;
    }

    FirebaseFirestore.instance.collection('reviews').add({
      'userEmail': user?.email,
      'userName': user?.displayName,
      'profileImage': user?.photoURL,
      'rating': _rating,
      'review': _reviewController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Review submitted successfully.'),
    ));

    _reviewController.clear();
    setState(() {
      _rating = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review and Rating'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").where("email", isEqualTo: user?.email).snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            var userData = snapshot.data!.docs.first;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userData["image"]),
                    ),
                    SizedBox(height: 20),
                    Text(
                      userData["name"],
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData["email"],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Review',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitReview,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Icon(Icons.error_outline));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
