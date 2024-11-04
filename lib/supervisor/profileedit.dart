import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import '../service/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SVProfileEditScreen extends StatefulWidget {
  const SVProfileEditScreen({super.key});

  @override
  SVProfileEditScreenState createState() => SVProfileEditScreenState();
}

class SVProfileEditScreenState extends State<SVProfileEditScreen> {
  String? _currentProfilePic;
  Map<String, dynamic>? cleanerInfo;
  String? token;
  final Logger _logger = Logger();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  Future<void> _loadProfile() async {
    ProfileService profileService = ProfileService();

    try {
      cleanerInfo = await profileService.fetchProfile(token!);
      if (mounted) {
        setState(() {
          _currentProfilePic = cleanerInfo?['profile_pic'];
          _nameController.text = cleanerInfo?['name'] ?? '';
          _usernameController.text = cleanerInfo?['username'] ?? '';
          _emailController.text = cleanerInfo?['email'] ?? '';
          _phoneController.text = cleanerInfo?['phone_no'] ?? '';
        });
      }
    } catch (e) {
      _logger.e('Error fetching profile: $e');
    }
  }

  Future<void> _updateProfile() async {
    ProfileService profileService = ProfileService();

    try {
      Map<String, String> updatedData = {
        'cleaner_name': _nameController.text,
        'cleaner_username': _usernameController.text,
        'email': _emailController.text,
        'phone_no': _phoneController.text,
      };

      await profileService.updateProfile(token!, updatedData, _currentProfilePic);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      _logger.e('Error updating profile: $e');
    }
  }

  Future<void> _showImageOptions() async {
    final ImagePicker picker = ImagePicker();
    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an action'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Upload'),
              child: const Text('Upload'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'Delete'),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (action == 'Upload') {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _currentProfilePic = image.path;
        });
      }
    } else if (action == 'Delete') {
      setState(() {
        _currentProfilePic = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          'Edit Profile',
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _currentProfilePic != null
                            ? NetworkImage(_currentProfilePic!)
                            : null,
                        child: _currentProfilePic == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageOptions,
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFFEF7FF),
                            child: Icon(Icons.edit, size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildTextField('Name', _nameController, screenWidth),
                    const SizedBox(height: 30),
                    _buildTextField('Username', _usernameController, screenWidth),
                    const SizedBox(height: 30),
                    _buildTextField('Email', _emailController, screenWidth),
                    const SizedBox(height: 30),
                    _buildTextField('Phone Number', _phoneController, screenWidth),
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.9,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF7FF),
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
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

  Widget _buildTextField(String label, TextEditingController controller, double screenWidth) {
    return Column(
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
          child: TextField(
            controller: controller,
            decoration: const InputDecoration.collapsed(hintText: ''),
          ),
        ),
      ],
    );
  }
}
