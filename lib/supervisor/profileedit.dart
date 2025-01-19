import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/profileedit_provider.dart';
import '../supervisor/main_navigator.dart';
import '../widget/profile_picture_widget.dart';
import '../providers/profile_provider.dart';
import '../providers/navigation_provider.dart';
import 'package:logger/logger.dart';

class SVProfileEditScreen extends ConsumerStatefulWidget {
  const SVProfileEditScreen({super.key});

  @override
  ConsumerState<SVProfileEditScreen> createState() =>
      _SVProfileEditScreenState();
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
    Future.microtask(() async {
      if (mounted) {
        ref.invalidate(profileEditProvider);
        await ref.read(profileLoaderProvider.future);
      }
    });
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
    final Logger logger = Logger();

    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih tindakan'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Upload'),
              child: const Text('Muat Naik'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'Delete'),
              child: const Text('Padam'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );

    logger.i('💡 User selected action: $action');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Token not found. Please log in.')),
      );
      return;
    }

  if (action == 'Muat Naik') {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        logger.i('💡 User selected image: ${image.path}');
        ref.read(profileEditProvider.notifier).updateTempProfilePicture(image.path);
      }
    } else if (action == 'Padam') {
        final confirmDelete = await _showDeleteConfirmationDialog(context);
        if (confirmDelete == true) {
          logger.i('💡 User confirmed to delete profile picture.');
          ref.read(profileEditProvider.notifier).handleProfilePictureDeletion(token); // Mark for deletion
        }
      }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sahkan Pemadaman'),
          content: const Text('Adakah anda yakin untuk padam gambar profil?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
              child: const Text('Padam'),
            ),
          ],
        );
      },
    );
    return result ?? false;
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
        final shouldExit = await _showCancelConfirmationDialog(context, ref);
        if (shouldExit) {
          Navigator.pop(context);
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: Text(
            'Edit Profil',
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
              final shouldExit = await _showCancelConfirmationDialog(context, ref);
              if (!context.mounted) return;
              if (shouldExit) Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            // Background UI for both loading and loaded states
            _buildBackgroundUI(
              primaryColor: primaryColor,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
            // Handle loading, error, and data states
            profileLoader.when(
              loading: () => _buildLoadingIndicator(screenHeight),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Ralat: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (_) {
                final profileState = ref.watch(profileEditProvider);

                if (!_isInitialized && !profileState.isLoading && profileState.error == null) {
                  nameController.text = profileState.tempName;
                  usernameController.text = profileState.tempUsername;
                  emailController.text = profileState.tempEmail;
                  phoneController.text = profileState.tempPhone;
                  _isInitialized = true;
                }

                return _buildProfileContent(
                  context,
                  primaryColor,
                  secondaryColor,
                  screenWidth,
                  screenHeight,
                  ref,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundUI({
    required Color primaryColor,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Stack(
      children: [
        // Blue background section
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          height: screenHeight * 0.25,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
        ),
        // White rounded section
        Positioned(
          top: screenHeight * 0.2,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(double screenHeight) {
    return Positioned(
      top: screenHeight * 0.4, // Center the spinner in the white rounded section
      left: 0,
      right: 0,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


  Future<bool> _showCancelConfirmationDialog(BuildContext context, WidgetRef ref) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batal Edit'),
          content: const Text('Batal edit? Perubahan belum disimpan akan hilang.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                ref.read(profileEditProvider.notifier).cancelChanges();
                ref.read(currentIndexProvider.notifier).state = 4;
                Navigator.of(context).pop(true);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Widget _buildProfileContent(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
    double screenWidth,
    double screenHeight,
    WidgetRef ref,
  ) {
    final notifier = ref.read(profileEditProvider.notifier);
    final profileState = ref.watch(profileEditProvider);

    final bool isLoading = profileState.isLoading;

    return Stack(
      children: [
        // Profile Picture Section
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          height: screenHeight * 0.25,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ProfilePictureWidget(
                    radius: 60,
                    imageUrl: profileState.tempProfilePic?.isNotEmpty == true
                        ? profileState.tempProfilePic
                        : 'assets/images/default.webp',
                    onTap: isLoading ? null : () => _showImageOptions(context, ref),
                  ),
                  if (!isLoading)
                    GestureDetector(
                      onTap: () => _showImageOptions(context, ref),
                      child: CircleAvatar(
                        radius: screenWidth * 0.05,
                        backgroundColor: Colors.white,
                        child: Icon(
                          profileState.tempProfilePic == null
                              ? Icons.cloud_upload
                              : Icons.edit,
                          size: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Form Section
        Positioned(
          top: screenHeight * 0.2,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.03,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    label: 'Nama',
                    controller: nameController,
                    onChanged: (value) => notifier.updateField('name', value),
                    enabled: !isLoading,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildTextField(
                    label: 'Nama Pengguna',
                    controller: usernameController,
                    onChanged: (value) => notifier.updateField('username', value),
                    enabled: !isLoading,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildTextField(
                    label: 'E-mel',
                    controller: emailController,
                    onChanged: (value) => notifier.updateField('email', value),
                    enabled: !isLoading,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildTextField(
                    label: 'Nombor Telefon',
                    controller: phoneController,
                    onChanged: (value) => notifier.updateField('phone', value),
                    enabled: !isLoading,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null // Disable button while loading
                        : () async {
                            if (nameController.text.isEmpty || emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama dan E-mel diperlukan')),
                              );
                              return;
                            }

                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');

                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error: Token not found. Please log in.')),
                              );
                              return;
                            }

                            await notifier.saveProfile(token);
                            ref.invalidate(profileProvider);
                            await ref.read(profileProvider.future);

                            if (!context.mounted) return;

                            // Show success popup
                            await _showSuccessDialog(context);

                            // Redirect to the profile page
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const MainNavigator()),
                              (route) => false,
                            );
                          },
                    icon: isLoading
                        ? Container() // Empty container for spacing
                        : const Icon(Icons.save, size: 18),
                    label: isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(fontSize: 16),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: const Size(200, 48),
                    ),
                  ),
                ],
              ),
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
    required bool enabled, // Add this to enable or disable the text field
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
          enabled: enabled, // Disable the text field when `enabled` is false
          decoration: InputDecoration(
            prefixIcon: Icon(
              _getIconForLabel(label),
              color: primaryColor,
              size: screenWidth * 0.06,
            ),
            hintText: 'Masukkan $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.035,
            ),
          ),
        ),
      ],
    );
  }

    Future<void> _showSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Berjaya'),
          content: const Text('Profil anda telah berjaya dikemas kini!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Nama':
        return Icons.person;
      case 'Nama Pengguna':
        return Icons.account_circle;
      case 'E-mel':
        return Icons.email;
      case 'Nombor Telefon':
        return Icons.phone;
      default:
        return Icons.edit;
    }
  }
}
