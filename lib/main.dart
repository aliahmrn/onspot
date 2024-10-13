import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'officer/homescreen.dart'; // Import the officer home screen

void main() {
  runApp(const OnspotOfficerApp());
}

class OnspotOfficerApp extends StatelessWidget {
  const OnspotOfficerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial route to the login screen
      routes: {
        '/': (context) => const LoginScreen(), // Set the login screen as the initial route
        '/officer-home': (context) => OfficerHomeScreen(), // Set the Officer home screen route
      },
    );
  }
}
