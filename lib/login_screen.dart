import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Image.asset(
              'assets/login.jpg',
              height: 300,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'LOGIN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final username = usernameController.text.trim();
                          final password = passwordController.text.trim();

                          try {

                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                              email: username,
                              password: password,
                            );

                            // Check if user exists in Firestore (optional)
                            DocumentSnapshot userDoc = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(userCredential.user?.uid)
                                .get();
                            if (userDoc.exists) {
                              
                              Navigator.pushNamed(context, '/success');
                            } else {
                              print('User data not found in Firestore');
                              
                            }
                          } catch (e) {
                            
                            print('Error: $e');
                            
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: const Text(
                                    'Failed to login. Please check your credentials and try again.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/registration');
                        },
                        child: const Text(
                          'If you are a new user click here',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
