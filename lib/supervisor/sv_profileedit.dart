import 'package:flutter/material.dart';
import '../profileedit.dart'; // Import reusable ProfileEditPage
import 'sv_profile.dart'; // Import SVProfilePage for navigation

class SVProfileEditPage extends StatelessWidget {
  const SVProfileEditPage({super.key});

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
            child: _buildSaveButton(context), // Add Save button
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
          // Navigate back to SVProfilePage after saving
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SVProfilePage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
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
