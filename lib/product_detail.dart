import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productID});

  final String productID;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
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
        title: Text('Product Detail'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("product").where('id', isEqualTo: widget.productID).snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!.docs.first;

            String pName = data["name"];
            String pShortDesc = data["sdes"];
            String pLongDesc = data["ldes"];
            String pPrice = data["price"];
            String pID = data["id"];
            String pImage = data["image"];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(pImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pName,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              pShortDesc,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '\$$pPrice',
                              style: TextStyle(
                                fontSize: 22.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      pLongDesc,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      String cartID = Uuid().v1();
                      await FirebaseFirestore.instance.collection('Cart').doc(cartID).set({
                        "id": cartID,
                        "email": uEmail,
                        'name': pName,
                        'price': pPrice,
                        'sdes': pShortDesc,
                        'ldes': pLongDesc,
                        'Color': data["Color"],
                        'image': pImage,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Added to cart'),
                      ));
                    },
                    child: Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      primary: Colors.blue,
                      textStyle: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Icon(Icons.error_outline);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}