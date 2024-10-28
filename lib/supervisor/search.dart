import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'navbar.dart'; // Import the SupervisorBottomNavBar widget
import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences
import '../supervisor/cleaner_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, String>> allCleaners = []; // List to hold all cleaner data
  List<Map<String, String>> filteredCleaners = []; // List to hold filtered cleaner data
  String selectedStatus = 'all'; // Dropdown value for cleaner status
  bool isLoading = true; // Flag to indicate if data is being loaded

  @override
  void initState() {
    super.initState();
    fetchCleaners(); // Fetch the list of cleaners when the page loads
  }

  // Fetch cleaner names from the backend
  Future<void> fetchCleaners({String? status}) async {
    final url = 'http://127.0.0.1:8000/api/supervisor/cleaners'; // API endpoint

    try {
      // Retrieve the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Replace 'auth_token' with your actual key

      // Set up the headers with the authorization token
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Append status parameter if provided
      final response = await http.get(Uri.parse('$url?status=$status'), headers: headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cleaners = data['data'];

        setState(() {
          // Store cleaner data as a list of maps, handling null values
          allCleaners = cleaners.map((cleaner) {
            return {
              'name': cleaner['cleaner_name'] as String? ?? 'Unknown', // Default to 'Unknown' if null
              'status': cleaner['status'] as String? ?? 'Unavailable', // Default to 'Unavailable' if null
              'profile_pic': cleaner['profile_pic'] as String? ?? '', // Default to empty string if null
              'phone_no': cleaner['cleaner_phoneNo'] as String? ?? '', // Default to empty string if null
              'building': cleaner['building'] as String? ?? '', // Default to empty string if null
            };
          }).toList();

          filteredCleaners = List.from(allCleaners); // Initially display all cleaners
          isLoading = false; // Stop loading
        });
      } else {
        throw Exception('Failed to load cleaners');
      }
    } catch (e) {
      print('Error fetching cleaners: $e');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  // Filter the list based on the search query and selected status
  void _filterNames(String query) {
    setState(() {
      filteredCleaners = allCleaners
          .where((cleaner) => cleaner['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Further filter by status if not 'all'
      if (selectedStatus != 'all') {
        filteredCleaners = filteredCleaners
            .where((cleaner) => cleaner['status'] == selectedStatus)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Changed AppBar color
        automaticallyImplyLeading: false, // Remove back button
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0), // Adds padding to move the text down
          child: Text(
            'Search',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold, // Makes the text bold
              fontSize: 18, // You can adjust the font size as needed
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar and Status Dropdown
            Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 233, 233, 233),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              _filterNames(value); // Filter as user types
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Space between the search bar and dropdown
                // Status Dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)), // Border color
                    color: const Color.fromARGB(255, 233, 233, 233),
                  ),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: SizedBox(), // Removes the underline
                    items: <String>['all', 'available', 'unavailable']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            value == 'all' ? 'Status' : value.capitalizeFirstOfEach(),
                            style: const TextStyle(color: Colors.black), // Dropdown text color
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue!;
                        // Filter names based on selected status
                        _filterNames(""); // Reapply the current search query
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cleaners List
            isLoading
                ? const CircularProgressIndicator() // Show loading spinner while fetching data
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredCleaners.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to cleaner detail page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CleanerDetailPage(
                                  cleanerName: filteredCleaners[index]['name']!,
                                  cleanerStatus: filteredCleaners[index]['status']!,
                                  profilePic: filteredCleaners[index]['profile_pic']!, // Pass profile picture
                                  cleanerPhoneNo: filteredCleaners[index]['phone_no']!, // Pass phone number
                                  building: filteredCleaners[index]['building']!, // Pass building
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100], // Light blue background
                                child: Text(
                                  filteredCleaners[index]['name']![0], // First letter of the name
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              title: Text(
                                filteredCleaners[index]['name']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: const SupervisorBottomNavBar(
        currentIndex: 1, // Set current index to 1 for Search screen
      ),
    );
  }
}

// Extension to capitalize the first letter of each word in the status dropdown
extension StringExtension on String {
  String capitalizeFirstOfEach() {
    return this.split(' ').map((word) => word.length > 0 ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }
}
