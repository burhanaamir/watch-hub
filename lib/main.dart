import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:watch_hub1/Product_add.dart';
import 'package:watch_hub1/firebase_options.dart';
import 'package:watch_hub1/product_detail.dart';
import 'package:watch_hub1/store_page.dart';
import 'package:watch_hub1/update.dart';
import 'AdminOrdersPage.dart';
import 'admin_store page.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'cart_screen.dart';
import 'package:watch_hub1/profile_screen.dart';
import 'wishlist.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class btom extends StatefulWidget {
  const btom({super.key});

  @override
  State<btom> createState() => _btomState();
}

class _btomState extends State<btom> {
  int currentIndex = 0;

  void pageShifter(index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> myScreens = [
    HomeScreen(),
    CartScreen(),
    WishlistScreen(),
    StorePage(),
    ProfilePage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: myScreens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: currentIndex,
        onTap: pageShifter,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Wislist"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Store"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class adminBtom extends StatefulWidget {
  const adminBtom({super.key});

  @override
  State<adminBtom> createState() => _adminBtomState();
}

class _adminBtomState extends State<adminBtom> {
  int currentIndex = 0;

  void pageShifter(index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> adminScreens = [
    AdminOrdersPage(),
    AStorePage(),
    Productadd(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: adminScreens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: currentIndex,
        onTap: pageShifter,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Astore"),
          BottomNavigationBarItem(icon: Icon(Icons.production_quantity_limits_sharp), label: "Product Add"),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Sign in"),
        ],
      ),
    );
  }
}
