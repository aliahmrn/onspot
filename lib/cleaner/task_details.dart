import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDetailsPage extends StatefulWidget {
  final int complaintId;
  final String location;
  final String date;
  final String? imageUrl;
  final String description;

  const TaskDetailsPage({
    super.key,
    required this.complaintId,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.description,
  });

  @override
  TaskDetailsPageState createState() => TaskDetailsPageState();
}

class TaskDetailsPageState extends State<TaskDetailsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Butiran Tugasan',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onPrimaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Rounded white background
          Positioned(
            top: screenHeight * 0.02,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.08),
                  topRight: Radius.circular(screenWidth * 0.08),
                ),
              ),
            ),
          ),

          // Main Content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.07, // Adjust for rounded background
                    ),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      elevation: 8, // Increase elevation for a more prominent shadow
                      shadowColor: Colors.black.withOpacity(0.8), 
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            Container(
                              width: double.infinity,
                              height: screenHeight * 0.3,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: screenWidth * 0.02,
                                    offset: Offset(0, screenHeight * 0.003),
                                  ),
                                ],
                              ),
                              child: widget.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(screenWidth * 0.04),
                                      child: Image.network(
                                        widget.imageUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Text(
                                              'Gagal memuatkan gambar',
                                              style: TextStyle(color: onPrimaryColor),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Tiada gambar tersedia',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // Lokasi Section
                            Text(
                              'Lokasi',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: Text(
                                widget.location,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // Tarikh Section
                            Text(
                              'Tarikh',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: Text(
                                _formatDate(widget.date),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // Penerangan Section
                            Text(
                              'Penerangan',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Tarikh tidak betul.';
    }
  }
}
