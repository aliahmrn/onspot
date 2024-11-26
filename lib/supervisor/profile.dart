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
          context,
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
  return LayoutBuilder(
    builder: (context, constraints) {
      // Ensures Stack has bounded constraints
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight, // Ensures the Stack fills available height
          ),
          child: IntrinsicHeight( // Allows Stack to take intrinsic height of its children
            child: Stack(
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
                        _buildTextField(
                          context,
                          'Email',
                          cleanerInfo['email'] ?? '',
                          Icons.email, // Add icon for the email field
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          context,
                          'Phone Number',
                          cleanerInfo['phone_no'] ?? '',
                          Icons.phone, // Add icon for the phone number field
                        ),
                        const SizedBox(height: 30),
                        _buildButtonSection(context, primaryColor, secondaryColor),
                      ],

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildTextField(BuildContext context, String label, String value, IconData icon) {
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
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
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


Widget _buildButtonSection(BuildContext context, Color primaryColor, Color secondaryColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 200, // Set a fixed width for both buttons
        child: ElevatedButton.icon(
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
          icon: const Icon(Icons.edit, size: 18), // Slightly smaller icon
          label: const Text(
            'Edit Information',
            style: TextStyle(fontSize: 16), // Adjusted font size
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Adjusted padding
          ),
        ),
      ),
      const SizedBox(height: 12), // Space between the buttons
      SizedBox(
        width: 200, // Set the same fixed width for both buttons
        child: ElevatedButton.icon(
          onPressed: () {
            _confirmLogout(context);
          },
          icon: const Icon(Icons.logout, size: 18), // Logout icon
          label: const Text(
            'Logout',
            style: TextStyle(fontSize: 16), // Adjusted font size
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Adjusted padding
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

    // Check if the widget is still mounted before navigating
    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }
}
