class ScheduleJobRequest {
  ScheduleJobRequest({
    this.frequency,
    this.startDate,
    this.startTime,
    this.endTime,
    this.repeatOnDay,
    this.copyCleaners,
    this.cleanerIds,
  });

  ScheduleJobRequest.fromJson(dynamic json) {
    frequency = json['frequency'];
    startDate = json['start_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    repeatOnDay = json['repeat_on_day'];
    copyCleaners = json['copy_cleaners'];
    if (json['cleaner_ids'] != null) {
      cleanerIds = [];
      json['cleaner_ids'].forEach((v) {
        cleanerIds?.add(v);
      });
    }
  }

  String? frequency;
  String? startDate;
  String? startTime;
  String? endTime;
  String? repeatOnDay;
  bool? copyCleaners;
  List<num>? cleanerIds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['frequency'] = frequency;
    map['start_date'] = startDate;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    if (repeatOnDay != null) {
      map['repeat_on_day'] = repeatOnDay;
    }
    map['copy_cleaners'] = copyCleaners;
    if (cleanerIds != null && cleanerIds!.isNotEmpty) {
      map['cleaner_ids'] = cleanerIds;
    }
    return map;
  }
}
