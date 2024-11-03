import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:pinput/pinput.dart';
import '../HomePage/HomePage.dart';
import '../Register/RegisterPage.dart';

class Verify extends StatefulWidget {
  final String verificationid;

  Verify({Key? key, required this.verificationid}) : super(key: key);

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  TextEditingController OtpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkRegistrationStatus();
  }

  Future<void> checkRegistrationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if the user is signed in with phone authentication
      bool isPhoneAuthUser = user.providerData.any((provider) => provider.providerId == 'phone');
      if (isPhoneAuthUser) {
        // If the user is signed in with phone authentication, navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // If the user is not signed in with phone authentication, navigate to the register page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      }
    }
  }

  Future<bool> registerUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users1').doc(userId).get();
      return snapshot.exists;
    } catch (error) {
      print('Error checking user registration: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Images/img2.png',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                showCursor: true,
                onCompleted: (pin) => print(pin),
                controller: OtpController,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      PhoneAuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: widget.verificationid,
                        smsCode: OtpController.text.toString(),
                      );

                      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

                      bool isRegistered = await registerUser(userCredential.user!.uid);

                      if (isRegistered) {
                        // If the user is registered, navigate to the home page
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                      } else {
                        // If the user is not registered, navigate to the registration page
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                      }
                    } catch (ex) {
                      log(ex.toString());
                    }
                  },
                  child: Text('VERIFY OTP'),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'phone',
                            (route) => false,
                      );
                    },
                    child: Text(
                      "Edit Phone Number ?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
