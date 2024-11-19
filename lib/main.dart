import 'package:flutter/material.dart';
import 'login.dart';
import 'cleaner/homescreen.dart'; // Import the cleaner home screen
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/cleaner-home': (context) => CleanerHomeScreen(), // Protect the Cleaner home route
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color
        primaryColor: Color(0xFF2E5675), // Primary color (AppBar, Buttons, etc.)
        colorScheme: ColorScheme(
          primary: Color(0xFF2E5675), // Card and button backgrounds
          secondary: Colors.white, // AppBar, Navbar background
          tertiary: Color.fromARGB(255, 183, 211, 233), // Accent color for less prominent elements
          surface: Color(0xFFE0E0E0), // Surface color for cards, dialogs, etc.
          error: Color(0xFFB00020), // Color for error messages and indicators
          onPrimary: Colors.white, // Text/icon color on top of primary color (e.g., AppBar text)
          onSecondary: Colors.black, // Text/icon color on top of secondary color (AppBar buttons)
          onTertiary: Color(0xFF000000), // Text/icon color on top of tertiary color
          onSurface: Color(0xFF000000), // Text/icon color on top of surface color
          onError: Color(0xFFFFFFFF), // Text/icon color on top of error color
          outline: Color(0xFF737373), // Color for outlines or borders (e.g., input fields)
          shadow: Color(0x29000000), // Shadow color for elevation effects
          brightness: Brightness.light, // Light mode theme
        ),
        textTheme: GoogleFonts.robotoTextTheme(), // Apply Roboto font
      ),
    );
  }
}
