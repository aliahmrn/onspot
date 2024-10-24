import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'supervisor/homescreen.dart'; // Import the officer home screen

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
        '/': (context) => const LoginScreen(), // Set the initial route to the login screen
         '/supervisor-home': (context) => SupervisorHomeScreen(), // Protect the Supervisor home route
      },
    );
  }
}
