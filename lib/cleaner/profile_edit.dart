import 'package:flutter/material.dart';
import 'profile.dart'; // Import CleanerProfileScreen for navigation

class CleanerProfileEditScreen extends StatelessWidget {
  const CleanerProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Edit Info',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4C7D90), // Keep the blue gradient color
                        Color(0xFFFEF7FF), // Change the white color to #FEF7FF
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFFEF7FF),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFFEF7FF), // Change to #FEF7FF
                        child: Icon(Icons.edit, size: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField('Name', 'Enter your name'),
                const SizedBox(height: 20),
                _buildTextField('Username', 'Enter your username'),
                const SizedBox(height: 20),
                _buildTextField('Email', 'Enter your email'),
                const SizedBox(height: 20),
                _buildTextField('Phone Number', 'Enter your phone number'),
                const SizedBox(height: 20),
                _buildSaveButton(context), // Add the Save button at the bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
            ),
          ],
        ),
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
