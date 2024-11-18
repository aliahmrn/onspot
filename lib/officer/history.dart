import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onspot_officer/service/history_service.dart';
import 'navbar.dart';
import 'complaintdetails.dart';
import 'package:onspot_officer/widget/date.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];
  bool hasFetchedData = false;

  @override
  void initState() {
    super.initState();
    _loadComplaintHistory();
  }

  Future<void> _loadComplaintHistory() async {
    try {
      List<dynamic> data = await fetchComplaintHistory();
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        historyData = data;
        hasFetchedData = true;
      });
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        hasFetchedData = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: $e')),
      );
    }
  }

  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '';
    }
    try {
      final time = DateFormat('HH:mm:ss').parse(timeString);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return '';
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Complaint sent!';
      case 'ongoing':
        return 'Complaint in progress...';
      case 'completed':
        return 'Complaint resolved!';
      default:
        return 'Unknown status';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.06),
            topRight: Radius.circular(screenWidth * 0.06),
          ),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: hasFetchedData
            ? (historyData.isEmpty
                ? const Center(child: Text('No complaints found'))
                : ListView.builder(
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final complaint = historyData[index];
                      final complaintId = complaint['id'];

                      return Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: screenWidth * 0.005,
                                    blurRadius: screenWidth * 0.03,
                                    offset: Offset(0, screenHeight * 0.005),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.history,
                                            color: onPrimaryColor.withOpacity(0.7),
                                            size: screenWidth * 0.05,
                                          ),
                                          SizedBox(width: screenWidth * 0.025),
                                          Text(
                                            getStatusText(complaint['comp_status'] ?? 'unknown'),
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: onPrimaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatTime(complaint['comp_time']),
                                        style: TextStyle(
                                          color: onPrimaryColor.withOpacity(0.7),
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    complaint['comp_desc'] ?? '',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: onPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Text(
                                    formatDate(complaint['comp_date']),
                                    style: TextStyle(
                                      color: onPrimaryColor.withOpacity(0.7),
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: screenHeight * 0.01,
                              right: screenWidth * 0.02,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward, color: onPrimaryColor),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ComplaintDetailsPage(complaintId: complaintId),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ))
            : const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: const OfficerNavBar(currentIndex: 2),
    );
  }
}
