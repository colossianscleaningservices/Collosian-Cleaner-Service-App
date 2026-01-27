/// View mode for the cleaner calendar (week / month / list).
enum CalendarViewMode { week, month, list }

/// Bounds for [TableCalendar] and period navigation.
final kCalendarFirstDay = DateTime(2020, 1, 1);
final kCalendarLastDay = DateTime(2030, 12, 31);

class CalendarEvent {
  CalendarEvent({
    required this.title,
    this.timeRange = '09:00 – 11:00',
    this.status = 'Approved',
  });

  final String title;
  final String timeRange;
  final String status;
}
