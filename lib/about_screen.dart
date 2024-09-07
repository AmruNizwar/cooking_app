import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            IconButton(
              icon: Icon(Icons.history, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
            IconButton(
              icon: Icon(Icons.info, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Cook with AI",
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Cook with AI is an innovative cooking assistant designed to make your kitchen experience easier and more enjoyable. Our app utilizes artificial intelligence to provide personalized recipe suggestions based on the ingredients you already have at home. Whether you're dealing with a fully stocked pantry or just a few leftover items, Cook with AI is here to help you create something delicious.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "Voice-Activated Experience",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "With built-in voice-to-text and text-to-voice features, Cook with AI offers a truly hands-free cooking experience. You can simply speak your requests, and the app will understand and respond, guiding you through the recipe step by step without needing to touch your device. This makes it perfect for busy cooks who need to keep their hands free.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "Customizable Recipes and Nutritional Information",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Not only does Cook with AI help you find recipes based on the ingredients you have, but it also provides detailed cooking times and nutritional information. Whether you're looking for something quick, trying to stick to a diet, or just curious about the health benefits of your meal, the app delivers all the information you need to make informed decisions.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "Your Culinary Companion",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Our goal is to transform your kitchen into a place of creativity and ease. Cook with AI is designed to simplify your cooking process, reduce food waste by utilizing what’s on hand, and make cooking an enjoyable, stress-free experience. From everyday meals to gourmet dishes, let Cook with AI be your culinary companion.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "Get Cooking Today",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Start using Cook with AI to explore new recipes, save your favorites, and make the most out of every meal. Download our app and see how artificial intelligence can revolutionize the way you cook!",
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
