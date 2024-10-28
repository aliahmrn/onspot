import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'profile.dart';
import 'navbar.dart';
import '../bell.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/complaints_service.dart';
import 'complaints.dart'; 
import 'package:google_fonts/google_fonts.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  _SupervisorHomeScreenState createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  String userName = '';
  Map<String, dynamic>? latestComplaint;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchUnassignedComplaints();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Supervisor';
    });
  }

  Future<void> _fetchUnassignedComplaints() async {
    try {
      final complaints = await ComplaintsService().fetchComplaints();
      setState(() {
        latestComplaint = complaints.isNotEmpty ? complaints.first : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load complaints: $e';
        isLoading = false;
      });
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SVProfilePage()),
    );
  }

  void _navigateToComplaintsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComplaintPage()), // Navigate to ComplaintsPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0, // Remove shadow
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, $userName!',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      BellProfileWidget(onBellTap: _navigateToComplaintsPage),
                      GestureDetector(
                        onTap: _navigateToProfile,
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/profile.jpg'),
                          radius: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/welcome_vacuum.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Complaints',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToComplaintsPage, // Navigate to ComplaintsPage on See All
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(child: Text(error!))
                      : latestComplaint != null
                          ? GestureDetector(
                              onTap: _navigateToComplaintsPage, // Navigate to ComplaintsPage on card tap
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
                                    Row(
                                      children: [
                                        const Icon(Icons.place, size: 30, color: Colors.black),
                                        const SizedBox(width: 5),
                                        Text(
                                          latestComplaint!['comp_location'] ?? 'No Location',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          latestComplaint!['comp_time'] != null
                                              ? DateFormat('HH:mm').format(DateTime.parse("1970-01-01 ${latestComplaint!['comp_time']}"))
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF3c6576),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      latestComplaint!['comp_desc'] ?? 'No Description',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/calendar.svg',
                                          height: 24,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          latestComplaint!['comp_date'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const Center(child: Text('No unassigned complaints available.')),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SupervisorBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
