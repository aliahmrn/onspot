import 'package:flutter/material.dart';
import '../profileedit.dart'; // Import reusable ProfileEditPage
import 'cleaner_profile.dart'; // Import CleanerProfileScreen for navigation

class CleanerProfileEditPage extends StatelessWidget {
  const CleanerProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ProfileEditPage(), // Reuse ProfileEditPage
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildSaveButton(context), // Add the Save button
          ),
        ],
      ),
    );
  }

  // Save button widget
  Widget _buildSaveButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // After saving, navigate back to the CleanerProfileScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CleanerProfileScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          minimumSize: const Size(250, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        child: const Text(
          'Save',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
