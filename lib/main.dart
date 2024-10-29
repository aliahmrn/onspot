import 'package:flutter/material.dart';
import 'login.dart';
import 'cleaner/homescreen.dart'; // Import the cleaner home screen
import 'package:google_fonts/google_fonts.dart';


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
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white, // Set the default background color to white
            textTheme: GoogleFonts.openSansTextTheme(),
          ),
    );
  }
}
