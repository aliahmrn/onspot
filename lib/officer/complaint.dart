import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../service/complaint_service.dart';
import 'dart:io';

// Providers
final descriptionControllerProvider = Provider((ref) => TextEditingController());
final selectedLocationProvider = StateProvider<String?>((ref) => null);
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final imagePathProvider = StateProvider<String?>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);

class FileComplaintPage extends ConsumerStatefulWidget {
  const FileComplaintPage({super.key});

  @override
  FileComplaintPageState createState() => FileComplaintPageState();
}

class FileComplaintPageState extends ConsumerState<FileComplaintPage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitComplaint(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      final selectedDate = ref.read(selectedDateProvider);
      final selectedLocation = ref.read(selectedLocationProvider);
      final descriptionController = ref.read(descriptionControllerProvider);
      final imagePath = ref.read(imagePathProvider);

      if (selectedDate == null || selectedLocation == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and location')),
        );
        return;
      }

      // Set loading state to true
      ref.read(loadingProvider.notifier).state = true;

      try {
        bool success = await ComplaintService().submitComplaint(
          description: descriptionController.text,
          location: selectedLocation,
          date: selectedDate,
          imagePath: imagePath,
        );

        if (!mounted) return;

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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        // Reset loading state
        ref.read(loadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final String? selectedImagePath = await ComplaintService().pickImage();
    ref.read(imagePathProvider.notifier).state = selectedImagePath;
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ref.read(selectedDateProvider) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
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

    final descriptionController = ref.watch(descriptionControllerProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final imagePath = ref.watch(imagePathProvider);
    final isLoading = ref.watch(loadingProvider);

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
              _buildImageUploadCard(primaryColor, onPrimaryColor, screenWidth, ref),
              const SizedBox(height: 10),
              _buildImagePreview(imagePath),
              const SizedBox(height: 35),
              _buildLocationField(
                  outlineColor, onSecondaryColor, screenWidth, selectedLocation, ref),
              const SizedBox(height: 16.0),
              _buildDateField(
                  outlineColor, onSecondaryColor, screenWidth, selectedDate, context, ref),
              const SizedBox(height: 16.0),
              _buildDescriptionField(outlineColor, onSecondaryColor, screenWidth,
                  descriptionController),
              const SizedBox(height: 30.0),
              _buildSendButton(primaryColor, onPrimaryColor, isLoading, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(
      Color primaryColor, Color onPrimaryColor, double screenWidth, WidgetRef ref) {
    final imagePath = ref.watch(imagePathProvider);
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
                  imagePath != null ? imagePath.split('/').last : 'No image selected',
                  style: TextStyle(
                    color: imagePath != null ? Colors.black : Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () => _pickImage(ref),
              icon: const Icon(Icons.camera_alt),
              color: onPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String? imagePath) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: imagePath != null && File(imagePath).existsSync()
            ? Image.file(File(imagePath), fit: BoxFit.cover)
            : const Text('Image Preview'),
      ),
    );
  }

  Widget _buildLocationField(Color outlineColor, Color onSecondaryColor,
      double screenWidth, String? selectedLocation, WidgetRef ref) {
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
          value: selectedLocation,
          decoration: InputDecoration(
            hintText: 'Room, Floor',
            hintStyle: TextStyle(color: onSecondaryColor, fontSize: screenWidth * 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: outlineColor),
            ),
          ),
          items: [
            'Floor 1',
            'Floor 2',
            'Floor 3',
            'Floor 4',
            'Floor 5',
            'Floor 6',
          ].map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location, style: TextStyle(fontSize: screenWidth * 0.04)),
            );
          }).toList(),
          onChanged: (value) {
            ref.read(selectedLocationProvider.notifier).state = value;
          },
          validator: (value) => value == null ? 'Please select a location' : null,
        ),
      ],
    );
  }

  Widget _buildDateField(Color outlineColor, Color onSecondaryColor,
      double screenWidth, DateTime? selectedDate, BuildContext context, WidgetRef ref) {
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
          onTap: () => _selectDate(context, ref),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate)
                    : 'Select date',
                hintStyle: TextStyle(color: onSecondaryColor, fontSize: screenWidth * 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: outlineColor),
                ),
              ),
              validator: (value) => selectedDate == null ? 'Please select a date' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(Color outlineColor, Color onSecondaryColor,
      double screenWidth, TextEditingController descriptionController) {
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
          controller: descriptionController,
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

  Widget _buildSendButton(
      Color primaryColor, Color onPrimaryColor, bool isLoading, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : () => _submitComplaint(ref),
          style: TextButton.styleFrom(
            backgroundColor: isLoading ? Colors.grey : primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  'Send',
                  style: TextStyle(color: onPrimaryColor, fontSize: 16),
                ),
        ),
      ],
    );
  }
}
