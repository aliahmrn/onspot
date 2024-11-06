import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'assign_task.dart';
import '../service/complaints_service.dart';


class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  ComplaintPageState createState() => ComplaintPageState();
}

class ComplaintPageState extends State<ComplaintPage> {
  final ComplaintsService complaintsService = ComplaintsService();

  Future<void> _refreshComplaints() async {
    setState(() {}); // Trigger a rebuild to fetch updated complaints
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
        automaticallyImplyLeading: false, // Removes the back arrow
        centerTitle: true,
        title: Text(
          'Complaints',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
            color: onPrimaryColor,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: complaintsService.fetchComplaints(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No complaints yet.'));
            }

            final complaints = snapshot.data!;
            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                final timeString = complaint['comp_time']!;
                final DateTime time = DateTime.parse('1970-01-01 $timeString');
                final String formattedTime = DateFormat('HH:mm').format(time);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Container(
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
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Complaint',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: onPrimaryColor,
                              ),
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
                        Text(
                          complaint['comp_desc']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: onPrimaryColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Date: ${complaint['comp_date']!}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: onPrimaryColor.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => AssignTaskPage(complaintId: complaint['id'].toString()),
                                  transitionDuration: Duration.zero, // No transition animation
                                  reverseTransitionDuration: Duration.zero, // No reverse transition animation
                                ),
                              );
                              _refreshComplaints();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                              backgroundColor: onPrimaryColor,
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                            ),
                            child: Text(
                              'Assign',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
