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
                "The familiar pre-lunch grumble resonated in Sarah's stomach, a rude awakening from her spreadsheet labyrinth. A glance at the clock confirmed her worst fear - 1:12 pm. The forgotten grocery list mocked her from the corner of her desk, a crumpled testament to her neglected fridge and dwindling pantry. Despair threatened to drown her, visions of limp lettuce and wilted carrots dancing in her head. Yet, amidst the looming hunger pangs, a flicker of defiance sparked. She wouldn't surrender to the tyranny of the delivery app - not today.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "With a determined pushback from her chair, Sarah marched towards the battleground - the cluttered pantry. Swinging open the door unleashed a chaotic symphony of forgotten treasures. Dusty spice jars jostled for space with half-empty bags of grains and forgotten cans of exotic beans. The air hung heavy with the musky scent of cumin, the sharp bite of ground pepper, and the sweet embrace of cinnamon. A forgotten bag of dried herbs crumbled in her hand, releasing a nostalgic aroma of childhood stews. It was a culinary jungle, teeming with possibilities, if only she could decipher their forgotten language.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "Suddenly, a brilliant sliver of sunlight slashed through the pantry gloom, illuminating a single, perfectly ripe avocado nestled amongst dented cans of soup. Its smooth, emerald skin gleamed like a beacon of hope. Sarah snatched it, the coolness grounding her in the present. It was a simple ingredient, yet it held the key to her culinary rebellion.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "Beside the avocado, a lone can of chickpeas, dented but defiant, stood guard. A grin stretched across Sarah's face. These humble ingredients, combined with a squeeze of lemon from the fridge's citrus drawer, could become something extraordinary. With newfound purpose, she gathered her tools - a well-worn cutting board, a trusty fork, and a mismatched set of ceramic bowls.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "The rhythmic tap of the knife against the cutting board became a battle cry. Sarah halved the avocado, its vibrant green flesh a stark contrast to the brown of the wooden board. As the smooth flesh yielded to the fork, a creamy mash began to form, punctuated by the occasional fleck of black. The air filled with a subtle, buttery aroma, promising riches to come.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "She coaxed uniformity and contrast to the verdant mash. Sarah gleefully smashed and stirred, transforming the simple green into a delicious concoction. The clinking of the fork against the ceramic was a melodic reminder, a testament to her determination to defy the lunch rut.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "With the mashed chickpeas now folded into the avocado, she released a burst of citrus from a lemon, its vibrant green flesh a stark contrast to the brown of the wooden board. As the smooth flesh yielded to the fork, a creamy mash began to form, punctuated by the occasional fleck of black. The air filled with a subtle, buttery aroma, a refreshing contrast to the chaos outside.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                "But the masterpiece wasn’t complete. Sarah’s gaze fell upon a forgotten can of sun-dried tomatoes, their intense red vibrant against the verdant base. Scattered on top, they became a crown, a testament to her culinary.",
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
