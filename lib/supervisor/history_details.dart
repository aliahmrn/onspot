import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';

class TaskDetailsPage extends ConsumerWidget {
  final String complaintId;

  const TaskDetailsPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskDetailsAsync = ref.watch(taskDetailsProvider(complaintId));

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
      body: taskDetailsAsync.when(
        loading: () => Center(
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
        ),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        data: (taskDetails) {
          return _buildTaskDetailsContent(
            screenWidth,
            screenHeight,
            primaryColor,
            secondaryColor,
            taskDetails,
            context,
          );
        },
      ),
    );
  }

  Widget _buildTaskDetailsContent(
    double screenWidth,
    double screenHeight,
    Color primaryColor,
    Color secondaryColor,
    Map<String, dynamic> taskDetails,
    BuildContext context,
  ) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(taskDetails['comp_date']));
    final formattedAssignedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(taskDetails['assigned_date']));

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.885,
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
                  children: [
                    Icon(Icons.info, color: primaryColor, size: screenWidth * 0.06),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        icon: Icons.description,
                        label: 'Description',
                        value: taskDetails['comp_desc'] ?? 'No Description',
                        screenWidth: screenWidth,
                        textColor: secondaryColor,
                      ),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: taskDetails['comp_location'] ?? 'No Location',
                        screenWidth: screenWidth,
                        textColor: secondaryColor,
                      ),
                      _buildInfoRow(
                        icon: Icons.person,
                        label: 'Complaint by',
                        value: taskDetails['officer_name'] ?? 'Unknown Officer',
                        screenWidth: screenWidth,
                        textColor: secondaryColor,
                      ),
                      _buildInfoRow(
                        icon: Icons.date_range,
                        label: 'Date of Complaint',
                        value: formattedDate,
                        screenWidth: screenWidth,
                        textColor: secondaryColor,
                      ),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Assigned Date',
                        value: formattedAssignedDate,
                        screenWidth: screenWidth,
                        textColor: secondaryColor,
                      ),
                      _buildStatusRow(
                        icon: Icons.assignment_turned_in,
                        label: 'Status',
                        status: taskDetails['comp_status'] ?? 'Unknown',
                        screenWidth: screenWidth,
                        textColor: secondaryColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    Icon(Icons.people, color: primaryColor, size: screenWidth * 0.06),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Assigned Cleaners',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                _buildCleanersList(
                  screenWidth,
                  primaryColor,
                  secondaryColor,
                  Theme.of(context).colorScheme.onPrimary,
                  taskDetails,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
    required Color textColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        children: [
          Icon(icon, color: textColor.withOpacity(0.7), size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String status,
    required double screenWidth,
    required Color textColor,
  }) {
    Color statusColor = _getStatusColor(status);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        children: [
          Icon(icon, color: textColor.withOpacity(0.7), size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
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
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanersList(
    double screenWidth,
    Color primaryColor,
    Color secondaryColor,
    Color onPrimaryColor,
    Map<String, dynamic> taskDetails,
  ) {
    final cleaners = taskDetails['assigned_cleaners'] as List<dynamic>;

    if (cleaners.isEmpty) {
      return Text(
        'No cleaners assigned.',
        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black),
      );
    }

    return Column(
      children: cleaners.map<Widget>((cleaner) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03, horizontal: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: secondaryColor,
                child: Text(
                  cleaner['cleaner_name']?.substring(0, 1).toUpperCase() ?? '?',
                  style: TextStyle(fontSize: screenWidth * 0.045, color: primaryColor),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  cleaner['cleaner_name'] ?? 'Unknown Cleaner',
                  style: TextStyle(fontSize: screenWidth * 0.045, color: onPrimaryColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase() == 'completed') return Colors.green;
    if (status.toLowerCase() == 'ongoing') return Colors.blue;
    if (status.toLowerCase() == 'pending') return Colors.orange;
    return Colors.red;
  }
}
