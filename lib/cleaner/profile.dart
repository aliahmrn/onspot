import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import your AuthService
import 'profile_edit.dart'; // Import CleanerProfileEditPage
import 'navbar.dart'; // Import CleanerBottomNavBar

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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFEF7FF), // Change background color to #fef7ff
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4C7D90),
                    Color(0xFFFEF7FF),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cleaner Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'cleaner.username',
                  style: TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                ),
                const SizedBox(height: 40),
                _buildTextField('Email', 'cleaner@gmail.com'),
                const SizedBox(height: 30),
                _buildTextField('Phone Number', '0987654321'),
                const SizedBox(height: 30), // Add some space before buttons
                _buildButtonSection(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CleanerBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: SizedBox(
              width: 300,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
              MaterialPageRoute(builder: (context) => CleanerProfileEditScreen()),
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
            _logout(context); // Call logout method
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

  void _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.logout(); // Call the logout method to clear the token
    Navigator.pushReplacementNamed(context, '/'); // Navigate back to the login screen
  }
}
