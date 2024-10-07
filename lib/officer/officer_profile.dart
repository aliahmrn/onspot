import 'package:flutter/material.dart';
import 'officer_navbar.dart';
import 'officer_profileedit.dart';
import '../profile.dart'; // Import your reusable ProfilePage
import '../login.dart'; // Assuming this is where the LoginScreen is located

class OfficerProfileScreen extends StatelessWidget {
  const OfficerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ProfilePage(
            name: 'Officer Name', // Example name
            username: 'officer123', // Example username
            email: 'officer@example.com', // Example email
            phoneNumber: '0123456789', // Example phone number
          ),
          Positioned(
            bottom: 20, // Position buttons at the bottom
            left: 0,
            right: 0,
            child: _buildButtonSection(context),
          ),
        ],
      ),
      bottomNavigationBar: OfficerNavBar(currentIndex: 3),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Minimize space usage to fit at the bottom
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OfficerProfileEdit()),
            );
          },
          icon: const Icon(Icons.edit, color: Colors.black),
          label: const Text(
            'Edit Information',
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: const Size(250, 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: const Size(250, 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
