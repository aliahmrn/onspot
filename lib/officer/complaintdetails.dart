import 'package:flutter/material.dart';
import 'package:onspot_officer/service/complaintdetails_service.dart';
import 'package:onspot_officer/widget/cleanicons.dart';
import 'package:onspot_officer/widget/constants.dart';

class ComplaintDetailsPage extends StatefulWidget {
  final int complaintId;

  const ComplaintDetailsPage({super.key, required this.complaintId});

  @override
  ComplaintDetailsPageState createState() => ComplaintDetailsPageState();
}

class ComplaintDetailsPageState extends State<ComplaintDetailsPage> {
  Map<String, dynamic>? complaintDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaintDetails();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

Future<void> _loadComplaintDetails() async {
  try {
    final details = await fetchComplaintDetails(widget.complaintId);
    if (!mounted) return; // Ensure the widget is still in the tree
    setState(() {
      complaintDetails = details;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return; // Ensure the widget is still in the tree before using context
    setState(() {
      isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaint details: $e')),
      );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Complaint Details',
          style: TextStyle(
            color: onPrimaryColor,
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
      body: SingleChildScrollView( // <== Wrap Stack in SingleChildScrollView
      child: Container(
        height: screenHeight * 1.5, // <== Adjust height for scrolling
        child: Stack(
        children: [
          // Primary background
          Container(color: primaryColor),

          // Secondary rounded content
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
                        // Location and Date section
                        Positioned(
                          top: screenHeight * 0.03,
                          left: screenWidth * 0.075,
                          right: screenWidth * 0.075,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Location:',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    complaintDetails!['comp_location'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Date:',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    formatDate(complaintDetails!['comp_date']),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Gradient container
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
                                  tertiaryColor,
                                  secondaryColor,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Image container
                        Positioned(
                          top: screenHeight * 0.1,
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
                            child: complaintDetails!['comp_image'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(screenWidth * 0.08),
                                    child: Image.network(
                                      resolveUrl(complaintDetails!['comp_image']),
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
                        // Description, status, and tasks
                        Positioned(
                          top: screenHeight * 0.45,
                          left: screenWidth * 0.075,
                          right: screenWidth * 0.075,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description
                              Center(
                                child: Container(
                                  width: screenWidth * 0.8,
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                  child: Text(
                                    complaintDetails!['comp_desc'] ?? 'No description available.',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),

                              // Tasks
                              Text(
                                'Task included',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
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
                                          MopIcon(size: screenWidth * 0.08),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Mopping',
                                            style: TextStyle(fontSize: screenWidth * 0.04),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          WipeIcon(size: screenWidth * 0.08),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Wiping',
                                            style: TextStyle(fontSize: screenWidth * 0.04),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          WindowIcon(size: screenWidth * 0.08),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            'Organizing',
                                            style: TextStyle(fontSize: screenWidth * 0.04),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              SizedBox(height: screenHeight * 0.02),
                              // Cleaner Section (updated to handle a list of cleaners)
                              Text(
                                'Cleaners',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: onSecondaryColor,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Center(
                                child: Container(
                                  width: screenWidth * 0.8,
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                  child: (complaintDetails!['cleaners'] != null &&
                                          complaintDetails!['cleaners'].isNotEmpty)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: List.generate(
                                            complaintDetails!['cleaners'].length,
                                            (index) {
                                              final cleaner =
                                                  complaintDetails!['cleaners'][index];
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: screenHeight * 0.005),
                                                child: Text(
                                                  ' ${cleaner['cleaner_name'] ?? 'Unassigned'}',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.035,
                                                    color: onSecondaryColor,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            'Unassigned',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: onSecondaryColor,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              // Completed button with dynamic states
                              if (complaintDetails != null)
                                Positioned(
                                  bottom: screenHeight * 0.03,
                                  right: screenWidth * 0.05,
                                  child: ElevatedButton.icon(
                                    onPressed: complaintDetails!['comp_status'] ==
                                                'pending' ||
                                            complaintDetails!['comp_status'] ==
                                                'completed'
                                        ? null // Disable button for "Pending" and "Completed" statuses
                                        : () async {
                                            try {
                                              // Call the completeComplaint function
                                              bool success = await completeComplaint(
                                                  widget.complaintId);

                                              if (!mounted) return;

                                              if (success) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Complaint marked as completed successfully!')),
                                                );

                                                // Refresh complaint details
                                                await _loadComplaintDetails();
                                              }
                                            } catch (e) {
                                              if (!mounted) return;

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to complete complaint: $e')),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          complaintDetails!['comp_status'] ==
                                                  'completed'
                                              ? Colors.green
                                              : complaintDetails!['comp_status'] ==
                                                      'pending'
                                                  ? tertiaryColor
                                                  : primaryColor,
                                      foregroundColor:
                                          complaintDetails!['comp_status'] ==
                                                  'completed'
                                              ? Colors.white
                                              : complaintDetails!['comp_status'] ==
                                                      'pending'
                                                  ? onSecondaryColor
                                                  : onPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(screenWidth * 0.02),
                                      ),
                                    ),
                                    icon: Icon(
                                      complaintDetails!['comp_status'] == 'completed'
                                          ? Icons.check_circle
                                          : complaintDetails!['comp_status'] ==
                                                  'pending'
                                              ? Icons.info
                                              : Icons.check,
                                      size: screenWidth * 0.05,
                                    ),
                                    label: Text(
                                      complaintDetails!['comp_status'] == 'completed'
                                          ? 'Completed'
                                          : complaintDetails!['comp_status'] ==
                                                  'pending'
                                              ? 'Pending'
                                              : 'Complete',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.normal,
                                      ),
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
      ),
      ),
    );
  }
}