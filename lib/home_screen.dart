import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.4:5000/api/random_recipes?count=20'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          recipes = json.decode(response.body);
        });
        print('Recipes fetched successfully: $recipes');
      } else {
        // Print more detailed error information
        print('Failed to load recipes: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  icon: Icon(Icons.chat_bubble, color: Colors.black),
                  label: Text(
                    'COME CHAT WITH ME',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[100],
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30),
                  Text(
                    'TRENDING',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  if (recipes.isEmpty) Text('No recipes available.'),
                  ...recipes
                      .map((recipe) => _buildTrendingItem(context, recipe))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingItem(BuildContext context, dynamic recipe) {
    // Safely access the 'Images' field
    String imagesField =
        recipe['Images'] ?? ''; // Default to an empty string if null

    // Check if the imagesField is not empty before attempting to split
    List<String> imageUrls =
        imagesField.isNotEmpty ? imagesField.split(',https://') : [];

    // Safely access the first image URL or use a placeholder if not available
    String firstImageUrl = imageUrls.isNotEmpty ? imageUrls[0].trim() : '';

    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: Image.network(
          firstImageUrl.isNotEmpty ? firstImageUrl : 'assets/placeholder.jpg',
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $firstImageUrl'); // Debugging line
            return Image.asset('assets/placeholder.jpg', width: 50, height: 50);
          },
        ),
        title: Text(recipe['Name'] ?? 'Recipe Name'),
        subtitle: Text(
          recipe['Description'] ?? 'No description available.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
