import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../HomePage/HomePage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {
  bool isMale = true;
  String selectedGender = 'Male';
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                   image: AssetImage("assets/Images/img_4.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(top: 70, left: 20),
                color: Color(0xFF3b5999).withOpacity(.85),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Welcome to",
                        style: TextStyle(
                          fontSize: 25,
                          letterSpacing: 2,
                          color: Colors.yellow[700],
                        ),
                        children: [
                          TextSpan(
                            text: " Rizona,",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow[700],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Signup to Continue",
                      style: TextStyle(
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 700),
            curve: Curves.bounceInOut,
            top: 200,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 700),
              curve: Curves.bounceInOut,
              height: 390,
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: buildSignupSection(),
              ),
            ),
          ),
          Positioned(
            top: 210,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Choose from gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromGallery();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_camera),
                            title: Text('Take a picture'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromCamera();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.add_a_photo, size: 50, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildSignupSection() {
    return Container(
      margin: EdgeInsets.only(top: 110),
      child: Column(
        children: [
          buildTextField(
            Icons.account_circle_outlined,
            "User Name",
            userNameController,
            false,
            false,
          ),
          SizedBox(height: 10,),
          buildTextField(
            Icons.email_outlined,
            "Email",
            emailController,
            false,
            true,
          ),
          buildGenderField(),
          SizedBox(height: 20),
          buildTextField(
            Icons.location_on_outlined,
            "Address",
            addressController,
            false,
            false,
          ),
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: registerUser,
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMale = true;
                    selectedGender = 'Male';
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isMale ? Colors.black : Colors.transparent,
                        border: Border.all(
                          width: 1,
                          color: isMale ? Colors.black : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.account_circle_outlined,
                        color: isMale ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "Male",
                      style: TextStyle(
                        color: isMale ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMale = false;
                    selectedGender = 'Female';
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isMale ? Colors.transparent : Colors.black,
                        border: Border.all(
                          width: 1,
                          color: isMale ? Colors.grey : Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.account_circle_outlined,
                        color: isMale ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      "Female",
                      style: TextStyle(
                        color: isMale ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
      IconData icon,
      String hintText,
      TextEditingController controller,
      bool isPassword,
      bool isEmail,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  void registerUser() async {
    String userName = userNameController.text.trim();
    String email = emailController.text.trim();
    String address = addressController.text.trim();

    if (userName.isEmpty || email.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields.'),
      ));
      return;
    }

    try {
      var user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      String imageUrl = await _uploadImageToFirebaseStorage(_imageFile!);

      await FirebaseFirestore.instance.collection('users1').doc(user.uid).set({
        'userId': user.uid,
        'userName': userName,
        'email': email,
        'gender': selectedGender,
        'address': address,
        'imageUrl': imageUrl, // Use the imageUrl here
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      print('Error registering user: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed. Please try again.'),
      ));
    }
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final Reference storageRef = FirebaseStorage.instance.ref();
      final Reference imageRef = storageRef.child('usersimages/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(imageFile);
      final String imageUrl = await imageRef.getDownloadURL();
      print('Uploaded image URL: $imageUrl');
      return imageUrl; // Return the download URL
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return ''; // Return empty string in case of error
    }
  }
}
