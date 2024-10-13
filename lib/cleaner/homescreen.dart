import 'package:flutter/material.dart';
import 'task.dart';
import 'notifications.dart';
import 'profile.dart';
import 'navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widget/bell.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences package
import '../service/attendance_service.dart'; // Import the AttendanceService

const Color appBarColor = Color(0xFFFFFFFF); // White color for AppBar

class CleanerHomeScreen extends StatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  _CleanerHomeScreenState createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends State<CleanerHomeScreen> {
  String userName = ''; // This will hold the cleaner's name
  late AttendanceService attendanceService;
  String cleanerId = ''; // Make it mutable so you can set it dynamically

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Load the user's name
    _loadCleanerId(); // Load the dynamic cleaner ID
    attendanceService = AttendanceService('http://127.0.0.1:8000'); // Initialize AttendanceService
  }

  // Define the _loadUserName method to fetch the user's name
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Cleaner'; // Default to 'Cleaner' if no name is found
    });
  }

  // Define the _loadCleanerId method to fetch the cleaner ID
  Future<void> _loadCleanerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cleanerId = prefs.getString('cleanerId') ?? ''; // Use the stored cleaner ID, or set a default
    });
  }

  void _handleBellTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerNotificationsScreen(),
      ),
    );
  }

  void _handleProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerProfileScreen(),
      ),
    );
  }

  // Function to mark attendance
  Future<void> _markAttendance(String status) async {
    try {
      await attendanceService.markAttendance(status, cleanerId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance marked as $status')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark attendance')),
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
      body: SingleChildScrollView( // Make content scrollable
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
                          backgroundImage: AssetImage(
                              'assets/images/profile.png'), // Profile image asset
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
                          userName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
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
                              _markAttendance('present'); // Call markAttendance with 'present'
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
                              _markAttendance('absent'); // Call markAttendance with 'absent'
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
                              const Icon(Icons.location_on,
                                  size: 24, color: Colors.black),
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
                                color: Color(0xFF3c6576),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Room Cleaning',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/calendar.svg',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Oct 13, 2024',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CleanerBottomNavBar(currentIndex: 0),
    );
  }
}
