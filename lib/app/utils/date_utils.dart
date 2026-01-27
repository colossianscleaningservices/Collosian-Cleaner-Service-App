import 'package:intl/intl.dart';

// Consolidated date/time utilities (moved from extension.dart).

const List<String> monthList = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class RelativeTimeUtils {
  static String relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDateWithTime(date);
  }
}

String formatDate(
  String date, {
  String inputFormat = 'dd-MM-yyyy',
  String outputFormat = 'dd MMM, yyyy',
}) {
  final originalFormat = DateFormat(inputFormat);
  final parsedDate = originalFormat.parse(date);
  final desiredFormat = DateFormat(outputFormat);
  return desiredFormat.format(parsedDate);
}

/// Parses a UTC date string from server and converts to local time.
DateTime parseUtcToLocal(String? dateString) {
  if (dateString == null || dateString.isEmpty) return DateTime.now();

  try {
    // ISO formats with timezone markers.
    if (dateString.contains('Z') ||
        dateString.contains('+') ||
        (dateString.length > 19 && dateString[10] == 'T')) {
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) return parsed.toLocal();
    }

    // Common UTC formats without timezone info.
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parseUTC(dateString).toLocal();
    } catch (_) {
      return DateFormat('yyyy-MM-ddTHH:mm:ss').parseUTC(dateString).toLocal();
    }
  } catch (_) {
    return DateTime.now();
  }
}

String formatDateString(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '--';
  try {
    final parsedDate = parseUtcToLocal(dateString);
    return formatDateWithTime(parsedDate);
  } catch (_) {
    return dateString;
  }
}

String formatDateWithTime(DateTime date) =>
    DateFormat('MM-dd-yyyy hh:mm a').format(date);

String formatDateOnly(DateTime date) => DateFormat('MM-dd-yyyy').format(date);

String formatDateShort(DateTime date) => DateFormat('dd MMM yyyy').format(date);

extension CcsDateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool isSameDay(DateTime other) =>
      day == other.day && month == other.month && year == other.year;

  String toLocalString([String format = 'yyyy-MM-dd HH:mm:ss']) =>
      DateFormat(format).format(toLocal());

  String toUtcString([String format = 'yyyy-MM-dd HH:mm:ss']) =>
      DateFormat(format).format(toUtc());

  String toDisplayDate([String format = 'MMM yyyy, hh:mm a']) =>
      DateFormat(format).format(toLocal());
}
