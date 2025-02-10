import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import 'profile_edit.dart';
import '../utils/shared_preferences_manager.dart';
import '../providers/navigation_provider.dart'; // For currentIndexProvider
import '../providers/attendance_provider.dart'; // For attendanceProvider
import '../login.dart'; // Ensure this file defines `LoginScreen`
import '../providers/auth_provider.dart';
import 'package:logger/logger.dart';

class CleanerProfileScreen extends ConsumerWidget {
  const CleanerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

    // Watch the profileProvider
    final profileAsyncValue = ref.watch(profileProvider);
    // Watch the attendanceProvider
    final attendanceAsyncValue = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil',
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
            'Ralat memuatkan profil: $error',
            style: TextStyle(
              color: Colors.red,
              fontSize: screenWidth * 0.045,
            ),
          ),
        ),
        data: (cleanerInfo) => attendanceAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Ralat memuatkan status: $error',
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ),
          data: (attendanceState) => _buildProfileContent(
            context,
            ref,
            cleanerInfo,
            attendanceState.status ?? 'Unavailable',
            primaryColor,
            secondaryColor,
            onPrimaryColor,
            screenWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> cleanerInfo,
    String attendanceStatus,
    Color primaryColor,
    Color secondaryColor,
    Color onPrimaryColor,
    double screenWidth,
  ) {
    final translatedStatus = attendanceStatus.toLowerCase() == 'available' ? 'Sedia' : 'Tidak Sedia';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
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
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: Column(
                          children: [
                            SizedBox(height: screenWidth * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: screenWidth * 0.12,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: cleanerInfo['profile_pic'] != null
                                            ? NetworkImage("${cleanerInfo['profile_pic']}?timestamp=${DateTime.now().millisecondsSinceEpoch}")
                                            : null,
                                        child: cleanerInfo['profile_pic'] == null
                                            ? Icon(Icons.person, size: screenWidth * 0.12, color: Colors.grey[600])
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenWidth * 0.01,
                                        horizontal: screenWidth * 0.03,
                                      ),
                                      decoration: BoxDecoration(
                                        color: translatedStatus == 'Sedia'
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: translatedStatus == 'Sedia' ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      child: Text(
                                        translatedStatus,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color: translatedStatus == 'Sedia' ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.05),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cleanerInfo['name'] ?? 'Nama Pembersih',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      cleanerInfo['username'] ?? 'cleaner.username',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.white70,
                                      ),
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
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.05),
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
                          SizedBox(height: screenWidth * 0.1),
                          _buildTextField(context, 'E-mel', cleanerInfo['email'] ?? '', Icons.email, screenWidth),
                          SizedBox(height: screenWidth * 0.05),
                          _buildTextField(context, 'Nombor Telefon', cleanerInfo['phone_no'] ?? '', Icons.phone, screenWidth),
                          SizedBox(height: screenWidth * 0.08),
                          _buildButtonSection(context, ref, primaryColor, secondaryColor, screenWidth),
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
}



  Widget _buildTextField(BuildContext context, String label, String value, IconData icon, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03), // Responsive spacing
      child: Center( // Center the container
        child: Container(
          width: screenWidth * 0.8, // Set width to 80% of the screen width
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
            padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: screenWidth * 0.06), // Responsive icon
                SizedBox(width: screenWidth * 0.03), // Responsive spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Responsive font size
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01), // Responsive spacing
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // Responsive font size
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
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, WidgetRef ref, Color primaryColor, Color secondaryColor, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.5, // Responsive width
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const CleanerProfileEditScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ).then((_) => ref.invalidate(profileProvider));
            },
            icon: Icon(Icons.edit, size: screenWidth * 0.045), // Responsive icon
            label: Text(
              'Edit Profil',
              style: TextStyle(fontSize: screenWidth * 0.04), // Responsive font size
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.035, // Responsive padding
              ),
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.04), // Responsive spacing
        SizedBox(
          width: screenWidth * 0.5, // Responsive width
          child: ElevatedButton.icon(
            onPressed: () {
              _confirmLogout(context, ref);
            },
            icon: Icon(Icons.logout, size: screenWidth * 0.045), // Responsive icon
            label: Text(
              'Log Keluar',
              style: TextStyle(fontSize: screenWidth * 0.04), // Responsive font size
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.035, // Responsive padding
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Keluar'),
          content: const Text('Adakah anda yakin untuk log keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                logout(context, ref);
              },
              child: const Text('Log Keluar'),
            ),
          ],
        );
      },
    );
  }

  void logout(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider); // Get AuthService instance
      await authService.logout(); // Call logout logic from AuthService

      // Clear SharedPreferences
      SharedPreferencesManager.prefs.clear();
      Logger().i('SharedPreferences cleared on logout');

      // Reset providers
      ref.invalidate(authTokenProvider);
      ref.read(authTokenProvider.notifier).state = ''; // Reset auth token
      ref.invalidate(profileProvider); // Invalidate profile
      ref.invalidate(attendanceProvider); // Invalidate attendance provider
      ref.read(currentIndexProvider.notifier).state = 0; // Reset navigation index to home page

      if (!context.mounted) return;

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // Ensure the widget is still mounted before showing the SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

