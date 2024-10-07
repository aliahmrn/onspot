import 'package:flutter/material.dart';
import 'sv_navbar.dart'; // Import the SupervisorBottomNavBar widget

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF7FF), // Changed AppBar color
        elevation: 0,
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold, // Make "History" bold
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount:
              3, // You can change this to reflect the number of history items
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Reduced curveness of the card
                ),
                color: Color(0xFF92AEB9), // Background color of the task card
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Task assigned',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '9:41 AM',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Floor 2',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '2 Cleaners',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Align to the left
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFFC3D2D7), // Updated fill color
                              side: BorderSide(
                                  color: Colors.black), // Black border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Reduced button curveness
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.black, // Set text color to black
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // Space between the buttons
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFFC3D2D7), // Updated fill color
                              side: BorderSide(
                                  color: Colors.black), // Black border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Reduced button curveness
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: Colors.black, // Set text color to black
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
          },
        ),
      ),
      bottomNavigationBar: SupervisorBottomNavBar(
        currentIndex: 3, // Set current index to 3 for History screen
      ),
    );
  }
}
