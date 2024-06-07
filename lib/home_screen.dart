import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Watch Hub'),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome to Watch Hub⌚',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Let\'s get something awesome and lovely?',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
              ),
              items: [
                'https://via.placeholder.com/600/92c952',
                'https://via.placeholder.com/600/771796',
                'https://via.placeholder.com/600/24f355',
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Image.network(i, fit: BoxFit.cover),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 14, top: 14),
              child: Text(
                "Top Products",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('product').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products available'));
                }
                return Container(
                  width: double.infinity,
                  height: 200,
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      var product = snapshot.data!.docs[index];
                      return ProductContainer(
                        productImage: product['image'] ?? 'https://via.placeholder.com/150',
                        productName: product['name'] ?? 'No Name',
                        productPrice: "\$${product['price'] ?? '0.00'}",
                        productID: product['id'] ?? '',
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 14, top: 14),
              child: Text(
                "Latest Reviews",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reviews').orderBy('timestamp', descending: true).limit(5).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No reviews available'));
                }
                return Container(
                  height: 180,
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      var review = snapshot.data!.docs[index];
                      return ReviewContainer(
                        profileImage: review['profileImage'] ?? 'https://via.placeholder.com/150',
                        userName: review['userName'] ?? 'Anonymous',
                        rating: review['rating']?.toDouble() ?? 0.0,
                        reviewText: review['review'] ?? '',
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductContainer extends StatelessWidget {
  const ProductContainer({
    super.key,
    required this.productImage,
    required this.productName,
    required this.productPrice,
    required this.productID,
  });

  final String productImage;
  final String productName;
  final String productPrice;
  final String productID;

  @override
  Widget build(BuildContext context) {
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
        width: 150,
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
            image: NetworkImage(productImage),
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 14, left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                productName,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
              ),
              Text(
                productPrice,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewContainer extends StatelessWidget {
  const ReviewContainer({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.rating,
    required this.reviewText,
  });

  final String profileImage;
  final String userName;
  final double rating;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profileImage),
              ),
              SizedBox(width: 10),
              Text(
                userName,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              );
            }),
          ),
          SizedBox(height: 10),
          Text(
            reviewText,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
