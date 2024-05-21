import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:watch_hub1/firebase_options.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

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

  void pageShifter(index){
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> myScreens = [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: myScreens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          currentIndex: currentIndex,
          onTap: pageShifter,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart),label: "Cart"),
            BottomNavigationBarItem(icon: Icon(Icons.contact_mail),label: "Contact"),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile"),
          ]
      ),);

  }
}
