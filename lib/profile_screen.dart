import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watch_hub1/login_screen.dart';
import 'Change Password Page.dart';
import 'order_history_page.dart';
import 'Feedback Page.dart';
import 'review.dart';
import 'Edit User.dart';
// Import the new Review and Rating Page

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").where("email",isEqualTo: user?.email).snapshots(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {

              var dataLength = snapshot.data!.docs.length;

              return ListView.builder(
                itemCount: dataLength,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage("${snapshot.data!.docs[index]["image"]}"),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "${snapshot.data!.docs[index]["name"]}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${snapshot.data!.docs[index]["email"]}",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      _buildProfileOption(
                        context,
                        title: 'Order History',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderHistoryPage(),
                            ),
                          );
                        },
                      ),
                      _buildProfileOption(
                        context,
                        title: 'Edit Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildProfileOption(
                        context,
                        title: 'Change Password',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                      _buildProfileOption(
                        context,
                        title: 'Customer support',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedbackPage(),
                            ),
                          );
                        },
                      ),
                      _buildProfileOption(
                        context,
                        title: 'Review and Rating',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewRatingPage(),
                            ),
                          );
                        },
                      ),
                      _buildProfileOption(
                        context,
                        title: 'Sign Out',
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen(),));
                        },
                      ),
                    ],
                  );
                },);
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}
