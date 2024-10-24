import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import for date/time formatting
import '../service/complaints_service.dart'; // Import the service
import 'package:shared_preferences/shared_preferences.dart';

class AssignTaskPage extends StatefulWidget {
  final String complaintId;

  const AssignTaskPage({super.key, required this.complaintId}); // Receive complaintId

  @override
  _AssignTaskPageState createState() => _AssignTaskPageState();
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  Map<String, dynamic>? complaintDetails;  // Holds the fetched data
  bool isLoading = true;                   // Track loading state
  String? error;                           // Track any error
  String? selectedNumOfCleaners;           // Holds the selected number of cleaners
  List<String> availableCleaners = [];     // List of available cleaners
  List<String?> selectedCleaners = [];     // Holds selected cleaners
  String? supervisorId;
  

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();  // Call the function to fetch data
    _getSupervisorId();  // Fetch supervisor ID
  }
    // Function to fetch supervisor ID from SharedPreferences
  Future<void> _getSupervisorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      supervisorId = prefs.getString('svId');
    });
  }

  // Function to fetch complaint details from the backend
  Future<void> _fetchComplaintDetails() async {
    try {
      final data = await ComplaintsService().getComplaintDetails(widget.complaintId);
      setState(() {
        complaintDetails = data;
        availableCleaners = List<String>.from(data['available_cleaners']); // Load available cleaners
        isLoading = false;  // Data has been fetched, stop loading
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching complaint details: $e';
        isLoading = false;  // Stop loading in case of an error
      });
    }
  }

  // Function to handle changes in the number of cleaners
  void _onNumberOfCleanersChanged(String? value) {
    setState(() {
      selectedNumOfCleaners = value;
      int numCleaners = int.tryParse(value!) ?? 1;

      // Resize the selectedCleaners list to match the number of cleaners selected
      if (numCleaners > selectedCleaners.length) {
        selectedCleaners.addAll(List<String?>.filled(numCleaners - selectedCleaners.length, null));
      } else {
        selectedCleaners = selectedCleaners.sublist(0, numCleaners);
      }
    });
  }

  // Function to handle changes in cleaner selection for each dropdown
  void _onCleanerSelected(int index, String? cleaner) {
    setState(() {
      selectedCleaners[index] = cleaner;
    });
  }

  // Function to get available cleaners for each dropdown, excluding already selected ones
  List<String> _getAvailableCleaners(int index) {
    return availableCleaners.where((cleaner) => !selectedCleaners.contains(cleaner) || selectedCleaners[index] == cleaner).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFEF7FF), // Changed AppBar color
        foregroundColor: Colors.black, // Adjusted foreground color for contrast
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const SizedBox(
          width: double.infinity, // Make it take the full width
          child: Center(
            // Center the title
            child: Text(
              'Assign Task',
              style: TextStyle(
                fontWeight: FontWeight.bold, // Make it bold
                fontSize: 20, // Set font size to 20
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Show loading spinner
          : error != null
              ? Center(child: Text(error!))  // Show error message if any
              : complaintDetails != null
                  ? _buildComplaintDetails(complaintDetails!)  // Build UI if data is available
                  : Center(child: Text('No data available')),  // Show this if data is null
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Set background color
    );
  }

  // Function to build the UI for displaying complaint details
  Widget _buildComplaintDetails(Map<String, dynamic> data) {
    // Format the date and ensure it is a string
    String formattedDate = DateFormat.yMMMMd().format(DateTime.parse(data['comp_date']));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Box
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

            // Location and Date Row (aligned together)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Location: ",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      data['comp_location'] ?? 'No Location', // Handle NULL location safely
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Changed color to black
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Date: ",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      formattedDate, // Display formatted date
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Changed color to black
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description of the complaint
            RichText(
              text: TextSpan(
                text: 'Description: ',  // "Description" part will be bold
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,  // Bold for "Description"
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: data['comp_desc'],  // Complaint description part
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,  // Normal weight for comp_desc
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Complaint by Header with Officer Name (officer_name is not bold)
            Text.rich(
              TextSpan(
                text: "Complaint by: ",  // This part remains bold
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: data['officer_name'],  // Officer name is not bold
                    style: const TextStyle(fontWeight: FontWeight.normal),  // Make the officer name not bold
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Add space below this section

            // Task Included Header
            const Text(
              "Task Included",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Task Included Icons with Shadows
            Container(
              padding: const EdgeInsets.all(10),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTaskIcon(Icons.cleaning_services, 'Mopping & Cleaning'),
                  _buildTaskIcon(Icons.wash, 'Vacuuming'),
                  _buildTaskIcon(Icons.wash, 'Wiping'),
                  _buildTaskIcon(Icons.storage, 'Organizing'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Number of Cleaners Dropdown
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF92AEB9), // Card background color
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
                          color: Colors.white,  // Keep dropdown white
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedNumOfCleaners,
                            hint: const Text('Select number'),
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

            // Dynamically Generated Cleaner Dropdowns
            if (selectedNumOfCleaners != null)
              for (int i = 0; i < int.parse(selectedNumOfCleaners!); i++)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF92AEB9), // Card background color
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
                                    color: Colors.white,  // Keep dropdown white
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedCleaners[i],
                                      hint: const Text('Select cleaner'),
                                      onChanged: (String? newValue) {
                                        _onCleanerSelected(i, newValue);
                                      },
                                      items: _getAvailableCleaners(i).map<DropdownMenuItem<String>>((String cleaner) {
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

            // Assign Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle the assign task logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF92AEB9), // Same color as cleaner name card
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Assign Task',
                  style: TextStyle(fontSize: 16, color: Colors.black), // Button text style
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each task icon button
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
