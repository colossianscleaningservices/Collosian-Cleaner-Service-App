import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Consolidated date/time utilities. Use CcsDateUtils for all date formatting in the app.

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
    if (dateString.contains('Z') || dateString.contains('+') || (dateString.length > 19 && dateString[10] == 'T')) {
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

String formatDateWithTime(DateTime date) => DateFormat('dd/MM/yyyy hh:mm a').format(date);

String formatDateOnly(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

String formatDateShort(DateTime date) => DateFormat('dd MMM yyyy').format(date);

/// Common date formats used across the app. Prefer these over direct DateFormat.
class CcsDateUtils {
  CcsDateUtils._();

  static DateFormat _fmt(String pattern) => DateFormat(pattern);

  /// Full date with weekday: "Tue 28 Jan 2025"
  static String fullDate(DateTime date) => _fmt('EEE d MMM yyyy').format(date);

  /// Short date without year: "Tue 28 Jan"
  static String shortDateNoYear(DateTime date) => _fmt('EEE d MMM').format(date);

  /// Short date: "28 Jan 2025"
  static String shortDate(DateTime date) => _fmt('dd MMM yyyy').format(date);

  /// Month and year: "Jan 2025"
  static String monthYear(DateTime date) => _fmt('MMM yyyy').format(date);

  /// Full month and year: "January 2025"
  static String fullMonthYear(DateTime date) => _fmt('MMMM yyyy').format(date);

  /// Long date: "Tuesday, 28 January 2025"
  static String longDate(DateTime date) => _fmt('EEEE, d MMMM yyyy').format(date);

  /// Short with weekday: "Tue, 28 Jan 2025"
  static String shortWithWeekday(DateTime date) => _fmt('EEE, d MMM yyyy').format(date);

  /// Day and month: "28 Jan"
  static String dayMonth(DateTime date) => _fmt('d MMM').format(date);

  /// For form inputs / expiry display: "dd/MM/yyyy"
  static String forInput(DateTime? date) => date != null ? _fmt('dd/MM/yyyy').format(date) : '';

  /// Date range: "1–15 Jan 2025"
  static String dateRange(DateTime start, DateTime end) => '${start.day}–${end.day} ${monthYear(start)}';

  /// Time from TimeOfDay (12h with am/pm)
  static String timeFromTimeOfDay(TimeOfDay t) => DateFormat.jm().format(DateTime(2000, 1, 1, t.hour, t.minute));

  static TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String parseTimeRange(String startTime, String endTime) {
    var start = CcsDateUtils.parseTimeOfDay(startTime);
    var end = CcsDateUtils.parseTimeOfDay(endTime);

    return ("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}");
  }
}

extension CcsDateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool isSameDay(DateTime other) => day == other.day && month == other.month && year == other.year;

  String toLocalString([String format = 'yyyy-MM-dd HH:mm:ss']) => DateFormat(format).format(toLocal());

  String toUtcString([String format = 'yyyy-MM-dd HH:mm:ss']) => DateFormat(format).format(toUtc());

  String toDisplayDate([String format = 'MMM yyyy, hh:mm a']) => DateFormat(format).format(toLocal());

  static String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hours = timeOfDay.hour;
    final minutes = timeOfDay.minute;
    final seconds = 0; // TimeOfDay doesn't store seconds, so we default to 0

    // Format the time as H:i:s
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String convertTime(String time) {
    final inputFormat = DateFormat("HH:mm:ss");
    final outputFormat = DateFormat("hh:mm a");

    final dateTime = inputFormat.parse(time);
    return outputFormat.format(dateTime);
  }
}
