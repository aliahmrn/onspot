import 'package:flutter/material.dart';
import 'package:onspot_cleaner/widget/cleanicons.dart'; // Import custom icons
import 'package:intl/intl.dart';

class TaskDetailsPage extends StatefulWidget {
  final int complaintId;
  final String location;
  final String date;
  final String? imageUrl;
  final String description;

  const TaskDetailsPage({
    super.key,
    required this.complaintId,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.description,
  });

  @override
  TaskDetailsPageState createState() => TaskDetailsPageState();
}

class TaskDetailsPageState extends State<TaskDetailsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Task Details',
          style: TextStyle(
            color: onPrimaryColor,  // Changed to onSecondaryColor
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onPrimaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Primary background layer
          Container(color: primaryColor),

          // Secondary layer for rounded content area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.08),
                  topRight: Radius.circular(screenWidth * 0.08),
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        Positioned(
                          top: screenHeight * 0.03,
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on, // Location icon
                                        color: onSecondaryColor,
                                        size: screenWidth * 0.05, // Adjust size based on screen
                                      ),
                                      SizedBox(width: screenWidth * 0.025),
                                      Text(
                                        'Location:',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: onSecondaryColor,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.025),
                                      Text(
                                        widget.location,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: onSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today, // Date icon
                                        color: onSecondaryColor,
                                        size: screenWidth * 0.05, // Adjust size based on screen
                                      ),
                                      SizedBox(width: screenWidth * 0.025),
                                      Text(
                                        'Date:',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: onSecondaryColor,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.025),
                                      Text(
                                        _formatDate(widget.date), // Format the date
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: onSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.28,
                          left: screenWidth * 0.075,
                          right: screenWidth * 0.075,
                          child: Container(
                            width: screenWidth * 0.85,
                            height: screenHeight * 0.6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(screenWidth * 0.04),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  primaryColor,
                                  secondaryColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.15,
                          left: screenWidth * 0.075,
                          right: screenWidth * 0.075,
                          child: Container(
                            width: screenWidth * 0.9,
                            height: screenHeight * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(screenWidth * 0.08),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: screenWidth * 0.02,
                                  offset: Offset(0, screenHeight * 0.005),
                                ),
                              ],
                            ),
                            child: widget.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(screenWidth * 0.08),
                                    child: Image.network(
                                      widget.imageUrl!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            'Image failed to load',
                                            style: TextStyle(color: onSecondaryColor),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      'No image available',
                                      style: TextStyle(color: onSecondaryColor),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.48, // Adjusted to be closer to the image container
                          left: screenWidth * 0.075,
                          right: screenWidth * 0.075,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Add "Description" heading
                              Text(
                                '  Description',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045, // Slightly larger font for the heading
                                  fontWeight: FontWeight.bold,
                                  color: onSecondaryColor, // Matches the secondary text color
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01), // Spacing between heading and box

                              Center(
                                child: Container(
                                  width: screenWidth * 0.8,
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: screenWidth * 0.02,
                                        offset: Offset(0, screenHeight * 0.005),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget.description,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02), // Adjusted for closer spacing

                              // Task included section remains as it is
                              Text(
                                '  Task included',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: onSecondaryColor,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Center(
                                child: Container(
                                  width: screenWidth * 0.8,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          MopIcon(size: screenWidth * 0.08), // Custom mop icon
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Mopping',
                                            style: TextStyle(fontSize: screenWidth * 0.04),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          VacuumingIcon(size: screenWidth * 0.08), // Custom vacuuming icon
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Vacuuming',
                                            style: TextStyle(fontSize: screenWidth * 0.04),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          WipeIcon(size: screenWidth * 0.08), // Custom wiping icon
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Wiping',
                                            style: TextStyle(fontSize: screenWidth * 0.04),
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
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

    String _formatDate(String? rawDate) {
    if (rawDate == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(rawDate); // Parse raw date string
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Format to DD/MM/YYYY
    } catch (e) {
      return 'Invalid Date'; // Fallback in case of error
    }
  }
}
