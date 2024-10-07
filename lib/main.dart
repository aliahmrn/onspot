import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'protected_route.dart'; // Import your ProtectedRoute
import 'cleaner/cleaner_homescreen.dart'; // Import the cleaner home screen
import 'officer/officer_homescreen.dart'; // Import the officer home screen
import 'supervisor/sv_homescreen.dart'; // Import the supervisor home screen

void main() {
  runApp(OnSpotFacilityApp());
}

class OnSpotFacilityApp extends StatelessWidget {
  const OnSpotFacilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.white, // Set the scaffold background color to white
        // You can also customize other theme properties here
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>
            LoginScreen(), // Set the initial route to the login screen
        '/cleaner-home': (context) => ProtectedRoute(
            child: CleanerHomeScreen()), // Protect the Cleaner home route
        '/officer-home': (context) => ProtectedRoute(
            child: OfficerHomeScreen()), // Protect the Officer home route
        '/supervisor-home': (context) => ProtectedRoute(
            child: SupervisorHomeScreen()), // Protect the Supervisor home route
      },
    );
  }
}
