import 'package:intl/intl.dart';

String formatTime(String? timeString) {
  if (timeString == null || timeString.isEmpty) {
    return '';
  }
  try {
    final time = DateFormat('HH:mm:ss').parse(timeString);
    return DateFormat('hh:mm a').format(time);
  } catch (e) {
    return '';
  }
}

String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return '';
  }
  try {
    final date = DateFormat('yyyy-MM-dd').parse(dateString);
    return DateFormat('MMM d, yyyy').format(date);
  } catch (e) {
    return '';
  }
}

String getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Complaint sent!';
    case 'ongoing':
      return 'Complaint in progress...';
    case 'completed':
      return 'Complaint resolved!';
    default:
      return 'Unknown status';
  }
}
