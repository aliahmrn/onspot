import 'package:flutter/material.dart';
import '../service/auth_service.dart'; // Import your AuthService
import '../service/profile_service.dart'; // Import ProfileService
import 'profile_edit.dart'; // Import CleanerProfileEditScreen
import 'navbar.dart'; // Import CleanerBottomNavBar
import 'package:shared_preferences/shared_preferences.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({super.key});

  @override
  _CleanerProfileScreenState createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  Map<String, dynamic>? cleanerInfo;
  String? token; // Assume you have a way to retrieve the token

  @override
  void initState() {
    super.initState();
    _initializeTokenAndLoadProfile();
  }

  Future<void> _initializeTokenAndLoadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token != null) {
      await _loadProfile();
    } else {
      print('No token found');
      Navigator.pushReplacementNamed(context, '/'); // Navigate to login if no token
    }
  }

  Future<void> _loadProfile() async {
    ProfileService profileService = ProfileService();

    try {
      cleanerInfo = await profileService.fetchProfile(token!);
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
        setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
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
              color: Color(0xFFFEF7FF),
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
                // Update CircleAvatar to show profile picture or default icon
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: (cleanerInfo?['profile_pic'] != null)
                      ? NetworkImage(cleanerInfo!['profile_pic']) // Display current picture if available
                      : null, // Show default avatar icon if picture is null
                  child: (cleanerInfo?['profile_pic'] == null)
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        )
                      : null, // Don't show anything if picture is available
                ),
                 const SizedBox(height: 10),
                Text(
                  cleanerInfo?['name'] ?? 'Cleaner Name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  cleanerInfo?['username'] ?? 'Username',
                  style: TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                ),
                const SizedBox(height: 40),
                _buildTextField('Email', cleanerInfo?['email'] ?? ''),
                const SizedBox(height: 30),
                _buildTextField('Phone Number', cleanerInfo?['phone_no'] ?? ''),
                const SizedBox(height: 30),
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
            backgroundColor: const Color(0xFFFEF7FF),
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
            _logout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEF7FF),
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
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }
}