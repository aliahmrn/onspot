import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../service/auth_service.dart'; // Import your AuthService
import '../service/profile_service.dart'; // Import ProfileService
import 'profileedit.dart'; // Import CleanerProfileEditScreen
import 'package:shared_preferences/shared_preferences.dart';

class SVProfileScreen extends StatefulWidget {
  const SVProfileScreen({super.key});

  @override
  SVProfileScreenState createState() => SVProfileScreenState(); // Made public
}

class SVProfileScreenState extends State<SVProfileScreen> {
  Map<String, dynamic>? cleanerInfo;
  String? token;
  final Logger _logger = Logger(); // Use Logger instead of print

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
      _logger.w('No token found');
      if (mounted) {
        if (context.mounted) {  // Guarding with `context.mounted`
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    }
  }

  Future<void> _loadProfile() async {
    ProfileService profileService = ProfileService();

    try {
      cleanerInfo = await profileService.fetchProfile(token!);
    } catch (e) {
      _logger.e('Error fetching profile: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4C7D90),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
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
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: (cleanerInfo?['profile_pic'] != null)
                      ? NetworkImage(cleanerInfo!['profile_pic'])
                      : null,
                  child: (cleanerInfo?['profile_pic'] == null)
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        )
                      : null,
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
                  style: const TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
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
              MaterialPageRoute(builder: (context) => SVProfileEditScreen()),
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
    if (mounted) {
      if (context.mounted) { // Guarding with `context.mounted`
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }
}
