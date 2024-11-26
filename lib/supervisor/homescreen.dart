import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';
import '../widget/bell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/navigation_provider.dart';
import '../supervisor/notifications.dart';


class SupervisorHomeScreen extends ConsumerWidget {
 const SupervisorHomeScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;

    // Watch Riverpod providers
    final complaintsState = ref.watch(complaintsProvider);
    final latestComplaint = ref.watch(latestComplaintProvider);

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
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<String>(
                        future: _getUserName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Welcome!',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            );
                          }
                          return Text(
                            'Welcome, ${snapshot.data}!',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          BellProfileWidget(onBellTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const NotificationsPage(),
                                transitionDuration: Duration.zero, // No forward animation
                                reverseTransitionDuration: Duration.zero, // No backward animation
                              ),
                            );
                          }),
                          SizedBox(width: screenWidth * 0.02),
                          GestureDetector(
                            onTap: () {
                              ref.read(currentIndexProvider.notifier).state = 4; // Set to Profile Page index
                            },
                            child: const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/user.jpg'),
                              radius: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Welcome Icon
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/homeicon.svg',
                      height: screenHeight * 0.25,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Complaints Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complaints',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: onSecondaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(currentIndexProvider.notifier).state = 2; // Set to Complaints Page index
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: onSecondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w500,
                                  color: onSecondaryColor,
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: screenWidth * 0.035, color: onSecondaryColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Divider
                  Divider(color: Colors.grey.withOpacity(0.5)),

                  // Complaints Section
                  complaintsState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Failed to load complaints: $e')),
                    data: (_) {
                      if (latestComplaint == null) {
                        return Center(
                          child: Text(
                            'No complaints available.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: onPrimaryColor,
                            ),
                          ),
                        );
                      }

                      // Format complaint time
                      final timeString = latestComplaint['comp_time']!;
                      final DateTime time = DateTime.parse('1970-01-01 $timeString');
                      final String formattedTime = DateFormat('HH:mm').format(time);

                      return GestureDetector(
                        onTap: () {
                          // Redirect to Complaints Page
                          ref.read(currentIndexProvider.notifier).state = 2; // Complaints Page index
                        },
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            border: Border.all(color: onPrimaryColor.withOpacity(0.2), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: screenWidth * 0.003,
                                blurRadius: screenWidth * 0.02,
                                offset: Offset(0, screenHeight * 0.003),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location and Time Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 18, color: Colors.white),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        latestComplaint['comp_location'] ?? 'No Location',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.bold,
                                          color: onPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: onPrimaryColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              const Divider(thickness: 1, color: Colors.white24),
                              SizedBox(height: screenHeight * 0.01),

                              // Complaint Description
                              Row(
                                children: [
                                  const Icon(Icons.description, size: 18, color: Colors.white),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(
                                    child: Text(
                                      latestComplaint['comp_desc'] ?? 'No Description',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: onPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),

                              // Complaint Date
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(DateTime.parse(latestComplaint['comp_date']!)),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: onPrimaryColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'Supervisor';
  }
}
