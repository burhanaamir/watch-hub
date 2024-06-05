import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'product_detail.dart';

class StorePage extends StatefulWidget {
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String uEmail = "";
  String searchQuery = "";
  String sortOption = "None";

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

  void sortProducts(List<DocumentSnapshot> products) {
    if (sortOption == "Price: Low to High") {
      products.sort((a, b) => double.parse(a['price']).compareTo(double.parse(b['price'])));
    } else if (sortOption == "Price: High to Low") {
      products.sort((a, b) => double.parse(b['price']).compareTo(double.parse(a['price'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: sortOption,
              onChanged: (String? newValue) {
                setState(() {
                  sortOption = newValue!;
                });
              },
              items: <String>['None', 'Price: Low to High', 'Price: High to Low']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("product").snapshots(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!.docs.where((doc) => doc["name"].toString().toLowerCase().contains(searchQuery)).toList();
                  sortProducts(data);
                  var dataLength = data.length;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 180 / 380,
                      ),
                      itemCount: dataLength,
                      itemBuilder: (context, index) {
                        String productImage = data[index]["image"];
                        String productName = data[index]["name"];
                        String productPrice = data[index]["price"];
                        String productID = data[index]["id"];
                        String productL = data[index]["ldes"];
                        String productS = data[index]["sdes"];
                        String productColor = data[index]["Color"];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(productID: productID),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(productImage),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productName,
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "\$$productPrice",
                                    style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          String wishlistID = Uuid().v1();
                                          await FirebaseFirestore.instance.collection('Wishlist').doc(wishlistID).set({
                                            "id": wishlistID,
                                            "email": uEmail,
                                            'name': productName,
                                            'price': productPrice,
                                            'sdes': productS,
                                            'ldes': productL,
                                            'Color': productColor,
                                            'image': productImage,
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('Added to wishlist'),
                                          ));
                                        },
                                        child: Text('Wishlist'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.orange,
                                          textStyle: TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          String cartID = Uuid().v1();
                                          await FirebaseFirestore.instance.collection('Cart').doc(cartID).set({
                                            "id": cartID,
                                            "email": uEmail,
                                            'name': productName,
                                            'price': productPrice,
                                            'sdes': productS,
                                            'ldes': productL,
                                            'Color': productColor,
                                            'image': productImage,
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('Added to cart'),
                                          ));
                                        },
                                        child: Text('Add to Cart'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.blue,
                                          textStyle: TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Icon(Icons.error_outline);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
