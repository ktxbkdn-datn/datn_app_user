import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// A utility class for formatting dates consistently throughout the app
class DateFormatUtils {
  /// Converts a date string to the API format (yyyy-MM-dd)
  /// 
  /// Takes a date string in various formats (dd-MM-yyyy, yyyy-MM-dd, etc.)
  /// and converts it to the API format (yyyy-MM-dd).
  /// 
  /// Returns null if the date string is invalid.
  static String? formatDateForApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      final trimmedDate = dateString.trim();
      
      // Already in yyyy-MM-dd format (backend format)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmedDate)) {
        debugPrint('Date already in correct backend format: $trimmedDate');
        return trimmedDate;
      }
      
      // In dd-MM-yyyy format (UI format)
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(trimmedDate)) {
        final parsed = DateFormat('dd-MM-yyyy').parse(trimmedDate);
        final formatted = DateFormat('yyyy-MM-dd').format(parsed);
        debugPrint('Date converted from $trimmedDate to $formatted');
        return formatted;
      }
      
      // Try to parse as DateTime
      final parsed = DateTime.parse(trimmedDate);
      final formatted = DateFormat('yyyy-MM-dd').format(parsed);
      debugPrint('Date parsed as DateTime and formatted: $formatted');
      return formatted;
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return null;
    }
  }
  
  /// Formats a date for UI display (dd-MM-yyyy)
  static String? formatDateForUi(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    
    try {
      final trimmedDate = dateString.trim();
      
      // Already in dd-MM-yyyy format (UI format)
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(trimmedDate)) {
        return trimmedDate;
      }
      
      // In yyyy-MM-dd format (backend format)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmedDate)) {
        final parsed = DateFormat('yyyy-MM-dd').parse(trimmedDate);
        return DateFormat('dd-MM-yyyy').format(parsed);
      }
      
      // Try to parse as DateTime
      final parsed = DateTime.parse(trimmedDate);
      return DateFormat('dd-MM-yyyy').format(parsed);
    } catch (e) {
      debugPrint('Error formatting date for UI: $e');
      return null;
    }
  }
  
  /// Validates a date string and returns true if it is valid
  static bool isValidDate(String? dateString) {
    return formatDateForApi(dateString) != null;
  }
}
