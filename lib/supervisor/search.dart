import 'package:flutter/material.dart';
import 'navbar.dart'; // Import the SupervisorBottomNavBar widget

class SearchPage extends StatelessWidget {
  final List<String> names = [
    "Husna Ilyani",
    "Ilham Fatinah",
    "Nurul Aliah",
    "Akif Aiman",
    "Nur Safiyah",
    "Ahmad Akram",
    "Aiman Zaki",
    "Muhd Yusuf",
  ];

  SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFEF7FF), // Changed AppBar color
        automaticallyImplyLeading: false, // Remove back button
        title: const Padding(
          padding: EdgeInsets.only(
              top: 10.0), // Adds padding to move the text down
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.purple[50], // Light purple background
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: names.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.blue[100], // Light blue background
                      child: Text(
                        names[index][0], // First letter of the name
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    title: Text(
                      names[index],
                      style: const TextStyle(fontSize: 16),
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
