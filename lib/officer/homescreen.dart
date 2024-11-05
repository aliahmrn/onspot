import 'package:flutter/material.dart';
import 'navbar.dart';
import 'history.dart';
import 'profile.dart';
import '../widget/bell.dart';
import 'complaint.dart';
import '../service/auth_service.dart';
import '../service/history_service.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class OfficerHomeScreen extends StatefulWidget {
  const OfficerHomeScreen({super.key});

  @override
  OfficerHomeScreenState createState() => OfficerHomeScreenState();
}

class OfficerHomeScreenState extends State<OfficerHomeScreen> {
  String officerName = 'Officer';
  Map<String, dynamic>? recentComplaint;
  bool isLoadingComplaint = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchOfficerName();
    _fetchRecentComplaint();
  }

  Future<void> _fetchOfficerName() async {
    try {
      final userData = await _authService.getUser();
      setState(() {
        officerName = userData['name'] ?? 'Officer';
      });
    } catch (e) {
      setState(() {
        officerName = 'Officer';
      });
    }
  }

  Future<void> _fetchRecentComplaint() async {
    try {
      final complaint = await fetchMostRecentComplaint();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Home',
            style: TextStyle(
              color: onPrimaryColor,
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: primaryColor),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome, $officerName',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: onSecondaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            BellProfileWidget(
                              onBellTap: () => _handleBellTap(context),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            GestureDetector(
                              onTap: () => _handleProfileTap(context),
                              child: CircleAvatar(
                                radius: screenWidth * 0.04,
                                child: Icon(Icons.person, size: screenWidth * 0.06),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/officer.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FileComplaintPage()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, screenHeight * 0.005),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/messy.png',
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Noticed a mess?',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    'We\'re on it - File a complaint now!',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: screenWidth * 0.05, color: onSecondaryColor),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: onSecondaryColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HistoryPage()),
                            );
                          },
                          child: Text(
                            'see all',
                            style: TextStyle(
                              color: onSecondaryColor.withOpacity(0.7),
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HistoryPage()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, screenHeight * 0.005),
                            ),
                          ],
                        ),
                        child: isLoadingComplaint
                            ? const Center(child: CircularProgressIndicator())
                            : recentComplaint != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: screenWidth * 0.06, color: onPrimaryColor),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(
                                            recentComplaint?['comp_location'] ?? 'Unknown location',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.w500,
                                              color: onPrimaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Text(
                                        recentComplaint?['comp_desc'] ?? 'No description',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: onPrimaryColor,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(
                                        'Status: ${recentComplaint?['comp_status'] ?? 'Unknown status'}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: onPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      'No recent complaints available',
                                      style: TextStyle(color: onPrimaryColor),
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: secondaryColor,
                child: const OfficerNavBar(currentIndex: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
