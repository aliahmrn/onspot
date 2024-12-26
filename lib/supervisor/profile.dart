import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../widget/profile_picture_widget.dart';
import '../service/auth_service.dart';
import 'profileedit.dart';
import '../supervisor/main_navigator.dart';

class SVProfileScreen extends ConsumerWidget {
  const SVProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: _buildProfileContent(
        context,
        primaryColor,
        secondaryColor,
        onPrimaryColor,
        screenWidth,
        ref,
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
    Color onPrimaryColor,
    double screenWidth,
    WidgetRef ref,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Blue Header Section
          Container(
            height: 190,
            width: double.infinity,
            color: primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    Consumer(builder: (_, ref, __) {
                      final profile = ref.watch(profileProvider);
                      return ProfilePictureWidget(
                        radius: 50,
                        imageUrl: profile.when(
                          data: (data) => data['profile_pic'] ??
                              'http://192.168.1.105:8000/storage/profile_pic/default.webp',
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    // Name and Username
                    Consumer(builder: (_, ref, __) {
                      final profile = ref.watch(profileProvider);
                      return profile.when(
                        loading: () => const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        error: (_, __) => const Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        data: (data) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data['name'] ?? 'Name not available',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              data['username'] ?? 'Username not available',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // White Rounded Section
          Transform.translate(
            offset: const Offset(0, -40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Email Field
                  Consumer(builder: (_, ref, __) {
                    final profile = ref.watch(profileProvider);
                    return profile.when(
                      loading: () =>
                          _buildTextField(context, 'Email', 'Loading...', Icons.email),
                      error: (_, __) =>
                          _buildTextField(context, 'Email', 'Error loading', Icons.email),
                      data: (data) =>
                          _buildTextField(context, 'Email', data['email'] ?? '', Icons.email),
                    );
                  }),
                  const SizedBox(height: 20),
                  // Phone Number Field
                  Consumer(builder: (_, ref, __) {
                    final profile = ref.watch(profileProvider);
                    return profile.when(
                      loading: () => _buildTextField(
                          context, 'Phone Number', 'Loading...', Icons.phone),
                      error: (_, __) => _buildTextField(
                          context, 'Phone Number', 'Error loading', Icons.phone),
                      data: (data) => _buildTextField(
                          context, 'Phone Number', data['phone_no'] ?? '', Icons.phone),
                    );
                  }),
                  const SizedBox(height: 30),
                  // Buttons Section
                  _buildButtonSection(context, ref, primaryColor, secondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, WidgetRef ref, Color primaryColor,
      Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SVProfileEditScreen()),
              ).then((_) {
                ref.invalidate(profileProvider);
                // Navigate back to MainNavigator
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigator()),
                  (route) => false,
                );
              });
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text(
              'Edit Information',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: () {
              _confirmLogout(context);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.logout();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }
}
