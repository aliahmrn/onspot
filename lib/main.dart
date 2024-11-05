import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'officer/homescreen.dart';
import 'officer/complaint.dart'; // Import the officer complaint screen
import 'officer/complaintdetails.dart'; // Import the complaint details screen
import 'package:google_fonts/google_fonts.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == '/complaint-details') {
          final args = settings.arguments as Map<String, dynamic>;
          final complaintId = args['complaintId'];

          return MaterialPageRoute(
            builder: (context) => ComplaintDetailsPage(complaintId: complaintId),
          );
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/officer-home':
            return MaterialPageRoute(builder: (context) => OfficerHomeScreen());
          case '/file-complaint':
            return MaterialPageRoute(builder: (context) => const FileComplaintPage());
          default:
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color
        primaryColor: Color(0xFF2E5675),  // Primary color
        colorScheme: ColorScheme(
            primary: Color(0xFF2E5675), //card annd 
            secondary: Colors.white, // appbar and navbar CFE0F5
            tertiary: Color.fromARGB(255, 183, 211, 233), // Additional accent color for less prominent elements
            surface: Color(0xFFE0E0E0), // Surface color for cards, dialogs, and other containers
            error: Color(0xFFB00020),  // Color for error messages and indicators
            onPrimary: Colors.white, // Text/icon color on top of primary colo         r (e.g., AppBar text)
            onSecondary: Colors.black, // Text/icon color on top of secondary color
            onTertiary: Color(0xFF000000),  // Text/icon color on top of tertiary color
            onSurface: Color(0xFF000000), // Text/icon color on top of the surface color
            onError: Color(0xFFFFFFFF), // Text/icon color on top of the error color
            outline: Color(0xFF737373), // Color for outlines or borders (e.g., input fields)
            shadow: Color(0x29000000), // Shadow color for elevation effects
            brightness: Brightness.light, // light or dark mode
          ),
        textTheme: GoogleFonts.robotoTextTheme(), 
      ),
    );
  }
}
