import 'package:flutter/material.dart';
import 'navbar.dart';
import 'history.dart';
import 'profile.dart';
import '../widget/bell.dart';
import 'complaint.dart';
import '../service/auth_service.dart'; // Import AuthService
import '../service/history_service.dart'; // Import complaint service

class OfficerHomeScreen extends StatefulWidget {
  const OfficerHomeScreen({super.key});

  @override
  OfficerHomeScreenState createState() => OfficerHomeScreenState();
}

class OfficerHomeScreenState extends State<OfficerHomeScreen> {
  String officerName = 'Officer'; // Default name if fetching fails or takes time
  Map<String, dynamic>? recentComplaint; // Variable to store the recent complaint
  bool isLoadingComplaint = true; // Flag to indicate loading state
  final AuthService _authService = AuthService(); // Instance of AuthService

  @override
  void initState() {
    super.initState();
    _fetchOfficerName(); // Fetch the officer's name when the screen loads
    _fetchRecentComplaint(); // Fetch recent complaint when the screen loads
  }

  Future<void> _fetchOfficerName() async {
    try {
      final userData = await _authService.getUser();
      setState(() {
        officerName = userData['name'] ?? 'Officer'; // Use fetched name, fallback to 'Officer' if null
      });
    } catch (e) {
      setState(() {
        officerName = 'Officer'; // Fallback in case of error
      });
    }
  }

  Future<void> _fetchRecentComplaint() async {
    try {
      final complaint = await fetchMostRecentComplaint(); // Fetch the most recent complaint
      setState(() {
        recentComplaint = complaint;
        isLoadingComplaint = false;
      });
    } catch (e) {
      setState(() {
        recentComplaint = null;
        isLoadingComplaint = false;
      });
    }
  }

  void _handleBellTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  void _handleProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OfficerProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), 
        child: Material(
          elevation: 0, 
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: const Center(
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Row with Bell and Profile Picture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome, $officerName', // Display the officer's name
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                        radius: 15,
                        child: Icon(Icons.person, size: 24), 
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Welcome Banner
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/welcome_vacuum.png'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // File Complaint Section
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FileComplaintPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Image(
                      image: AssetImage('assets/images/messy.png'),
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Noticed a mess?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('We\'re on it - File a complaint now!'),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // History Section with "See All" option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryPage()),
                    );
                  },
                  child: const Text(
                    'see all',
                    style: TextStyle(
                      color: Color.fromARGB(255, 165, 165, 165),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Recent History Item
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
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
                child: isLoadingComplaint
                    ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
                    : recentComplaint != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 24, color: Colors.black),
                                  const SizedBox(width: 5),
                                  Text(
                                    recentComplaint?['comp_location'] ?? 'Unknown location',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                recentComplaint?['comp_desc'] ?? 'No description',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Status: ${recentComplaint?['comp_status'] ?? 'Unknown status'}',
                                style: const TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          )
                        : const Center(child: Text('No recent complaints available')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const OfficerNavBar(currentIndex: 0),
    );
  }
}
