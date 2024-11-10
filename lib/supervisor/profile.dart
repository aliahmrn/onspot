import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../service/auth_service.dart';
import '../service/profile_service.dart';
import 'profileedit.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SVProfileScreen extends StatefulWidget {
  const SVProfileScreen({super.key});

  @override
  SVProfileScreenState createState() => SVProfileScreenState();
}

class SVProfileScreenState extends State<SVProfileScreen> {
  Map<String, dynamic>? cleanerInfo;
  String? token;
  final Logger _logger = Logger();

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
      if (mounted && context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: cleanerInfo?['profile_pic'] != null
                              ? NetworkImage(cleanerInfo!['profile_pic'])
                              : null,
                          child: cleanerInfo?['profile_pic'] == null
                              ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cleanerInfo?['name'] ?? 'Supervisor Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              cleanerInfo?['username'] ?? 'supervisor.username',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildTextField('Email', cleanerInfo?['email'] ?? ''),
                  const SizedBox(height: 20),
                  _buildTextField('Phone Number', cleanerInfo?['phone_no'] ?? ''),
                  const SizedBox(height: 30),
                  _buildButtonSection(context, primaryColor, secondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: screenWidth * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, Color primaryColor, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => SVProfileEditScreen(),
                transitionDuration: Duration.zero, // Disables animation
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Information'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,     // Use primary color for background
            foregroundColor: secondaryColor,   // Use secondary color for text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(250, 50),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _logout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,     // Use primary color for background
            foregroundColor: secondaryColor,   // Use secondary color for text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(250, 50),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  void _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.logout();
    if (mounted && context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}
