import 'package:ccs_app/app/utils/date_utils.dart';

class UpdateScheduleJobRequest {
  UpdateScheduleJobRequest({
      this.frequency, 
      this.startDate, 
      this.startTime, 
      this.endTime, 
      this.repeatOnDay, 
      this.copyCleaners, 
      this.isActive,});

  UpdateScheduleJobRequest.fromJson(dynamic json) {
    frequency = json['frequency'];
    startDate = json['start_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    repeatOnDay = json['repeat_on_day'];
    copyCleaners = json['copy_cleaners'];
    isActive = json['is_active'];
  }
  String? frequency;
  String? startDate;
  String? startTime;
  String? endTime;
  String? repeatOnDay;
  bool? copyCleaners;
  bool? isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['frequency'] = frequency;
    map['start_date'] = startDate;
    map['start_time'] = CcsDateTimeX.normalizeApiTimeShort(startTime);
    map['end_time'] = CcsDateTimeX.normalizeApiTimeShort(endTime);
    map['repeat_on_day'] = repeatOnDay;
    map['copy_cleaners'] = copyCleaners;
    map['is_active'] = isActive;
    return map;
  }

}