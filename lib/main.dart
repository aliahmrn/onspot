import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'protected_route.dart'; // Import your ProtectedRoute
import 'supervisor/homescreen.dart'; // Import the supervisor home screen

void main() {
  runApp(const OnspotSupervisorApp());
}

class OnspotSupervisorApp extends StatelessWidget {
  const OnspotSupervisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // Set the initial route to the login screen
        '/supervisor-home': (context) => const ProtectedRoute(child: SupervisorHomeScreen()), // Protect the Supervisor home route
      },
    );
  }
}
