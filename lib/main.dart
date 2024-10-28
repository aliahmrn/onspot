import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'supervisor/homescreen.dart'; // Import the supervisor home screen
import 'package:google_fonts/google_fonts.dart'; 

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
        '/supervisor-home': (context) =>  SupervisorHomeScreen(), // Protect the Supervisor home route
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Set the default background color to white
         textTheme: GoogleFonts.openSansTextTheme(),
      ),
    );
  }
}
