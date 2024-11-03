import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../HomePage/HomePage.dart';

class EditProfile extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialgender;
  final String initialaddress;
  final String initialImageUrl;

  const EditProfile({
    Key? key,
    required this.initialName,
    required this.initialEmail,
    required this.initialgender,
    required this.initialaddress,
    required this.initialImageUrl,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController genderController;
  late TextEditingController addressController;
  PickedFile? _image;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    emailController = TextEditingController(text: widget.initialEmail);
    genderController = TextEditingController(text: widget.initialgender);
    addressController = TextEditingController(text: widget.initialaddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 20.0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Positioned(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration:  BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: const SingleChildScrollView(),
                    ),
                  ),
                  Positioned(
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
                                    leading:  Icon(Icons.photo_library),
                                    title:  Text('Choose from gallery'),
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
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path)) as ImageProvider<Object>
                            : NetworkImage(widget.initialImageUrl),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 158.0),
                              child: _image == null
                                  ? Icon(Icons.add_a_photo, size: 50, color: Colors.white)
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: genderController,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      // Get the current user
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        try {
                          String imageUrl = widget.initialImageUrl;

                          // Upload image to Firebase Storage if new image selected
                          if (_image != null) {
                            imageUrl = await _updateImageInFirebaseStorage(_image!.path);
                          }

                          // Update user data in Firestore
                          await FirebaseFirestore.instance.collection('users1').doc(user.uid).update({
                            'userName': nameController.text,
                            'email': emailController.text,
                            'gender': genderController.text,
                            'address': addressController.text,
                            'imageUrl': imageUrl, // Update image URL
                          });

                          // Navigate to home page after successful update
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        } catch (error) {
                          // Handle errors
                          print('Error updating user data: $error');
                        }
                      }
                    },
                    child: Text('update',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(160.0, 60.0), backgroundColor: Color(0xFF40487E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = PickedFile(pickedFile.path);
      }
    });
  }


  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = PickedFile(pickedFile.path);
      }
    });
  }


  Future<String> _updateImageInFirebaseStorage(String newFilePath) async {
    try {
      final File newImageFile = File(newFilePath);
      final Reference storageRef = FirebaseStorage.instance.ref();

      // Delete existing image from storage
      await FirebaseStorage.instance.refFromURL(widget.initialImageUrl).delete();

      // Upload new image to storage
      final Reference imageRef = storageRef.child('usersimages/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(newImageFile);

      // Get the updated image URL
      final String newImageUrl = await imageRef.getDownloadURL();
      print('Updated image URL: $newImageUrl');

      // Update user data in Firestore with new image URL
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users1')
            .doc(user.uid)
            .update({'imageUrl': newImageUrl});
      }

      // Return the new image URL
      return newImageUrl;
    } catch (e) {
      print('Error updating image in Firebase Storage: $e');
      return ''; // Return empty string in case of error
    }
  }
}
