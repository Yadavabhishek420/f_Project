import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../OtpVerify/OtpVerify.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({Key? key}) : super(key: key);


  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}


class _PhoneAuthState extends State<PhoneAuth> {
  TextEditingController phoneController = TextEditingController();


  @override
  void initState() {
    phoneController.text = "+91";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter your phone number',
                          suffixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),

              SizedBox(
                width: double.infinity,
                height: 45,
                child:  ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      verificationCompleted: (PhoneAuthCredential credential) {},
                      verificationFailed: (FirebaseAuthException ex) {

                      },
                      codeSent: (String verificationId, int? resendToken) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Verify( verificationid: verificationId,)));
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                      phoneNumber: phoneController.text.toString(),
                    );
                  },
                  child: const Text('SEND OTP'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
