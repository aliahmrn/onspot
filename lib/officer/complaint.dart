import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../service/submit_service.dart';
import '../providers/submit_provider.dart';

class ComplaintPage extends ConsumerStatefulWidget {
  const ComplaintPage({super.key});

  @override
  ComplaintPageState createState() => ComplaintPageState();
}

class ComplaintPageState extends ConsumerState<ComplaintPage> {
  Future<void> _submitComplaint() async {
    final formKey = ref.read(formKeyProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final selectedTime = ref.read(selectedTimeProvider);

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila pilih tarikh dan masa')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    ref.read(loadingProvider.notifier).state = true;

    try {
      bool success = await ComplaintService().submitComplaint(
        description: ref.read(descriptionControllerProvider).text,
        location: ref.read(selectedLocationProvider) ?? '',
        date: scheduledDateTime,
        time: DateFormat.Hm().format(scheduledDateTime),
        imagePath: ref.read(imagePathProvider),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
        );

        // Reset form
        formKey.currentState!.reset();
        ref.read(descriptionControllerProvider).clear();
        ref.read(selectedLocationProvider.notifier).state = null;
        ref.read(selectedDateProvider.notifier).state = null;
        ref.read(selectedTimeProvider.notifier).state = null;
        ref.read(imagePathProvider.notifier).state = null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit complaint')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTime = ref.watch(selectedTimeProvider);
    final imagePath = ref.watch(imagePathProvider);
    final theme = Theme.of(context);

    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final secondaryColor = theme.colorScheme.secondary;
    final outlineColor = theme.colorScheme.outline;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40), // ✅ Forces AppBar height
        child: AppBar(
          title: Text(
            'Aduan',
            style: TextStyle(
              color: onPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          elevation: 0,
          toolbarHeight: 40, // ✅ Sets smaller AppBar height
          titleSpacing: 0, // ✅ Ensures no extra padding around title
          automaticallyImplyLeading:
              false, // ✅ Removes default back button padding
        ),
      ),
      body: Stack(
        children: [
          // this is the content section
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(
                bottom: 20), // ✅ Adjusts space dynamically
          ),

          // ✅ Adjust Form Position
          Positioned.fill(
            top: kToolbarHeight - 5, // Brings form higher
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: ref.watch(formKeyProvider),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageUploadCard(primaryColor, onPrimaryColor),
                      const SizedBox(height: 10),
                      _buildImagePreview(imagePath),
                      const SizedBox(height: 20),
                      _buildLocationField(outlineColor),
                      const SizedBox(height: 16.0),
                      _buildDateField(selectedDate, outlineColor),
                      const SizedBox(height: 16.0),
                      _buildTimeField(selectedTime, outlineColor),
                      const SizedBox(height: 16.0),
                      _buildDescriptionField(outlineColor),
                      const SizedBox(height: 30.0),
                      _buildSendButton(isLoading, primaryColor, onPrimaryColor),
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

  Widget _buildImageUploadCard(Color primaryColor, Color onPrimaryColor) {
    return Card(
      elevation: 4,
      color: primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Row(
          children: [
            Text('Muat naik gambar',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: onPrimaryColor)),
            const Spacer(),
            IconButton(
              onPressed: () async {
                final selectedImagePath = await ComplaintService().pickImage();
                ref.read(imagePathProvider.notifier).state = selectedImagePath;
              },
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imagePath != null && File(imagePath).existsSync()
            ? Image.file(File(imagePath), fit: BoxFit.cover)
            : Center(
                child: Text(
                  'Tiada gambar',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
      ),
    );
  }

  Widget _buildLocationField(Color outlineColor) {
    return DropdownButtonFormField<String>(
      value: ref.watch(selectedLocationProvider),
      decoration: InputDecoration(
        hintText: 'Blok',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: outlineColor)),
      ),
      items: ['Blok A', 'Blok B', 'Blok C', 'Blok D', 'Blok E']
          .map((location) =>
              DropdownMenuItem(value: location, child: Text(location)))
          .toList(),
      onChanged: (value) =>
          ref.read(selectedLocationProvider.notifier).state = value,
      validator: (value) => value == null ? 'Sila pilih blok' : null,
    );
  }

  Widget _buildDateField(DateTime? selectedDate, Color outlineColor) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (pickedDate != null) {
          ref.read(selectedDateProvider.notifier).state = pickedDate;
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(selectedDate)
                : 'Pilih tarikh',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: outlineColor)),
          ),
          validator: (value) =>
              selectedDate == null ? 'Sila pilih tarikh' : null,
        ),
      ),
    );
  }

  Widget _buildTimeField(TimeOfDay? selectedTime, Color outlineColor) {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        if (pickedTime != null) {
          ref.read(selectedTimeProvider.notifier).state = pickedTime;
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: selectedTime != null
                ? selectedTime.format(context)
                : 'Pilih masa',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: outlineColor)),
          ),
          validator: (value) => selectedTime == null ? 'Sila pilih masa' : null,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(Color outlineColor) {
    return TextFormField(
      controller: ref.watch(descriptionControllerProvider),
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Masukkan penerangan tugas',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: outlineColor)),
      ),
      validator: (value) => value == null || value.isEmpty
          ? 'Sila masukkan pengerangan tugas.'
          : null,
    );
  }

  Widget _buildSendButton(
      bool isLoading, Color primaryColor, Color onPrimaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // ✅ Align button to the right
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : _submitComplaint,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // ✅ Button uses primary color
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  'Hantar',
                  style: TextStyle(
                      color:
                          onPrimaryColor), // ✅ Submit text uses onPrimary color
                ),
        ),
      ],
    );
  }
}
