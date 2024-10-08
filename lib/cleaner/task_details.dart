import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Task Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location and Date row (moved above image)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Floor 2',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '17/09/2024',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Image Container (empty box)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      const Color(0xFFE0E0E0), // Light grey for the empty box
                ),
                child: const Center(
                  child: Icon(Icons.image,
                      size: 60, color: Colors.grey), // Placeholder icon
                ),
              ),
              const SizedBox(height: 16),

              // Task description box
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0), // Light grey background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  maxLines: 4,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Task description...',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Task included section
              const Text(
                'Task included',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Gray container for the task icons row
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF0F0F0), // Light grey container for icons
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTaskIcon(
                        'Mopping & Cleaning', Icons.cleaning_services),
                    _buildTaskIcon('Vacuuming', Icons.cleaning_services),
                    _buildTaskIcon('Wiping', Icons.wash),
                    _buildTaskIcon('Organizing', Icons.inventory),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build task icons with labels
  Widget _buildTaskIcon(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.black),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const TaskDetailsPage(),
  ));
}
