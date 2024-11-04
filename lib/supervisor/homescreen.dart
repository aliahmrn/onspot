import 'package:flutter/material.dart';
import 'profile.dart';
import '../widget/bell.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/complaints_service.dart';
import 'complaints.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  SupervisorHomeScreenState createState() => SupervisorHomeScreenState();
}

class SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
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
      MaterialPageRoute(builder: (context) => SVProfileScreen()),
    );
  }

  void _navigateToComplaintsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComplaintPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(color: primaryColor),
          Positioned(
            top: screenHeight * 0.01,
            left: 0,
            right: 0,
            bottom: screenHeight * 0.08,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: TextStyle(
                          fontSize: 18, // Font size same as "Task"
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          BellProfileWidget(
                            onBellTap: _navigateToComplaintsPage,
                          ),
                          SizedBox(width: screenWidth * 0.025),
                          GestureDetector(
                            onTap: _navigateToProfile,
                            child: const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/profile.jpg'),
                              radius: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/welcome_vacuum.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complaints',
                        style: TextStyle(
                          fontSize: 18, // Font size same as "Task"
                          fontWeight: FontWeight.bold,
                          color: onSecondaryColor,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: onSecondaryColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : error != null
                          ? Center(child: Text(error!))
                          : latestComplaint != null
                              ? GestureDetector(
                                  onTap: _navigateToComplaintsPage,
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.04),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: screenWidth * 0.005,
                                          blurRadius: screenWidth * 0.03,
                                          offset: Offset(0, screenHeight * 0.005),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: screenWidth * 0.06, color: onPrimaryColor),
                                            SizedBox(width: screenWidth * 0.02),
                                            Text(
                                              latestComplaint!['comp_location'] ?? 'No Location',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.045,
                                                fontWeight: FontWeight.w500,
                                                color: onPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Text(
                                          latestComplaint!['comp_desc'] ?? 'No Description',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.bold,
                                            color: onPrimaryColor,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/calendar.svg',
                                              height: screenWidth * 0.06,
                                              color: onPrimaryColor,
                                            ),
                                            SizedBox(width: screenWidth * 0.02),
                                            Text(
                                              latestComplaint!['comp_date'] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: onPrimaryColor,
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
        ],
      ),
    );
  }
}
