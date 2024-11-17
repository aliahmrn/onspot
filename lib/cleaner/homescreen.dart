import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'notifications.dart';
import 'profile.dart';
import '../widget/bell.dart';
import 'navbar.dart';
import 'task.dart';
import '../service/task_service.dart';

class CleanerHomeScreen extends StatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  _CleanerHomeScreenState createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends State<CleanerHomeScreen> {
  bool isChecked = false;
  Map<String, dynamic>? latestTask;
  String? error;
  bool isLoading = true; // Loading state
  final TaskService taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _fetchLatestTask();
  }

  Future<void> _fetchLatestTask() async {
    try {
      final tasks = await taskService.getCleanerTasks(69); // Replace 69 with the actual cleaner ID
      setState(() {
        latestTask = tasks != null && tasks.isNotEmpty ? tasks.first : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load latest task: $e';
        isLoading = false;
      });
    }
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
            fontSize: screenWidth * 0.05,
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
            bottom: 0,
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
                        'Welcome, Cleaner',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
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
                              child: Icon(Icons.person, size: screenWidth * 0.05),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/welcome.svg',
                      height: screenHeight * 0.25,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Task',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: onSecondaryColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : error != null
                          ? Center(child: Text(error!))
                          : latestTask != null
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CleanerTasksScreen(),
                                      ),
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
                                              latestTask!['comp_location'] ?? 'No Location',
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
                                          latestTask!['comp_desc'] ?? 'No Description',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.bold,
                                            color: onPrimaryColor,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: screenWidth * 0.05, color: onPrimaryColor),
                                            SizedBox(width: screenWidth * 0.02),
                                            Text(
                                              latestTask!['comp_date'] ?? 'N/A',
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
                              : Center(
                                  child: Text(
                                    'No recent tasks available.',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: onPrimaryColor,
                                    ),
                                  ),
                                ),
                ],
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
                child: CleanerBottomNavBar(currentIndex: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
