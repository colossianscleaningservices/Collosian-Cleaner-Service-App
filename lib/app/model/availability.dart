import 'package:flutter/material.dart';

/// A single work window: [start] to [end].
class TimeSlot {
  TimeSlot({
    TimeOfDay? start,
    TimeOfDay? end,
  })  : start = start ?? const TimeOfDay(hour: 9, minute: 0),
        end = end ?? const TimeOfDay(hour: 18, minute: 0);

  final TimeOfDay start;
  final TimeOfDay end;

  TimeSlot copyWith({TimeOfDay? start, TimeOfDay? end}) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

/// One weekday: [enabled] toggle and list of [slots] (From–To). [dayIndex] 0 = Monday .. 6 = Sunday.
class DayAvailability {
  DayAvailability({
    required this.dayIndex,
    this.enabled = false,
    List<TimeSlot>? slots,
  }) : slots = slots ?? [];

  final int dayIndex;
  final bool enabled;
  final List<TimeSlot> slots;

  static DayAvailability getDefault(int dayIndex) => DayAvailability(
        dayIndex: dayIndex,
        enabled: false,
        slots: [],
      );

  DayAvailability copyWith({int? dayIndex, bool? enabled, List<TimeSlot>? slots}) {
    return DayAvailability(
      dayIndex: dayIndex ?? this.dayIndex,
      enabled: enabled ?? this.enabled,
      slots: slots ?? this.slots,
    );
  }
}

const kDayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
