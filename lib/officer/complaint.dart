import 'dart:convert'; // To handle JSON encoding
import 'package:http/http.dart' as http; // Import the http package
import 'package:shared_preferences/shared_preferences.dart'; // For storing and retrieving the token
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<List<String>> fetchLocations() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('http://your-api-url.com/api/locations'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> locationsJson = jsonDecode(response.body);
    return locationsJson.map((location) => location.toString()).toList();
  } else {
    throw Exception('Failed to load locations');
  }
}


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
  String? _imagePath; // For image storage

  // locations for the complaint
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  void _loadLocations() async {
    try {
      List<String> locations = await fetchLocations();
      setState(() {
        _locations = locations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading locations: $e')));
    }
  }


  // List to keep track of checkbox states for additional tasks
  List<bool> _additionalTasksChecked = [false, false, false, false, false];

    // Method to submit the complaint via the API
  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      // Get the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User not authenticated')),
        );
        return;
      }

      // Prepare complaint data
      final complaintData = {
        'comp_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'comp_time': DateFormat('HH:mm:ss').format(DateTime.now()), // Current time
        'comp_desc': _descriptionController.text,
        'comp_location': _selectedLocation,
        'comp_status': 'pending', // Default status
        'comp_image': _imagePath, // Add image if needed, this is optional
        'officer_id': 1 // Get this dynamically based on login or user profile
      };

      try {
        // API endpoint
        final url = Uri.parse('http://your-api-url.com/api/complaints');
        
        // Send POST request with token
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(complaintData),
        );

        if (response.statusCode == 200) {
          // On success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Complaint Submitted Successfully')),
          );
          _clearForm(); // Clear the form
        } else {
          // On failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Could not submit complaint')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

   // Method to clear the form after successful submission
  void _clearForm() {
    _descriptionController.clear();
    setState(() {
      _selectedLocation = null;
      _selectedDate = null;
      _additionalTasksChecked = [false, false, false, false, false];
    });
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
          'Call for Cleaner',
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Upload Image card with file name and upload button layout
            Card(
              elevation: 4,
              color: const Color(0xFF92AEB9), // Set the card color to match the theme
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), // Adjust vertical padding to make it thinner
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align items to the left
                  crossAxisAlignment: CrossAxisAlignment.center, // Center align the items vertically
                  children: [
                    // "Upload Image" text
                    const Text(
                      'Upload Image',
                      style: TextStyle(
                        color: Colors.black, // Black text for "Upload Image"
                        fontSize: 16, // Font size for the text
                        fontWeight: FontWeight.bold, // Optional: make the text bold
                      ),
                    ),
                    const SizedBox(width: 5), // Smaller space between the text and the file name box

                    // Left side: File name text
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 12.0), // Adjust padding
                        decoration: BoxDecoration(
                          color: Colors.white, // White background for the file name box
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          border: Border.all(color: Colors.grey[400]!), // Border for the box
                        ),
                        child: const Text(
                          'picture.png', // Default file name text
                          style: TextStyle(
                            color: Colors.black, // File name text color
                            fontSize: 16, // Font size for the file name
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5), // Smaller space between file name and upload button

                    // Right side: Upload button inside white container
                    Container(
                      height: 30, // Adjust height to be smaller
                      width: 30,  // Adjust width to be smaller
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for the upload button
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        border: Border.all(color: Colors.grey[400]!), // Border for the container
                      ),
                      child: Center( // Center the icon within the button
                        child: IconButton(
                          onPressed: () {
                            // Handle image upload logic
                          },
                          icon: const Icon(Icons.camera_alt), // Camera icon for the upload
                          color: Colors.black, // Icon color black
                          iconSize: 16, // Adjust icon size to fit the smaller container
                          padding: EdgeInsets.zero, // Remove default padding
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40), // Increased space between the card and the grey box




            // Grey box for image preview placed outside and below the upload image card
            const SizedBox(height: 10), // Space between the card and the grey box

            Container(
              height: 200, // Set height for the grey box
              width: double.infinity, // Take full width of the screen
              decoration: BoxDecoration(
                color: Colors.grey[300], // Set the grey color for the box
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              child: Center(
                child: const Text(
                  'Image Preview', // Placeholder text for the grey box
                  style: TextStyle(
                    color: Colors.black, // Black text
                    fontSize: 16, // Adjust font size if needed
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35), // Increased space between the card and the grey box

            // Location card
            Card(
              elevation: 0, // Remove shadow by setting elevation to 0
              color: Colors.transparent, // Set the card color to transparent
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Change text color to black
                      ),
                    ),
                    DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: InputDecoration(
                      hintText: 'Room, Floor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _locations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.grey),
                        ),
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
              elevation: 0, // Remove shadow by setting elevation to 0
              color: Colors.transparent, // Set the card color to transparent
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Change text color to black
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: _selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                : 'Select date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey), // Set outline color to grey
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
                          style: const TextStyle(color: Colors.grey), // Set input text color to grey
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
              elevation: 0, // Remove shadow by setting elevation to 0
              color: Colors.transparent, // Set the card color to transparent
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Change text color to black
                      ),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter task description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey), // Set outline color to grey
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
                      style: const TextStyle(color: Colors.grey), // Set input text color to grey
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30.0),


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

              Row(
                mainAxisAlignment: MainAxisAlignment.end, // Aligns the button to the right
                children: [
                  TextButton(
                    onPressed: () {
                      // Add your send functionality here
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF6F1F1), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Round-ish shape
                      ),
                    ),
                    child: const Text(
                      'Send', // Change button text to 'Send'
                      style: TextStyle(
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                ],
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
