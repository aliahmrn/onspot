import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import for secure storage
import 'navbar.dart';
import 'profileedit.dart';
import '../profile.dart'; // Import your reusable ProfilePage
import '../login.dart'; // Assuming this is where the LoginScreen is located
import 'http_service.dart'; // Import your HTTP service file

class OfficerProfileScreen extends StatefulWidget { // Change to StatefulWidget
  const OfficerProfileScreen({super.key});

  @override
  _OfficerProfileScreenState createState() => _OfficerProfileScreenState();
}

class _OfficerProfileScreenState extends State<OfficerProfileScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage(); // Create an instance of secure storage
  Map<String, dynamic>? userData; // Variable to hold user data

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  Future<void> _loadUserData() async {
    String? token = await storage.read(key: 'token'); // Retrieve the token
    if (token != null) {
      await fetchUserData(token); // Call the function to fetch user data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ProfilePage(
            name: 'Officer Name', // Example name (you might want to use userData here)
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
      bottomNavigationBar: const OfficerNavBar(currentIndex: 3),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Minimize space usage to fit at the bottom
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfficerProfileEdit()),
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
          onPressed: () async {
            String? token = await storage.read(key: 'token'); // Retrieve the token

            if (token != null) {
              await logoutUser(token); // Call logout function
              await storage.delete(key: 'token'); // Remove the token from storage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
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
