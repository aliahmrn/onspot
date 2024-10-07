import 'package:flutter/material.dart';
import '../login.dart';
import 'cleaner_profileedit.dart'; // Import CleanerProfileEditPage
import 'cleaner_navbar.dart'; // Import CleanerBottomNavBar
import '../profile.dart'; // Import the reusable ProfilePage

class CleanerProfileScreen extends StatelessWidget {
  const CleanerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF), // Set AppBar color to #fef7ff
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ProfilePage(
              name: 'Cleaner Name',
              username: 'cleaner.username',
              email: 'cleaner@gmail.com',
              phoneNumber: '0987654321',
              // No buttons here, handled below
            ),
          ),
          _buildButtonSection(context),
        ],
      ),
      bottomNavigationBar: CleanerBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CleanerProfileEditPage()),
            );
          },
          icon: const Icon(Icons.edit, color: Colors.black),
          label: const Text(
            'Edit Information',
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEF7FF), // Set button background color to #fef7ff
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
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEF7FF), // Set button background color to #fef7ff
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
