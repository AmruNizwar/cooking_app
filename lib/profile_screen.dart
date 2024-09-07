import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'EditProfileScreen.dart'; 

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String? email;
  String? phoneNumber;
  String? displayName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        email = user!.email;
        phoneNumber = userData['phoneNumber'];
        displayName = user!.displayName;
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(300.0),
                      bottomRight: Radius.circular(300.0),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Text(
                          displayName ?? 'User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), 
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            // Your profile image here
                            child: Icon(
                              Icons.person_add,
                              size: 50,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
                height:
                    40), 
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                            onProfileUpdated:
                                _loadUserData, 
                          )),
                );
              },
              child: Text(
                'Edit profile',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: displayName ?? 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      hintText: phoneNumber ?? 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: email ?? 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[100],
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
