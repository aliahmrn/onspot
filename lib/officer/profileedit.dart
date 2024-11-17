import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/profile_service.dart'; // Import ProfileService
import 'package:shared_preferences/shared_preferences.dart'; // Import for token management

class OfficerProfileEdit extends StatefulWidget {
  const OfficerProfileEdit({super.key});

  @override
  OfficerProfileEditState createState() => OfficerProfileEditState();
}

class OfficerProfileEditState extends State<OfficerProfileEdit> {
  String? _currentProfilePic;
  Map<String, dynamic>? officerInfo;
  String? token;

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
      print('No token found');
      Navigator.pushReplacementNamed(context, '/'); // Navigate to login if no token
    }
  }

  Future<void> _loadProfile() async {
    ProfileService profileService = ProfileService();

    try {
      officerInfo = await profileService.fetchProfile(token!);
      setState(() {
        // Fetch all required fields including name, username, email, and phone
        _currentProfilePic = officerInfo?['profile_pic'];
        _nameController.text = officerInfo?['name'] ?? ''; // Fetch name
        _usernameController.text = officerInfo?['username'] ?? ''; // Fetch username
        _emailController.text = officerInfo?['email'] ?? ''; // Fetch email
        _phoneController.text = officerInfo?['phone_no'] ?? ''; // Fetch phone number
      });
    } catch (e) {
      print('Error fetching profile: $e');
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
      // Show success message or navigate back after update
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      print('Error updating profile: $e');
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
          _currentProfilePic = image.path; // Update profile picture path
        });
        // TODO: Upload the image to your server
      }
    } else if (action == 'Delete') {
      setState(() {
        _currentProfilePic = null; // Clear profile picture
      });
      // TODO: Call your API to delete the profile picture
    }
  }

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
                        Color(0xFF4C7D90),
                        Colors.white
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
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
                const SizedBox(height: 40),
                _buildTextField('Name', _nameController),
                const SizedBox(height: 30),
                _buildTextField('Username', _usernameController),
                const SizedBox(height: 30),
                _buildTextField('Email', _emailController),
                const SizedBox(height: 30),
                _buildTextField('Phone Number', _phoneController),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: 250, // You can set this to the desired width
                    height: 50,
                    child:ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Match the background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Same rounded corners as Edit Info
                        ),
                        elevation: 3, // Match the elevation for shadow effect
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Same padding
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.black, // Match text color
                          fontWeight: FontWeight.bold, // Bold font style
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
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
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration.collapsed(hintText: ''),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}