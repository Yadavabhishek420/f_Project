import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../HomePage/HomePage.dart';
import '../PhoneAuth/PhoneAuth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check the authentication state and navigate accordingly
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // Delay the navigation slightly to give time for the splash screen to be shown
      Timer(Duration(seconds: 2), () {
        if (user == null) {
          // If user is not authenticated, navigate to Phone Auth Page
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PhoneAuth()));
        } else {
          // If user is authenticated, navigate to Home Page
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // You can replace this with your custom splash screen UI
        ),
        );
    }
}
