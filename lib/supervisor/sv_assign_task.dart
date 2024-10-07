import 'package:flutter/material.dart';

class AssignTaskPage extends StatelessWidget {
  const AssignTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFEF7FF), // Changed AppBar color
        foregroundColor: Colors.black, // Adjusted foreground color for contrast
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SizedBox(
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
      body: SingleChildScrollView(
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
                  boxShadow: [
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
              SizedBox(height: 20),
              // Location and Date Row with Correct Styling
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Location: ",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Text(
                        "Floor 2",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Gray text for content
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Date: ",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Text(
                        "17/09/2024",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Gray text for content
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Task Description with White Background
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Task description...',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Task Included Header
              Text(
                "Task Included",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Task Included Icons with Shadows
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
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
                    _buildTaskIcon(
                        Icons.cleaning_services, 'Mopping & Cleaning'),
                    _buildTaskIcon(Icons.wash, 'Vacuuming'),
                    _buildTaskIcon(Icons.wash, 'Wiping'),
                    _buildTaskIcon(Icons.storage, 'Organizing'),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Number of Cleaners Header and Input
              _buildInputContainer(
                context,
                title: 'Number of Cleaner',
                hint: 'Number of cleaner',
                buttonText: 'Confirm',
                buttonAction: () {},
              ),
              SizedBox(height: 20),

              // Cleaner Name Header and Input
              _buildInputContainer(
                context,
                title: 'Cleaner Name',
                hint: 'Select cleaner',
                buttonText: 'Assign',
                buttonAction: () {},
                isReadOnly: true,
                suffixIcon: Icon(Icons.person_search,
                    color: Colors.black), // Search icon black
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF92AEB9), // Set background color
    );
  }

  // Helper method to build each task icon button
  Widget _buildTaskIcon(IconData iconData, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: Icon(iconData, size: 40),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // Method to build an input container with header and button
  Widget _buildInputContainer(
    BuildContext context, {
    required String title,
    required String hint,
    required String buttonText,
    required VoidCallback buttonAction,
    bool isReadOnly = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Keep the input container background white
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3, // Adjust this to control the width of the textbox
                  child: TextField(
                    readOnly: isReadOnly,
                    decoration: InputDecoration(
                      hintText: hint,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Colors.black, width: 1), // Black outline
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(
                    width: 20), // Add more spacing between textbox and button
                ElevatedButton(
                  onPressed: buttonAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: Colors.black, width: 1), // Black outline
                    ),
                    shadowColor: Colors.black54, // Button shadow color
                    elevation: 6, // Button shadow elevation
                  ),
                  child: suffixIcon ?? Text(buttonText,
                          style: TextStyle(
                              color: Colors.black, // Text color is black
                              fontSize: 16)),
                ),
              ],
            ),
          ),
          SizedBox(height: 10), // Add some padding below the row
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: AssignTaskPage(),
    ));
