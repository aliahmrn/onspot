import 'package:flutter/material.dart';
import 'navbar.dart';
import 'profileedit.dart';
import 'package:onspot_officer/login.dart';
import 'package:onspot_officer/service/auth_service.dart'; // Import AuthService

class OfficerProfileScreen extends StatefulWidget {
  const OfficerProfileScreen({super.key});

  @override
  OfficerProfileScreenState createState() => OfficerProfileScreenState();
}

class OfficerProfileScreenState extends State<OfficerProfileScreen> {
  Map<String, dynamic>? userData;
  AuthService authService = AuthService(); // Initialize the AuthService
  bool isLoading = true; // Add loading indicator state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      userData = await authService.getUser(); // Fetch user data from AuthService
      setState(() {
        isLoading = false; // Set loading to false when data is loaded
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false; // Ensure loading state is updated even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
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
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loader while data is loading
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Display fetched user data (name, username, etc.)
                      Text(
                        userData?['name'] ?? '', // Use fetched name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        userData?['username'] ?? '', // Use fetched username
                        style: const TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                      ),
                      const SizedBox(height: 40),
                      _buildTextField('Email', userData?['email'] ?? ''),
                      const SizedBox(height: 30),
                      _buildTextField('Phone Number', userData?['phone_no'] ?? ''),
                      const SizedBox(height: 30), // Space before buttons
                      _buildButtonSection(context),
                    ],
                  ),
                ),
        ],
      ),
      bottomNavigationBar: const OfficerNavBar(currentIndex: 3),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Edit Info Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OfficerProfileEdit()), // Navigate to profile edit
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text(
            'Edit Info',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Logout Button
        ElevatedButton(
          onPressed: () async {
            await authService.logout(); // Call logout function from AuthService
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to login page
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
          SizedBox(
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
        ],
      ),
    );
  }
}
