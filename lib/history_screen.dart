import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> historyItems = [
      {
        'date': '04/1/2023',
        'title': 'Salad',
        'imagePath': 'assets/hi.jpg',
        'description':
            'Straining under the weight of a forgotten grocery list and a grumbling stomach, Sarah haphazardly threw open the pantry door, a whirlwind of spices, forgotten grains, and half-empty jars assaulting her senses. Sunlight, streaming through the window.'
      },
      {
        'date': '04/1/2023',
        'title': 'Salad',
        'imagePath': 'assets/hi.jpg',
        'description':
            'Straining under the weight of a forgotten grocery list and a grumbling stomach, Sarah haphazardly threw open the pantry door, a whirlwind of spices, forgotten grains, and half-empty jars assaulting her senses. Sunlight, streaming through the window.'
      },
      {
        'date': '14/1/2023',
        'title': 'Salad',
        'imagePath': 'assets/hi.jpg',
        'description':
            'Straining under the weight of a forgotten grocery list and a grumbling stomach, Sarah haphazardly threw open the pantry door, a whirlwind of spices, forgotten grains, and half-empty jars assaulting her senses. Sunlight, streaming through the window.'
      },
      {
        'date': '',
        'title': 'Salad',
        'imagePath': 'assets/hi.jpg',
        'description':
            'Straining under the weight of a forgotten grocery list and a grumbling stomach, Sarah haphazardly threw open the pantry door, a whirlwind of spices, forgotten grains, and half-empty jars assaulting her senses. Sunlight, streaming through the window.'
      },
    ];

    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            return _buildHistoryItem(
              context,
              historyItems[index]['date']!,
              historyItems[index]['title']!,
              historyItems[index]['imagePath']!,
              historyItems[index]['description']!,
              index == historyItems.length - 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String date, String title,
      String imagePath, String description, bool isLast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              date,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(imagePath, width: 50, height: 50),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
