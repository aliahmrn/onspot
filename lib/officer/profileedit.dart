import 'package:flutter/material.dart';
// Import reusable ProfileEditPage
import 'profile.dart'; // Import OfficerProfilePage for navigation

class OfficerProfileEdit extends StatelessWidget {
  const OfficerProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ProfileEditPage(),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildSaveButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // After saving, navigate back to the OfficerProfileScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OfficerProfileScreen()),
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
