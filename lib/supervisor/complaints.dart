import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'assign_task.dart';
import '../providers/complaints_provider.dart';

class ComplaintPage extends ConsumerWidget {
  const ComplaintPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(complaintsProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        child: complaintsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (complaints) {
            if (complaints.isEmpty) {
              return const Center(child: Text('No complaints yet.'));
            }

            // Sort complaints by date in descending order
            complaints.sort((a, b) {
              DateTime dateA = DateTime.parse(a['comp_date']);
              DateTime dateB = DateTime.parse(b['comp_date']);
              return dateB.compareTo(dateA);
            });

            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                final timeString = complaint['comp_time']!;
                final DateTime time = DateTime.parse('1970-01-01 $timeString');
                final String formattedTime = DateFormat('HH:mm').format(time);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.007),
                  child: Container(
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
                    padding: EdgeInsets.all(screenWidth * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Complaint title and time
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
                        const Divider(
                          thickness: 1,
                          color: Colors.white24,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Complaint description
                        Text(
                          complaint['comp_desc']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: onPrimaryColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Complaint date
                        Text(
                          'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(complaint['comp_date']!))}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: onPrimaryColor.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Assign button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => AssignTaskPage(
                                    complaintId: complaint['id'].toString(),
                                  ),
                                  transitionDuration: Duration.zero, // No transition animation
                                  reverseTransitionDuration: Duration.zero, // No reverse transition animation
                                ),
                              );
                              ref.invalidate(complaintsProvider); // Refresh complaints after assigning
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.015,
                              ),
                              backgroundColor: onPrimaryColor,
                              foregroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.assignment, size: 18),
                                const SizedBox(width: 5),
                                Text(
                                  'Assign',
                                  style: TextStyle(fontSize: screenWidth * 0.04),
                                ),
                              ],
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
