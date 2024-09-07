import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure you have this file generated
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';
import 'success_screen.dart'; 
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cook With Me',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false, 
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/chat': (context) => ChatScreen(),
        '/history': (context) => HistoryScreen(),
        '/about': (context) => AboutScreen(),
        '/success': (context) => SuccessScreen(),
      },
    );
  }
}
