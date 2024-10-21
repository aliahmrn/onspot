import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onspot_officer/service/complaint_service.dart';
import 'dart:io';

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
  String? _imagePath;

  final List<String> _locations = [
    'Floor 1', 'Floor 2', 'Floor 3', 'Floor 4', 'Floor 5',
    'Floor 6', 'Floor 7', 'Floor 8', 'Floor 9', 'Floor 10',
    'Floor 11', 'Floor 12', 'Floor 13',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and location')),
        );
        return;
      }

      await ComplaintService().submitComplaint(
        description: _descriptionController.text,
        location: _selectedLocation!,
        date: _selectedDate!,
        imagePath: _imagePath,
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call for Cleaner'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUploadCard(),
              const SizedBox(height: 10),
              _buildImagePreview(),
              const SizedBox(height: 35),
              _buildLocationField(),
              const SizedBox(height: 16.0),
              _buildDateField(),
              const SizedBox(height: 16.0),
              _buildDescriptionField(),
              const SizedBox(height: 30.0),
              const SizedBox(height: 20),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return Card(
      elevation: 4,
      color: const Color(0xFF92AEB9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Row(
          children: [
            const Text('Upload Image', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Text(
                  _imagePath != null
                      ? _imagePath!.split('/').last
                      : 'No image selected',
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
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

  Widget _buildLocationField() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            decoration: InputDecoration(
              hintText: 'Room, Floor',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _locations.map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
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
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : 'Select date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => _selectedDate == null ? 'Please select a date' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Task Description', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter task description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a task description' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _submitComplaint,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFF6F1F1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Send', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
