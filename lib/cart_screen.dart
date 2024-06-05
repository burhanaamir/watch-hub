import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CheckoutPage.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
        title: Text('Your Cart'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Cart').where('email', isEqualTo: uEmail).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var cartItems = snapshot.data!.docs;

            if (cartItems.isEmpty) {
              return Center(
                child: Text('Your cart is empty', style: Theme.of(context).textTheme.headline6),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
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
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              SizedBox(height: 5),
                              Text(
                                '\$${item['price']}',
                                style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.green),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection('Cart').doc(item.id).delete();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('${item['name']} removed from cart'),
                                  ));
                                },
                                child: Text('Remove from Cart'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckoutPage(uEmail: uEmail)),
                      );
                    },
                    child: Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
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
