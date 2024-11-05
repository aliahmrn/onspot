import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onspot_officer/service/complaint_service.dart';
import 'dart:io';

class FileComplaintPage extends StatefulWidget {
  const FileComplaintPage({super.key});

  @override
  FileComplaintPageState createState() => FileComplaintPageState();
}

class FileComplaintPageState extends State<FileComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedLocation;
  DateTime? _selectedDate;
  String? _imagePath;

  final List<String> _locations = [
    'Floor 1', 'Floor 2', 'Floor 3', 'Floor 4', 'Floor 5',
    'Floor 6', 'Floor 7', 'Floor 8', 'Floor 9', 'Floor 10',
    'Floor 11', 'Floor 12', 'Floor 13',
  ];

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedLocation == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date and location')),
          );
        }
        return;
      }

      bool success = await ComplaintService().submitComplaint(
        description: _descriptionController.text,
        location: _selectedLocation!,
        date: _selectedDate!,
        imagePath: _imagePath,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complaint added successfully')),
          );

          Navigator.pushReplacementNamed(context, '/officer-home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit complaint. Try again.')),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final String? selectedImagePath = await ComplaintService().pickImage();
    setState(() {
      _imagePath = selectedImagePath;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final onSecondaryColor = theme.colorScheme.onSecondary;
    final outlineColor = theme.colorScheme.outline;

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Request Cleaner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: onSecondaryColor,
        ),
        backgroundColor: secondaryColor,
        titleTextStyle: TextStyle(
          color: onSecondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.05,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUploadCard(primaryColor, onPrimaryColor, screenWidth),
              const SizedBox(height: 10),
              _buildImagePreview(),
              const SizedBox(height: 35),
              _buildLocationField(outlineColor, onSecondaryColor, screenWidth),
              const SizedBox(height: 16.0),
              _buildDateField(outlineColor, onSecondaryColor, screenWidth),
              const SizedBox(height: 16.0),
              _buildDescriptionField(outlineColor, onSecondaryColor, screenWidth),
              const SizedBox(height: 30.0),
              _buildSendButton(primaryColor, onPrimaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(Color primaryColor, Color onPrimaryColor, double screenWidth) {
    return Card(
      elevation: 4,
      color: primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Row(
          children: [
            Text(
              'Upload Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: onPrimaryColor,
                fontSize: screenWidth * 0.04,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: primaryColor),
                ),
                child: Text(
                  _imagePath != null
                      ? _imagePath!.split('/').last
                      : 'No image selected',
                  style: TextStyle(
                    color: _imagePath != null ? Colors.black : Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              color: onPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: _imagePath != null && File(_imagePath!).existsSync()
            ? Image.file(File(_imagePath!), fit: BoxFit.cover)
            : const Text('Image Preview'),
      ),
    );
  }

  Widget _buildLocationField(Color outlineColor, Color onSecondaryColor, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: onSecondaryColor,
            fontSize: screenWidth * 0.04,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: InputDecoration(
            hintText: 'Room, Floor',
            hintStyle: TextStyle(color: onSecondaryColor, fontSize: screenWidth * 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: outlineColor),
            ),
          ),
          items: _locations.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location, style: TextStyle(fontSize: screenWidth * 0.04)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLocation = value;
            });
          },
          validator: (value) => value == null ? 'Please select a location' : null,
        ),
      ],
    );
  }

  Widget _buildDateField(Color outlineColor, Color onSecondaryColor, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: onSecondaryColor,
            fontSize: screenWidth * 0.04,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : 'Select date',
                hintStyle: TextStyle(color: onSecondaryColor, fontSize: screenWidth * 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: outlineColor),
                ),
              ),
              validator: (value) => _selectedDate == null ? 'Please select a date' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(Color outlineColor, Color onSecondaryColor, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Description',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: onSecondaryColor,
            fontSize: screenWidth * 0.04,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter task description',
            hintStyle: TextStyle(color: onSecondaryColor, fontSize: screenWidth * 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: outlineColor),
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a task description' : null,
        ),
      ],
    );
  }

  Widget _buildSendButton(Color primaryColor, Color onPrimaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _submitComplaint,
          style: TextButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Send',
            style: TextStyle(color: onPrimaryColor, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
