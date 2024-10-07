import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To handle date formatting

class FileComplaintPage extends StatefulWidget {
  const FileComplaintPage({super.key});

  @override
  _FileComplaintPageState createState() => _FileComplaintPageState();
}

class _FileComplaintPageState extends State<FileComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedLocation;
  DateTime? _selectedDate;

  // Sample locations for the complaint
  final List<String> _locations = [
    'Room 101',
    'Room 102',
    'Conference Hall',
    'Lobby',
  ];

  // List to keep track of checkbox states for additional tasks
  List<bool> _additionalTasksChecked = [false, false, false, false, false];

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      // Process the complaint submission (e.g., send to API)
      final complaintDescription = _descriptionController.text;
      final complaintLocation = _selectedLocation;
      final complaintDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);

      // Show confirmation message (for demo purposes)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Complaint Submitted:\nDescription: $complaintDescription\nLocation: $complaintLocation\nDate: $complaintDate'),
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear the form
      _descriptionController.clear();
      setState(() {
        _selectedLocation = null;
        _selectedDate = null;
        _additionalTasksChecked = [
          false,
          false,
          false,
          false,
          false
        ]; // Reset checkbox states
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Cleaner',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make text bold
            fontSize: 20, // Adjust font size if needed
          ),
        ),
        centerTitle: true, // Centers the title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image card
              Card(
                color: const Color(0xFF92AEB9), // Set the card color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.camera_alt, size: 50),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle image upload
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button color
                          foregroundColor:
                              const Color(0xFF92AEB9), // Text color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Location card
              Card(
                color: const Color(0xFF92AEB9), // Set the card color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: InputDecoration(
                          hintText: 'Select location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _locations.map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a location';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Date card
              Card(
                color: const Color(0xFF92AEB9), // Set the card color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: _selectedDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate!)
                                  : 'Select date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (_selectedDate == null) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Task description card
              Card(
                color: const Color(0xFF92AEB9), // Set the card color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Description',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter task description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a task description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Additional Tasks section
              Card(
                color: const Color(0xFFF6F1F1), // Set the card color to F6F1F1
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Tasks',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black), // Set font color to black
                      ),
                      ...List.generate(_additionalTasksChecked.length, (index) {
                        return CheckboxListTile(
                          value: _additionalTasksChecked[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _additionalTasksChecked[index] =
                                  value ?? false; // Toggle the checkbox state
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, // Checkbox before the text
                          activeColor: Colors.black, // Checkbox color
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // Align text and icon to the edges
                            children: [
                              Text(
                                _getTaskTitle(index),
                                style: const TextStyle(
                                    color: Colors
                                        .black), // Set text color to black
                              ),
                              const Icon(
                                Icons.circle, // Display circle icon
                                color: Colors.black, // Set icon color to black
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF92AEB9), // Button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text('Submit Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTaskTitle(int index) {
    // Define task titles based on the index
    switch (index) {
      case 0:
        return 'Clean the floors';
      case 1:
        return 'Empty trash bins';
      case 2:
        return 'Restock supplies';
      case 3:
        return 'Wipe windows';
      case 4:
        return 'Other tasks';
      default:
        return '';
    }
  }
}
