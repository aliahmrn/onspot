import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../service/auth_service.dart';
import 'profileedit.dart';

class SVProfileScreen extends ConsumerWidget {
  const SVProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

    // Watch the profileProvider
    final profileAsyncValue = ref.watch(profileProvider);

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
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading profile: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (cleanerInfo) => _buildProfileContent(
          context, // Pass context here
          cleanerInfo,
          primaryColor,
          secondaryColor,
          onPrimaryColor,
          screenWidth,
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    Map<String, dynamic> cleanerInfo,
    Color primaryColor,
    Color secondaryColor,
    Color onPrimaryColor,
    double screenWidth,
  ) {
    return Stack(
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: cleanerInfo['profile_pic'] != null
                              ? NetworkImage(cleanerInfo['profile_pic'])
                              : null,
                          child: cleanerInfo['profile_pic'] == null
                              ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cleanerInfo['name'] ?? 'Supervisor Name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            cleanerInfo['username'] ?? 'supervisor.username',
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
                _buildTextField(context, 'Email', cleanerInfo['email'] ?? ''),
                const SizedBox(height: 20),
                _buildTextField(context, 'Phone Number', cleanerInfo['phone_no'] ?? ''),
                const SizedBox(height: 30),
                _buildButtonSection(context, primaryColor, secondaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width; // Use context safely
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
              border: Border.all(color: Colors.grey.shade400),
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
                pageBuilder: (context, animation, secondaryAnimation) => const SVProfileEditScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Information'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            minimumSize: const Size(250, 50),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _confirmLogout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            minimumSize: const Size(250, 50),
          ),
          child: const Text('Logout'),
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
    Navigator.pushReplacementNamed(context, '/');
  }
}
