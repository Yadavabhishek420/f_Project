import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../EditProfile/EditProfile.dart';
import '../PhoneAuth/PhoneAuth.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userId = '';
  String userData = '';
  String name = '';
  String email = '';
  String gender = '';
  String address = '';
  String imageUrl = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchCurrentUserData();
  }

  Future<void> fetchCurrentUserData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        userData = 'User not logged in';
      });
      return;
    }

    // Retrieve user data from Firestore
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users1').doc(user.uid).get();

      if (snapshot.exists) {
        // Access the user data
        Map<String, dynamic> data = snapshot.data()!;

        // Retrieve name, email, gender, address, and imageUrl
        setState(() {
          name = data['userName'];
          email = data['email'];
          gender = data['gender'];
          address = data['address'];
          imageUrl = data['imageUrl'];
        });
      } else {
        setState(() {
          userData = 'User document not found for UID: ${user.uid}';
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        userData = 'Error fetching user data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 200),
        child: Column(
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 70.0),
                          Text('Name: $name', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.cyan),),
                          Text('Email: $email', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.cyan),),
                          Text('Gender: $gender', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.cyan),),
                          Text('Address: $address', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.cyan),),
                          const SizedBox(height: 60.0),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -60,
                    left: 120,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: 100, // Set the height of the DrawerHeader
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white),
                    SizedBox(width: 20),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("EditProfile"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(
                      initialName: name,
                      initialEmail: email,
                      initialgender: gender,
                      initialaddress: address,
                      initialImageUrl: imageUrl,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Logout"),
                      content: Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Close the alert dialog
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform logout operation
                            FirebaseAuth.instance.signOut();
                            // Close the alert dialog
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneAuth(),));
                          },
                          child: Text("Logout"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
