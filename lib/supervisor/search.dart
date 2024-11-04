import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../supervisor/cleaner_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState(); // Made public
}

class SearchPageState extends State<SearchPage> {
  final Logger _logger = Logger(); // Initialize Logger

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

          filteredCleaners = List.from(allCleaners);
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Search',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                            onChanged: (value) {
                              _filterNames(value);
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
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
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
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredCleaners.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CleanerDetailPage(
                                  cleanerName: filteredCleaners[index]['name']!,
                                  cleanerStatus: filteredCleaners[index]['status']!,
                                  profilePic: filteredCleaners[index]['profile_pic']!,
                                  cleanerPhoneNo: filteredCleaners[index]['phone_no']!,
                                  building: filteredCleaners[index]['building']!,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF92AEB9),
                                child: Text(
                                  filteredCleaners[index]['name']![0],
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
    );
  }
}

// Extension to capitalize the first letter of each word in the status dropdown
extension StringExtension on String {
  String capitalizeFirstOfEach() {
    return split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }
}
