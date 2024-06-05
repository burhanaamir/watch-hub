import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
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
        title: Text('Order History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Orders').where('email', isEqualTo: uEmail).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var orderItems = snapshot.data!.docs;

            if (orderItems.isEmpty) {
              return Center(
                child: Text('No order history'),
              );
            }

            return ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                var order = orderItems[index];
                var items = List.from(order['items']);
                String orderStatus = order['status'];

                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.id}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Shipping Address: ${order['address']}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Phone Number: ${order['phone']}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Status: $orderStatus',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Image.network(item['image'], height: 50, width: 50, fit: BoxFit.cover),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '\$${item['price']}',
                                    style: TextStyle(fontSize: 14, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )).toList(),
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
