import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'officer/homescreen.dart';
import 'officer/complaint.dart';
import 'officer/complaintdetails.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: OnspotOfficerApp()));
}

class OnspotOfficerApp extends StatelessWidget {
  const OnspotOfficerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF2E5675),
        colorScheme: const ColorScheme(
          primary: Color(0xFF2E5675),
          secondary: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/complaint-details':
            final args = settings.arguments as Map<String, dynamic>;
            final complaintId = args['complaintId'];
            return MaterialPageRoute(
              builder: (context) => ComplaintDetailsPage(complaintId: complaintId),
            );
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
    );
  }
}
