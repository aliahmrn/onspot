import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/complaints_service.dart';

class TaskDetailsPage extends StatefulWidget {
  final String complaintId;

  const TaskDetailsPage({super.key, required this.complaintId});

  @override
  TaskDetailsPageState createState() => TaskDetailsPageState();
}

class TaskDetailsPageState extends State<TaskDetailsPage> {
  Map<String, dynamic>? taskDetails;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    try {
      final data = await ComplaintsService().fetchAssignedTaskDetails(widget.complaintId);
      setState(() {
        taskDetails = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load task details: $e';
        isLoading = false;
      });
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'History Details',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.06),
                    topRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                width: screenWidth,
                height: screenHeight,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            )
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.black)))
              : taskDetails != null
                  ? _buildTaskDetailsContent(screenWidth, screenHeight, primaryColor, secondaryColor)
                  : const Center(child: Text('No data available', style: TextStyle(color: Colors.black))),
    );
  }

  Widget _buildTaskDetailsContent(double screenWidth, double screenHeight, Color primaryColor, Color secondaryColor) {
    final formattedDate = DateFormat.yMMMMd().format(DateTime.parse(taskDetails!['comp_date']));
    final formattedTime = DateFormat.jm().format(DateTime.parse("1970-01-01 ${taskDetails!['comp_time']}"));

    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.06),
          topRight: Radius.circular(screenWidth * 0.06),
        ),
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task details displayed without a card container
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.description,
                  label: 'Description',
                  value: taskDetails!['comp_desc'] ?? 'No Description',
                  screenWidth: screenWidth,
                ),
                _buildDivider(screenWidth),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: taskDetails!['comp_location'] ?? 'No Location',
                  screenWidth: screenWidth,
                ),
                _buildDivider(screenWidth),
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Complaint by',
                  value: taskDetails!['officer_name'] ?? 'Unknown Officer',
                  screenWidth: screenWidth,
                ),
                _buildDivider(screenWidth),
                _buildInfoRow(
                  icon: Icons.date_range,
                  label: 'Date Of Complaint',
                  value: formattedDate,
                  screenWidth: screenWidth,
                ),
                _buildDivider(screenWidth),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Complaint Time',
                  value: formattedTime,
                  screenWidth: screenWidth,
                ),
                _buildDivider(screenWidth),
                _buildInfoRow(
                  icon: Icons.people,
                  label: 'Number of Cleaners',
                  value: '${taskDetails!['no_of_cleaners']}',
                  screenWidth: screenWidth,
                ),
                _buildDivider(screenWidth),
                _buildStatusRow(
                  icon: Icons.assignment_turned_in,
                  label: 'Status',
                  status: taskDetails!['comp_status'] ?? 'Unknown',
                  screenWidth: screenWidth,
                ),
                _buildDivider(screenWidth),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Assigned Date',
                  value: DateFormat.yMMMMd().format(
                    DateTime.parse(taskDetails!['assigned_date'] ?? DateTime.now().toString()),
                  ),
                  screenWidth: screenWidth,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Assigned Cleaners',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            _buildCleanersList(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value, required double screenWidth}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black.withOpacity(0.7), size: screenWidth * 0.05),
        SizedBox(width: screenWidth * 0.025),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w600),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                value,
                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow({required IconData icon, required String label, required String status, required double screenWidth}) {
    Color statusColor;
    if (status.toLowerCase() == 'completed') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'ongoing') {
      statusColor = Colors.blue;
    } else if (status.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Row(
      children: [
        Icon(icon, color: statusColor.withOpacity(0.7), size: screenWidth * 0.05),
        SizedBox(width: screenWidth * 0.025),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: screenWidth * 0.04, color: statusColor.withOpacity(0.7), fontWeight: FontWeight.w600),
              ),
              SizedBox(height: screenWidth * 0.01),
              Container(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015, horizontal: screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
      child: Divider(
        color: Colors.grey[300],
        thickness: 1,
      ),
    );
  }

  Widget _buildCleanersList(double screenWidth) {
    final cleaners = taskDetails!['assigned_cleaners'] as List<dynamic>;
    if (cleaners.isEmpty) {
      return Text(
        'No cleaners assigned.',
        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cleaners.map<Widget>((cleaner) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03, horizontal: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.teal, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.025),
              Expanded(
                child: Text(
                  cleaner['cleaner_name'] ?? 'Unknown Cleaner',
                  style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
