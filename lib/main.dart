import 'package:flutter/material.dart';
import 'login.dart';
import 'cleaner/homescreen.dart'; // Import the cleaner home screen


void main() {
  runApp(OnspotCleanerApp());
}

class OnspotCleanerApp extends StatelessWidget {
  const OnspotCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // Set the initial route to the login screen
        '/cleaner-home': (context) =>  CleanerHomeScreen(), // Protect the Cleaner home route
      },
    );
  }
}
