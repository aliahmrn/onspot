import 'package:flutter/material.dart';
import 'task.dart';
import 'notifications.dart';
import 'profile.dart';
import 'navbar.dart';
import '../widget/bell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/attendance_service.dart';

const Color appBarColor = Color(0xFFFFFFFF); // White color for AppBar

class CleanerHomeScreen extends StatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  _CleanerHomeScreenState createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends State<CleanerHomeScreen> {
  String userName = ''; // This will hold the cleaner's name
  late AttendanceService attendanceService;
  String cleanerId = ''; // Cleaner ID will be stored here
  bool isAttendanceSubmitted = false; // State variable to control visibility of attendance card

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Load the user's name
    _loadCleanerId(); // Load the dynamic cleaner ID
    _initializeAttendanceService(); // Initialize AttendanceService with token
    _checkAttendanceStatus(); // Check if attendance has been submitted today
  }

  // Method to load the user's name from SharedPreferences
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Cleaner'; // Default to 'Cleaner' if no name is found
    });
  }

  // Method to load the cleaner ID from SharedPreferences
  Future<void> _loadCleanerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cleanerId = prefs.getString('cleanerId') ?? ''; // Use 'cleanerId' to match auth_service
      print('Loaded Cleaner ID: $cleanerId'); // Debug line
    });
  }

  // Method to initialize AttendanceService with token
  Future<void> _initializeAttendanceService() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Get the token from shared preferences

    if (token != null) {
      attendanceService = AttendanceService(token); // Initialize AttendanceService with token
    } else {
      // Handle the case where the token is null (e.g., navigate to login)
      print('No token found, navigating to login...');
      // You can navigate to the login screen or handle accordingly
    }
  }

  // Method to check if the attendance has been submitted today
  Future<void> _checkAttendanceStatus() async {
    // Directly call the AttendanceService method to check attendance status
    bool submittedToday = await attendanceService.isAttendanceSubmittedToday();
    
    // Update the state based on the result
    setState(() {
      isAttendanceSubmitted = submittedToday; 
    });
  }

  // Navigate to the notifications screen
  void _handleBellTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerNotificationsScreen(),
      ),
    );
  }

  // Navigate to the profile screen
  void _handleProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerProfileScreen(),
      ),
    );
  }

  // Function to mark attendance and call the API
  Future<void> _submitAttendance(String status) async {
    try {
      // Call the AttendanceService API without passing cleanerId
      await attendanceService.submitAttendance(
        status: status // Pass only the status parameter
      );

      // Hide the attendance card after successful submission
      setState(() {
        isAttendanceSubmitted = true; // Update state to hide the card
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance marked as $status')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark attendance: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: appBarColor, // Set AppBar color
          ),
          child: AppBar(
            elevation: 0, // No internal elevation
            backgroundColor: Colors.transparent, // Transparent to show the container's background
            automaticallyImplyLeading: false, // Remove the back button
            title: const Text(
              'Home',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, $userName!', // Display the cleaner's name dynamically
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      BellProfileWidget(
                        onBellTap: () => _handleBellTap(context),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _handleProfileTap(context),
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/profile.png'), // Profile image asset
                          radius: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/welcome_vacuum.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(),
                ),
              ),
              const SizedBox(height: 16),

              // Attendance section with visibility control
              if (!isAttendanceSubmitted) // Only show if attendance not submitted
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            userName, // Display cleaner's name instead of 'Cleaner'
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _submitAttendance('present'); // Call submitAttendance with 'present'
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _submitAttendance('absent'); // Call submitAttendance with 'absent'
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CleanerTasksScreen()),
                      );
                    },
                    child: const Text(
                      'see all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CleanerTasksScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF92AEB9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 24, color: Colors.black),
                              const SizedBox(width: 5),
                              const Text(
                                'Floor 2',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Positioned(
                            right: 0,
                            child: Text(
                              '9:41 AM',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4D4D4D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Empty bins, clean tables, clean windows',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CleanerBottomNavBar(currentIndex: 0), // Add your BottomNavigationBarWidget
    );
  }
}
