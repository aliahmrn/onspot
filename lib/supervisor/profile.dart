import 'package:flutter/material.dart';
import '../supervisor/profileedit.dart';
import '../login.dart';
import '../supervisor/navbar.dart';
import 'package:onspot_supervisor/service/auth_service.dart'; 


class SVProfilePage extends StatelessWidget {
  const SVProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(
            child: ProfilePage(
              name: 'Supervisor Name', // Replace with actual data if needed
              username: 'supervisor.username',
              email: 'supervisor@gmail.com',
              phoneNumber: '0123456789',
            ),
          ),
          _buildButtonSection(context),
        ],
      ),
      bottomNavigationBar: SupervisorBottomNavBar(currentIndex: 4),
    );
  }

Widget _buildButtonSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SVProfileEditPage()),
          );
        },
        icon: const Icon(Icons.edit, color: Colors.black),
        label: const Text(
          'Edit Information',
          style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 234, 220, 233),
          elevation: 5, // Add shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // More curved
          ),
          minimumSize: const Size(200, 50), 
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
      const SizedBox(height: 30),
    ],
  );
}

}

class ProfilePage extends StatelessWidget {
  final String name;
  final String username;
  final String email;
  final String phoneNumber;

  const ProfilePage({
    super.key,
    required this.name,
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFEF7FF), // Change background color to #fef7ff
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4C7D90),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  username,
                  style: const TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                ),
                const SizedBox(height: 40),
                _buildTextField('Email', email),
                const SizedBox(height: 30),
                _buildTextField('Phone Number', phoneNumber),
                const SizedBox(height: 35), 
                ElevatedButton(
                  onPressed: () => _logout(context), // Call logout method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 234, 220, 233),
                    elevation: 5, // Add shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // More curved
                    ),
                    minimumSize: const Size(200, 50), // Reduced width
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
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

  void _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.clearUserDetails(); // Clear the token
   Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate back to the login screen
);
}
}
