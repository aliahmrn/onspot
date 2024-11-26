import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends ConsumerState<NotificationsPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Preload notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).fetchNotifications();
    });
  }

  @override
  void dispose() {
    // Clear focus when the page is disposed
    _focusNode.unfocus();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping anywhere outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor, // Sets the background color
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Sets the title color to white
            ),
          ),
          centerTitle: true, // Centers the title
          iconTheme: const IconThemeData(
            color: Colors.white, // Sets the back arrow color to white
          ),
        ),
        body: Stack(
          children: [
            // Top blue section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.2,
              child: Container(
                color: primaryColor,
              ),
            ),
            // Rounded white bottom section
            Positioned(
              top: screenHeight * 0.18,
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
              ),
            ),
            notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.18), // Matches the top blue section
                        const CircularProgressIndicator(), // Loading spinner
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.06),
                        topRight: Radius.circular(screenWidth * 0.06),
                      ),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(
                          DateTime.parse(notification['created_at']),
                        );

                        return Padding(
                          padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: screenWidth * 0.02,
                                  spreadRadius: screenWidth * 0.003,
                                  offset: Offset(0, screenHeight * 0.003),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.notifications, color: Colors.white),
                                        SizedBox(width: screenWidth * 0.03),
                                        Text(
                                          notification['title'] ?? 'Notification',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                            color: onPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: onPrimaryColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                const Divider(thickness: 1, color: Colors.white24),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  notification['body'] ?? 'No details provided',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: onPrimaryColor.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
