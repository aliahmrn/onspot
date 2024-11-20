import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../service/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileEditProvider = StateNotifierProvider<ProfileEditNotifier, Map<String, dynamic>?>((ref) {
  return ProfileEditNotifier(ProfileService());
});

class ProfileEditNotifier extends StateNotifier<Map<String, dynamic>?> {
  final ProfileService _profileService;
  String? token;

  ProfileEditNotifier(this._profileService) : super(null);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? currentProfilePic;

  Future<void> initializeProfile() async {
    token = await _getToken();
    if (token != null) {
      await loadProfile();
    } else {
      // Handle token absence (e.g., redirect to login)
    }
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _profileService.fetchProfile(token!);
      currentProfilePic = profile['profile_pic'];
      nameController.text = profile['name'] ?? '';
      usernameController.text = profile['username'] ?? '';
      emailController.text = profile['email'] ?? '';
      phoneController.text = profile['phone_no'] ?? '';
      state = profile;
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> updateProfile() async {
    try {
      final updatedData = {
        'cleaner_name': nameController.text,
        'cleaner_username': usernameController.text,
        'email': emailController.text,
        'phone_no': phoneController.text,
      };

      await _profileService.updateProfile(token!, updatedData, currentProfilePic);
      // Handle success, e.g., show a success message
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> updateProfilePicture(String? path) async {
    currentProfilePic = path;
    state = {...state ?? {}, 'profile_pic': path};
    // Optionally, upload the image to your server
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

class OfficerProfileEdit extends ConsumerWidget {
  const OfficerProfileEdit({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileNotifier = ref.read(profileEditProvider.notifier);

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: profileNotifier.initializeProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
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
                          colors: [Color(0xFF4C7D90), Colors.white],
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
                          backgroundImage: profileNotifier.currentProfilePic != null
                              ? NetworkImage(profileNotifier.currentProfilePic!)
                              : null,
                          child: profileNotifier.currentProfilePic == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showImageOptions(context, profileNotifier),
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
                    _buildTextField('Name', profileNotifier.nameController),
                    const SizedBox(height: 30),
                    _buildTextField('Username', profileNotifier.usernameController),
                    const SizedBox(height: 30),
                    _buildTextField('Email', profileNotifier.emailController),
                    const SizedBox(height: 30),
                    _buildTextField('Phone Number', profileNotifier.phoneController),
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: 250,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => profileNotifier.updateProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showImageOptions(BuildContext context, ProfileEditNotifier profileNotifier) async {
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
        await profileNotifier.updateProfilePicture(image.path);
      }
    } else if (action == 'Delete') {
      await profileNotifier.updateProfilePicture(null);
    }
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
