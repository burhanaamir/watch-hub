import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub1/product_detail.dart';
import 'package:watch_hub1/update.dart';


class AStorePage extends StatefulWidget {
  @override
  State<AStorePage> createState() => _AStorePageState();
}

class _AStorePageState extends State<AStorePage> {
  String searchQuery = "";

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
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("product").snapshots(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!.docs.where((doc) =>
                      doc["name"].toString().toLowerCase().contains(searchQuery)).toList();
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
                              color: Colors.white,
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
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "\$$productPrice",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Productupdate(
                                            ID: productID,
                                            pname: productName,
                                            pldes: productL,
                                            psdes: productS,
                                            pprice: productPrice,
                                            image: productImage,
                                            color: productColor,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('Edit Product'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.blue,
                                      textStyle: TextStyle(fontSize: 16.0),
                                    ),
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
