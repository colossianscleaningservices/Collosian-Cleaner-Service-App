class ScheduleJobRequest {
  ScheduleJobRequest({
      this.frequency, 
      this.startDate, 
      this.endDate, 
      this.copyCleaners, 
      this.repeatEvery, 
      this.repeatOn, 
      this.startTime, 
      this.endTime,});

  ScheduleJobRequest.fromJson(dynamic json) {
    frequency = json['frequency'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    copyCleaners = json['copy_cleaners'];
    repeatEvery = json['repeat_every'];
    repeatOn = json['repeat_on'] != null ? RepeatOn.fromJson(json['repeat_on']) : null;
    startTime = json['start_time'];
    endTime = json['end_time'];
  }
  String? frequency;
  String? startDate;
  String? endDate;
  bool? copyCleaners;
  String? repeatEvery;
  RepeatOn? repeatOn;
  String? startTime;
  String? endTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['frequency'] = frequency;
    map['start_date'] = startDate;
    map['end_date'] = endDate;
    map['copy_cleaners'] = copyCleaners;
    map['repeat_every'] = repeatEvery;
    if (repeatOn != null) {
      map['repeat_on'] = repeatOn?.toJson();
    }
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    return map;
  }

}

class RepeatOn {
  RepeatOn({
      this.monday, 
      this.tuesday, 
      this.wednesday, 
      this.thursday, 
      this.friday, 
      this.saturday, 
      this.sunday,});

  RepeatOn.fromJson(dynamic json) {
    monday = json['monday'];
    tuesday = json['tuesday'];
    wednesday = json['wednesday'];
    thursday = json['thursday'];
    friday = json['friday'];
    saturday = json['saturday'];
    sunday = json['sunday'];
  }
  bool? monday;
  bool? tuesday;
  bool? wednesday;
  bool? thursday;
  bool? friday;
  bool? saturday;
  bool? sunday;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['monday'] = monday;
    map['tuesday'] = tuesday;
    map['wednesday'] = wednesday;
    map['thursday'] = thursday;
    map['friday'] = friday;
    map['saturday'] = saturday;
    map['sunday'] = sunday;
    return map;
  }

}