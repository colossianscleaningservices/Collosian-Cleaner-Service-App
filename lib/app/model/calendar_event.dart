/// View mode for the cleaner calendar (week / month / list).
enum CalendarViewMode { week, month, list }

/// Top-level mode: shows assigned jobs vs jobs available to apply for.
enum CalendarJobMode { assigned, available }

/// Bounds for [TableCalendar] and period navigation.
final kCalendarFirstDay = DateTime(2020, 1, 1);
final kCalendarLastDay = DateTime(2030, 12, 31);

class CalendarEvent {
  CalendarEvent({
    required this.title,
    this.timeRange = '09:00 – 11:00',
    this.status,
    this.jobId,
    this.propertyName,
    this.address,
    this.subtitle,
    this.cleanerInfo,
    this.cleanerJobStatus,
  });

  /// Cleaning type / job type (e.g. "Deep clean").
  final String title;
  final String? timeRange;
  final String? status;
  final String? cleanerJobStatus;

  /// Optional job id for navigation to client job detail.
  final num? jobId;

  /// Property name (e.g. "12 Maple St").
  final String? propertyName;

  /// Full address line.
  final String? address;

  /// Extra subtitle line.
  final String? subtitle;

  /// Cleaner assignment (e.g. "John, Jane" or "2 cleaners").
  final String? cleanerInfo;
}
