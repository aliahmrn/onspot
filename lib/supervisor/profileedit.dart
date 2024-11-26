import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/profileedit_provider.dart';
import '../providers/navigation_provider.dart';
import '../supervisor/main_navigator.dart';
import '../providers/profile_provider.dart';

class SVProfileEditScreen extends ConsumerStatefulWidget {
  const SVProfileEditScreen({super.key});

  @override
  ConsumerState<SVProfileEditScreen> createState() => _SVProfileEditScreenState();
}

class _SVProfileEditScreenState extends ConsumerState<SVProfileEditScreen> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Ensure profile data is loaded when entering the screen
    Future.microtask(() => ref.refresh(profileLoaderProvider));

    // Initialize controllers with empty strings; values will be updated once data is loaded
    nameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _showImageOptions(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
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
        ref.read(profileEditProvider.notifier).updateProfilePicture(image.path);
      }
    } else if (action == 'Delete') {
      ref.read(profileEditProvider.notifier).updateProfilePicture(null);
    }
  }

  Future<bool> _showCancelConfirmationDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Edit'),
          content: const Text('Are you sure you want to cancel editing? Unsaved changes will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay on the page
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm cancellation
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return result ?? false; // Return false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    final profileLoader = ref.watch(profileLoaderProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showCancelConfirmationDialog(context);
        return shouldExit; // Return true to exit, false to stay
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.06),
            onPressed: () async {
              final shouldExit = await _showCancelConfirmationDialog(context);
              if (!context.mounted) return; // Ensure context is still valid
              if (shouldExit) Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            // Rounded White Section at the Bottom
            Positioned(
              top: screenHeight * 0.20,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.08),
                    topRight: Radius.circular(screenWidth * 0.08),
                  ),
                ),
              ),
            ),

            // Main Profile Content
            profileLoader.when(
              loading: () => Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: screenHeight * 0.25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(screenWidth * 0.08),
                          bottomRight: Radius.circular(screenWidth * 0.08),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.20,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.08),
                          topRight: Radius.circular(screenWidth * 0.08),
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ],
              ),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (_) {
                if (!_isInitialized) {
                  final profileState = ref.read(profileEditProvider);
                  nameController.text = profileState.name;
                  usernameController.text = profileState.username;
                  emailController.text = profileState.email;
                  phoneController.text = profileState.phone;
                  _isInitialized = true;
                }
                return _buildProfileContent(context, primaryColor, secondaryColor, screenWidth, screenHeight);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Color primaryColor, Color secondaryColor, double screenWidth, double screenHeight) {
    final notifier = ref.read(profileEditProvider.notifier);

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.20,
          child: Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.15,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: ref.watch(profileEditProvider).profilePic != null
                      ? NetworkImage(ref.watch(profileEditProvider).profilePic!)
                      : null,
                  child: ref.watch(profileEditProvider).profilePic == null
                      ? Icon(Icons.person, size: screenWidth * 0.15, color: Colors.white)
                      : null,
                ),
                GestureDetector(
                  onTap: () => _showImageOptions(context, ref),
                  child: CircleAvatar(
                    radius: screenWidth * 0.05,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: screenWidth * 0.05, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
            child: Column(
              children: [
                _buildTextField(
                  label: 'Name',
                  controller: nameController,
                  onChanged: (value) => notifier.updateField('name', value),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildTextField(
                  label: 'Username',
                  controller: usernameController,
                  onChanged: (value) => notifier.updateField('username', value),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildTextField(
                  label: 'Email',
                  controller: emailController,
                  onChanged: (value) => notifier.updateField('email', value),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildTextField(
                  label: 'Phone Number',
                  controller: phoneController,
                  onChanged: (value) => notifier.updateField('phone', value),
                ),
                SizedBox(height: screenHeight * 0.05),
                ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('token');

                    if (token == null) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error: Token not found. Please log in again.')),
                      );
                      return;
                    }

                    await notifier.saveProfile(token);
                    final _ = ref.refresh(profileProvider);
                    ref.read(currentIndexProvider.notifier).state = 4;

                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Profile updated successfully!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainNavigator()),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.save, size: 18, color: Colors.white),
                  label: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    minimumSize: Size(screenWidth * 0.7, screenHeight * 0.07),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(
              _getIconForLabel(label),
              color: primaryColor,
              size: screenWidth * 0.06,
            ),
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.035),
          ),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Name':
        return Icons.person;
      case 'Username':
        return Icons.account_circle;
      case 'Email':
        return Icons.email;
      case 'Phone Number':
        return Icons.phone;
      default:
        return Icons.edit;
    }
  }
}
