import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../service/complaints_service.dart';

class AssignTaskPage extends StatefulWidget {
  final String complaintId;

  const AssignTaskPage({super.key, required this.complaintId});

  @override
  AssignTaskPageState createState() => AssignTaskPageState();
}

class AssignTaskPageState extends State<AssignTaskPage> {
  Map<String, dynamic>? complaintDetails;
  bool isLoading = true;
  String? error;
  String? selectedNumOfCleaners;
  List<Map<String, dynamic>> availableCleaners = [];
  List<String?> selectedCleaners = [];
  String? assignedBy;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _fetchSupervisorId();
    await _fetchComplaintDetails();
  }

  Future<void> _fetchSupervisorId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    assignedBy = prefs.getString('supervisorId');
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      final data = await ComplaintsService().getComplaintDetails(widget.complaintId);
      if (mounted) {
        setState(() {
          complaintDetails = data;
          availableCleaners = List<Map<String, dynamic>>.from(data['available_cleaners']);
          isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching complaint details: $e');
      if (mounted) {
        setState(() {
          error = 'Error fetching complaint details: $e';
          isLoading = false;
        });
      }
    }
  }

  void _onNumberOfCleanersChanged(String? value) {
    setState(() {
      selectedNumOfCleaners = value;
      int numCleaners = int.tryParse(value ?? '1') ?? 1;

      if (numCleaners > selectedCleaners.length) {
        selectedCleaners.addAll(List<String?>.filled(numCleaners - selectedCleaners.length, null));
      } else {
        selectedCleaners = selectedCleaners.sublist(0, numCleaners);
      }
    });
  }

  void _onCleanerSelected(int index, String? cleaner) {
    setState(() {
      selectedCleaners[index] = cleaner;
    });
  }

  List<String> _getAvailableCleaners(int index) {
    final available = availableCleaners
        .map((cleaner) => cleaner['cleaner_name'] as String)
        .where((cleaner) => !selectedCleaners.contains(cleaner) || selectedCleaners[index] == cleaner)
        .toList();
    return available.isEmpty ? ['No cleaner available for now'] : available;
  }

  Future<void> _assignTask() async {
    if (assignedBy == null) {
      _logger.e("Error: Supervisor ID not available.");
      return;
    }

    final cleanerIds = selectedCleaners
        .where((cleanerName) => cleanerName != null)
        .map((cleanerName) {
          final cleaner = availableCleaners.firstWhere(
            (element) => element['cleaner_name'] == cleanerName,
            orElse: () => {},
          );
          return cleaner['cleaner_id'];
        })
        .where((id) => id != null)
        .toList();

    final body = {
      'cleaner_ids': cleanerIds,
      'no_of_cleaners': int.parse(selectedNumOfCleaners ?? '1'),
      'assigned_by': assignedBy,
    };

    try {
      await ComplaintsService().assignTask(widget.complaintId, body);
      _logger.i("Task assigned successfully.");

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Task assigned successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context, true); // Pass `true` as the result when navigating back
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _logger.e("Error assigning task: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to assign task: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
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
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Assign Task',
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : complaintDetails != null
                    ? _buildComplaintDetailsContent(screenWidth, screenHeight, primaryColor, secondaryColor)
                    : const Center(child: Text('No data available')),
      ),
    );
  }

  Widget _buildComplaintDetailsContent(double screenWidth, double screenHeight, Color primaryColor, Color secondaryColor) {
    final formattedDate = DateFormat.yMMMMd().format(DateTime.parse(complaintDetails!['comp_date']));
    final String? imageUrl = complaintDetails!['comp_image_url'];

    final bool isAssignButtonEnabled = availableCleaners.isNotEmpty;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: screenWidth * 0.005,
            blurRadius: screenWidth * 0.03,
            offset: Offset(0, screenWidth * 0.005),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey[300]),
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.location_on, 'Location', complaintDetails!['comp_location'] ?? 'No Location'),
            _buildDetailRow(Icons.date_range, 'Date', formattedDate),
            _buildDetailRow(Icons.description, 'Description', complaintDetails!['comp_desc']),
            const SizedBox(height: 20),
            Text(
              'Number of Cleaners',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedNumOfCleaners,
              hint: const Text('Select number'),
              onChanged: isAssignButtonEnabled ? _onNumberOfCleanersChanged : null,
              items: List.generate(10, (index) => (index + 1).toString())
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < int.parse(selectedNumOfCleaners ?? '1'); i++)
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCleaners.length > i ? selectedCleaners[i] : null,
                hint: const Text('Select cleaner'),
                onChanged: isAssignButtonEnabled ? (String? newValue) {
                  if (newValue != 'No cleaner available for now') {
                    _onCleanerSelected(i, newValue);
                  }
                } : null,
                items: _getAvailableCleaners(i).map<DropdownMenuItem<String>>((String cleaner) {
                  return DropdownMenuItem<String>(
                    value: cleaner,
                    child: Text(cleaner),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isAssignButtonEnabled ? _assignTask : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  backgroundColor: isAssignButtonEnabled ? primaryColor : Colors.grey, // Change color based on availability
                  foregroundColor: secondaryColor,
                ),
                child: Text(
                  isAssignButtonEnabled ? 'Assign Task' : 'No Cleaners Available',
                  style: TextStyle(
                    color: isAssignButtonEnabled ? Theme.of(context).colorScheme.onPrimary : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 16),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
