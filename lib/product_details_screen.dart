import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String productId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('watches').doc(productId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var document = snapshot.data!;
          return Column(
            children: [
              Image.network(document['image']),
              Text(document['name'], style: TextStyle(fontSize: 24)),
              Text('\$${document['price']}', style: TextStyle(fontSize: 20)),
              Text(document['description']),
              ElevatedButton(
                onPressed: () {
                  // Add to cart functionality
                },
                child: Text('Add to Cart'),
              ),
            ],
          );
        },
      ),
    );
  }
}
