import 'package:flutter/material.dart';
import 'sv_profileedit.dart';
import '../login.dart';
import 'sv_navbar.dart';
import '../profile.dart'; // Import the reusable ProfilePage

class SVProfilePage extends StatelessWidget {
  const SVProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ProfilePage(
              name: 'Supervisor Name', // Replace with actual data if needed
              username: 'supervisor.username',
              email: 'supervisor@gmail.com',
              phoneNumber: '0123456789',
            ),
          ),
          _buildButtonSection(context),
        ],
      ),
      bottomNavigationBar: SupervisorBottomNavBar(currentIndex: 4),
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
              MaterialPageRoute(builder: (context) => SVProfileEditPage()),
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
              MaterialPageRoute(builder: (context) => LoginScreen()),
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
