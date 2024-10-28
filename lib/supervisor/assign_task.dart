import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/complaints_service.dart';

class AssignTaskPage extends StatefulWidget {
  final String complaintId;

  const AssignTaskPage({super.key, required this.complaintId});

  @override
  _AssignTaskPageState createState() => _AssignTaskPageState();
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  Map<String, dynamic>? complaintDetails;
  bool isLoading = true;
  String? error;
  String? selectedNumOfCleaners;
  List<Map<String, dynamic>> availableCleaners = [];
  List<String?> selectedCleaners = [];
  String? assignedBy;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    assignedBy = prefs.getString('supervisorId');
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      final data = await ComplaintsService().getComplaintDetails(widget.complaintId);
      setState(() {
        complaintDetails = data;
        availableCleaners = List<Map<String, dynamic>>.from(data['available_cleaners']);
        isLoading = false;
      });
    } catch (e, stacktrace) {
      print('Error fetching complaint details: $e');
      print('Stacktrace: $stacktrace');
      setState(() {
        error = 'Error fetching complaint details: $e';
        isLoading = false;
      });
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
      print("Error: Supervisor ID not available.");
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
      print("Task assigned successfully.");

      // Show confirmation dialog and navigate back
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Task assigned successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to complaints page
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error assigning task: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFEF7FF),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const SizedBox(
          width: double.infinity,
          child: Center(
            child: Text(
              'Assign Complaint',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : complaintDetails != null
                  ? _buildComplaintDetails(complaintDetails!)
                  : Center(child: Text('No data available')),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }

  Widget _buildComplaintDetails(Map<String, dynamic> data) {
    String formattedDate = DateFormat.yMMMMd().format(DateTime.parse(data['comp_date']));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              ),
              child: Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Location: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      data['comp_location'] ?? 'No Location',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Date: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'Description: ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  TextSpan(
                    text: data['comp_desc'],
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: "Complaint by: ",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: data['officer_name'],
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF92AEB9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                      child: Text(
                        'Number of Cleaner',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedNumOfCleaners,
                            hint: const Text('Select number of cleaner'),
                            onChanged: _onNumberOfCleanersChanged,
                            items: List.generate(10, (index) => (index + 1).toString())
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedNumOfCleaners != null)
              for (int i = 0; i < int.parse(selectedNumOfCleaners!); i++)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF92AEB9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                          child: Text(
                            'Cleaner ${i + 1}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedCleaners.length > i ? selectedCleaners[i] : null,
                                      hint: const Text('Select cleaner'),
                                      onChanged: (String? newValue) {
                                        if (newValue != 'No cleaner available for now') {
                                          _onCleanerSelected(i, newValue);
                                        }
                                      },
                                      items: _getAvailableCleaners(i)
                                          .map<DropdownMenuItem<String>>((String cleaner) {
                                        return DropdownMenuItem<String>(
                                          value: cleaner,
                                          child: Text(cleaner),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _assignTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF92AEB9),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Assign Complaint',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskIcon(IconData iconData, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Icon(iconData, size: 40),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
