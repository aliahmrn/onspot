import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'protected_route.dart'; // Import your ProtectedRoute
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Set the initial route to the login screen
        '/officer-home': (context) => ProtectedRoute(child: OfficerHomeScreen()), // Protect the Officer home route
      },
    );
  }
}
