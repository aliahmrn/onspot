import 'package:flutter/material.dart';
import 'login.dart';
import 'cleaner/homescreen.dart'; // Import the cleaner home screen


void main() {
  runApp(OnSpotFacilityApp());
}

class OnSpotFacilityApp extends StatelessWidget {
  const OnSpotFacilityApp({super.key});

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
