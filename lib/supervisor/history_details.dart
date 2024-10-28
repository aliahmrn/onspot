import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/complaints_service.dart';

class TaskDetailsPage extends StatefulWidget {
  final String complaintId;

  const TaskDetailsPage({super.key, required this.complaintId});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Complaint Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : taskDetails != null
                  ? _buildTaskDetailsContent()
                  : const Center(child: Text('No data available')),
    );
  }

  Widget _buildTaskDetailsContent() {
    final formattedDate = DateFormat.yMMMMd().format(DateTime.parse(taskDetails!['comp_date']));
    final formattedTime = DateFormat.jm().format(DateTime.parse("1970-01-01 ${taskDetails!['comp_time']}"));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            color: const Color(0xFFF5F5F5),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(icon: Icons.description, label: 'Description', value: taskDetails!['comp_desc'] ?? 'No Description'),
                  _buildDivider(),
                  _buildInfoRow(icon: Icons.location_on, label: 'Location', value: taskDetails!['comp_location'] ?? 'No Location'),
                  _buildDivider(),
                  _buildInfoRow(icon: Icons.person, label: 'Complaint by', value: taskDetails!['officer_name'] ?? 'Unknown Officer'),
                  _buildDivider(),
                  _buildInfoRow(icon: Icons.date_range, label: 'Date Of Complaint', value: formattedDate),
                  _buildDivider(),
                  _buildInfoRow(icon: Icons.access_time, label: 'Complaint Time', value: formattedTime),
                  _buildDivider(),
                  _buildInfoRow(icon: Icons.people, label: 'Number of Cleaners', value: '${taskDetails!['no_of_cleaners']}'),
                  _buildDivider(),
                  _buildInfoRow(icon: Icons.assignment_turned_in, label: 'Status', value: taskDetails!['comp_status'] ?? 'Unknown'),
                  _buildDivider(),
                  _buildInfoRow(icon: Icons.calendar_today, label: 'Assigned Date', value: DateFormat.yMMMMd().format(DateTime.parse(taskDetails!['assigned_date'] ?? DateTime.now().toString()))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Assigned Cleaners',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          _buildCleanersList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: Colors.grey[300],
        thickness: 1,
      ),
    );
  }

  Widget _buildCleanersList() {
    final cleaners = taskDetails!['assigned_cleaners'] as List<dynamic>;
    if (cleaners.isEmpty) {
      return const Text('No cleaners assigned.', style: TextStyle(fontSize: 14, color: Colors.black));
    }

    return Column(
      children: cleaners.map<Widget>((cleaner) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E5E8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cleaner['cleaner_name'] ?? 'Unknown Cleaner',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
