import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/loadscreen.png'), 
            fit: BoxFit.cover, 
          ),
        ),
      ),
    );
  }
}
