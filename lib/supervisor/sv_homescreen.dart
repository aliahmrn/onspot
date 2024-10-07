import 'package:flutter/material.dart';
import 'sv_history.dart';
import 'sv_profile.dart';
import 'sv_navbar.dart'; // Import the SupervisorBottomNavBar widget
import '../bell_profile_widget.dart'; // Import the BellProfileWidget
import 'package:flutter_svg/flutter_svg.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  _SupervisorHomeScreenState createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SVProfilePage()),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _navigateToHistoryFromCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color to #FEF7FF
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(),
          child: AppBar(
            elevation: 0, // No internal elevation
            backgroundColor: Colors
                .transparent, // Transparent to show the container's background
            automaticallyImplyLeading: false, // Remove the back button
            title: Text(
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, Supervisor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      BellProfileWidget(
                        onBellTap:
                            _navigateToHistory, // Navigate to history on bell tap
                      ),
                      GestureDetector(
                        onTap:
                            _navigateToProfile, // Navigate to ProfilePage on tap
                        child: CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/profile.jpg'),
                          radius: 20,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome_vacuum.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Complaint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _navigateToHistoryFromCard,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF92AEB9), // Color for the complaint card
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Shadow effect
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment
                            .topRight, // Align the time to the top right
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.place,
                                size: 30,
                                color: Colors.black, // Icon color
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Floor 2',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors
                                      .white, // Matching the white text color
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            child: const Text(
                              '9:41 AM', // Static time
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3c6576), // Time color
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Room Cleaning',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold, // Bold text for Room Cleaning
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/calendar.svg', // Ensure the path is correct
                            height: 24, // Adjust icon size as needed
                            color: Colors.black, // Makes the icon black
                          ),
                          const SizedBox(
                              width: 8), // Space between icon and text
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white, // Matching white text color
                            ),
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
      bottomNavigationBar: SupervisorBottomNavBar(
        currentIndex: 0, // Set current index to 0 for Home screen
      ),
    );
  }
}
