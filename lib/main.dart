import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../supervisor/main_navigator.dart'; // Import the main navigator
import 'login.dart'; // Import the login screen
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const OnspotSupervisorApp());
}

class OnspotSupervisorApp extends StatelessWidget {
  const OnspotSupervisorApp({super.key});

  // Remove token on app startup to force login screen
  Future<void> _clearTokenOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove token to always show login screen
  }

  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token'); // Check if token exists
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, 
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      routes: {
        '/main-navigator': (context) => const MainNavigator(),
        '/login': (context) => const LoginScreen(),
      },
      home: FutureBuilder(
        future: _clearTokenOnStartup().then((_) => _checkIfLoggedIn()),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Redirect based on authentication status
            return snapshot.data == true ? const MainNavigator() : const LoginScreen();
          }
        },
      ),
    );
  }
}
