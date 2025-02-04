import 'dart:io';
import 'package:intl/intl.dart';

/// Resolves the base URL by replacing 'localhost' with the appropriate IP for mobile devices
String resolveUrl(String url) {
  if (Platform.isAndroid || Platform.isIOS) {
    return url.replaceFirst('localhost', '192.168.1.121');
  }
  return url;
}

/// Base URL for API
const String baseUrl = 'http://10.0.2.2:8000/api';

/// Formats a date string into 'dd-MM-yyyy' format
String formatDate(String? dateString) {
  if (dateString == null) return 'Unknown';
  try {
    final date = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(date);
  } catch (e) {
    return 'Unknown'; // Handle parsing errors gracefully
  }
}
