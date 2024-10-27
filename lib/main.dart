import 'package:flutter/material.dart';
import 'login.dart'; // Import the login screen
import 'officer/homescreen.dart';
import 'officer/complaint.dart'; // Import the officer complaint screen
import 'officer/complaintdetails.dart'; // Import the complaint details screen

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
        scaffoldBackgroundColor: Colors.white, // Set the default background color to white
      ),
    );
  }
}
