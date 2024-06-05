import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CheckoutPage.dart';
import 'package:uuid/uuid.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String uEmail = "";

  Future getCred() async {
    SharedPreferences userCred = await SharedPreferences.getInstance();
    setState(() {
      uEmail = userCred.getString("email") ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    getCred();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Wishlist'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Wishlist').where('email', isEqualTo: uEmail).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var wishlistItems = snapshot.data!.docs;

            if (wishlistItems.isEmpty) {
              return Center(
                child: Text('Your wishlist is empty'),
              );
            }

            return ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                var item = wishlistItems[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(item['image'], height: 200, width: double.infinity, fit: BoxFit.cover),
                        SizedBox(height: 10),
                        Text(
                          item['name'],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${item['price']}',
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('Wishlist').doc(item.id).delete();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${item['name']} removed from wishlist'),
                            ));
                          },
                          child: Text('Remove from Wishlist'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            onPrimary: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String cartID = Uuid().v1();
                            await FirebaseFirestore.instance.collection('Cart').doc(cartID).set({
                              "id": cartID,
                              "email": uEmail,
                              'name': item['name'],
                              'price': item['price'],
                              'sdes': item['sdes'],
                              'ldes': item['ldes'],
                              'Color': item['Color'],
                              'image': item['image'],
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${item['name']} added to cart'),
                            ));
                          },
                          child: Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
