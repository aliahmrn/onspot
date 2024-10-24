import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'officer/homescreen.dart';
import 'officer/complaint.dart'; // Import the officer home screen
import 'officer/complaintdetails.dart'; // Import the officer home screen


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
         '/file-complaint': (context) => const FileComplaintPage(), // Define the complaint page route
         '/complaint-details': (context) => ComplaintDetailsPage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Set the default background color to white
      ),
    );
  }
}
