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
          .get(Uri.parse('http://192.168.1.4:5000/api/random_recipes?count=10'))
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
        automaticallyImplyLeading: false, // This line removes the back button
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
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Soft shadow color
                    spreadRadius: 2,
                    blurRadius: 8, // Blurry shadow for a smoother effect
                    offset:
                        Offset(0, 3), // Shadow position (slight vertical drop)
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          15.0), // Same soft rounded corners
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                    backgroundColor: Colors.orange[100], // Updated button color
                    elevation:
                        0, // No built-in shadow, since we are using custom shadow
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Spreads content across the button width
                    children: [
                      // Avatar on the left side
                      CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/icon.png'), // Replace with your avatar image path
                        radius: 20, // Larger avatar
                      ),

                      // Button label text at the center
                      Text(
                        'Let\'s Chat',
                        style: TextStyle(
                          color: Colors
                              .black, // Contrast text color for readability on light background
                          fontWeight: FontWeight
                              .w600, // Medium weight for balanced text
                          fontSize: 18, // Bigger text for good readability
                        ),
                      ),

                      // Chat icon on the right side
                      Icon(Icons.chat_bubble_rounded,
                          color: Colors.black,
                          size: 22), // Black icon to match text
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
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
        onTap: () {
          _showRecipeDetailsDialog(context, recipe);
        },
      ),
    );
  }

  void _showRecipeDetailsDialog(BuildContext context, dynamic recipe) {
    // Safely access fields from the recipe
    String recipeName = recipe['Name'] ?? 'Recipe Name';
    String totalTime = recipe['TotalTime'] ?? 'Not available';

    // Check if ingredients are a List or a String
    String ingredients = recipe['RecipeIngredientParts'] is List
        ? recipe['RecipeIngredientParts'].join(', ')
        : recipe['RecipeIngredientParts'] ?? 'Ingredients not available';

    // Replace commas with newline characters and add space after "Ingredients"
    ingredients = ingredients.replaceAll(', ', '\n');

    String imagesField = recipe['Images'] ?? '';
    List<String> imageUrls =
        imagesField.isNotEmpty ? imagesField.split(',https://') : [];
    String firstImageUrl = imageUrls.isNotEmpty ? imageUrls[0].trim() : '';

    // Display dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(recipeName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (firstImageUrl.isNotEmpty)
                Image.network(
                  firstImageUrl,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $firstImageUrl');
                    return Image.asset('assets/placeholder.jpg',
                        width: 100, height: 100);
                  },
                ),
              SizedBox(height: 16),

              // Highlight "Total Time"
              RichText(
                text: TextSpan(
                  text: 'Total Time: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .black, // Ensure it matches the dialog's text color
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: totalTime,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Highlight "Ingredients"
              RichText(
                text: TextSpan(
                  text: 'Ingredients:\n\n', // Add space after "Ingredients"
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ingredients,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // Custom styled button
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                    color: Colors.black), // Text color inside the button
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
