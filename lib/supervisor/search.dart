import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../supervisor/cleaner_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final Logger _logger = Logger();
  List<Map<String, String>> allCleaners = [];
  List<Map<String, String>> filteredCleaners = [];
  String selectedStatus = 'all';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCleaners();
  }

  Future<void> fetchCleaners({String? status}) async {
    final url = 'http://127.0.0.1:8000/api/supervisor/cleaners';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final response = await http.get(Uri.parse('$url?status=$status'), headers: headers);
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cleaners = data['data'];
        setState(() {
          allCleaners = cleaners.map((cleaner) {
            return {
              'name': cleaner['cleaner_name'] as String? ?? 'Unknown',
              'status': cleaner['status'] as String? ?? 'Unavailable',
              'profile_pic': cleaner['profile_pic'] as String? ?? '',
              'phone_no': cleaner['cleaner_phoneNo'] as String? ?? '',
              'building': cleaner['building'] as String? ?? '',
            };
          }).toList();
          _filterNames(''); // Apply the initial filter based on selected status
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cleaners');
      }
    } catch (e) {
      _logger.e('Error fetching cleaners: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterNames(String query) {
    setState(() {
      filteredCleaners = allCleaners
          .where((cleaner) => cleaner['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (selectedStatus != 'all') {
        filteredCleaners = filteredCleaners
            .where((cleaner) => cleaner['status'] == selectedStatus)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Search Cleaner',
          style: TextStyle(
            color: onPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Blue background section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
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
                                    onChanged: (value) => _filterNames(value),
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
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 233, 233, 233),
                          ),
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            icon: const Icon(Icons.arrow_drop_down),
                            underline: const SizedBox(),
                            items: <String>['all', 'available', 'unavailable']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    value == 'all' ? 'Status' : value.capitalizeFirstOfEach(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStatus = newValue!;
                                _filterNames("");
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content section
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCleaners.isEmpty
                      ? Center(
                          child: Text(
                            selectedStatus == 'available'
                                ? 'No available cleaners.'
                                : 'No unavailable cleaners.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCleaners.length,
                          itemBuilder: (context, index) {
                            final cleaner = filteredCleaners[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height * 0.01),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CleanerDetailPage(
                                        cleanerName: cleaner['name']!,
                                        cleanerStatus: cleaner['status']!,
                                        profilePic: cleaner['profile_pic']!,
                                        cleanerPhoneNo: cleaner['phone_no']!,
                                        building: cleaner['building']!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width * 0.03),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius:
                                            MediaQuery.of(context).size.width * 0.005,
                                        blurRadius:
                                            MediaQuery.of(context).size.width * 0.03,
                                        offset: Offset(0,
                                            MediaQuery.of(context).size.height * 0.005),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.04),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                        child: Text(
                                          cleaner['name']![0],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E5675),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          cleaner['name']!,
                                          style: TextStyle(
                                            fontSize:
                                                MediaQuery.of(context).size.width * 0.045,
                                            fontWeight: FontWeight.w600,
                                            color: onPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize the first letter of each word in the status dropdown
extension StringExtension on String {
  String capitalizeFirstOfEach() {
    return split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }
}
