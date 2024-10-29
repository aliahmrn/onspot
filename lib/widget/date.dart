import 'package:intl/intl.dart';

String formatDate(String? dateString) {
  if (dateString == null) return 'Unknown';
  try {
    final date = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(date);
  } catch (e) {
    return 'Unknown'; // Handle any parsing errors
  }
}
