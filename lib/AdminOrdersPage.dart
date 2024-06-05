import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatefulWidget {
  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final List<String> _statuses = ['In Process', 'In Transit', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Orders'),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var orders = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var orderData = order.data() as Map<String, dynamic>;
                var productList = orderData['items'] as List<dynamic>;
                String orderStatus = orderData['status'] ?? 'In Process';
                String orderId = order.id;

                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: $orderId',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Customer Email: ${orderData['email']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Status:',
                          style: TextStyle(fontSize: 16),
                        ),
                        DropdownButton<String>(
                          value: _statuses.contains(orderStatus) ? orderStatus : null,
                          onChanged: (String? newValue) async {
                            await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
                              'status': newValue,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Order status updated to $newValue'),
                            ));
                          },
                          items: _statuses
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          hint: Text('Update Status'),
                          isExpanded: true,
                          underline: Container(
                            height: 1,
                            color: Colors.blueGrey,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Products:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: productList.map((product) {
                            return ListTile(
                              leading: Image.network(product['image'], width: 50, height: 50),
                              title: Text(product['name']),
                              subtitle: Text('\$${product['price']} x ${product['quantity']}'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
