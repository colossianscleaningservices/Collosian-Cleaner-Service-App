class GetAvailabilityResponse {
  GetAvailabilityResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetAvailabilityResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? message;
  String? version;
  num? code;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['version'] = version;
    map['code'] = code;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }

}

class Data {
  Data({
      this.weeklySchedule, 
      this.blockedDays,});

  Data.fromJson(dynamic json) {
    if (json['weekly_schedule'] != null) {
      weeklySchedule = [];
      json['weekly_schedule'].forEach((v) {
        weeklySchedule?.add(WeeklySchedule.fromJson(v));
      });
    }
    blockedDays = json['blocked_days'] != null ? json['blocked_days'].cast<String>() : [];
  }
  List<WeeklySchedule>? weeklySchedule;
  List<String>? blockedDays;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (weeklySchedule != null) {
      map['weekly_schedule'] = weeklySchedule?.map((v) => v.toJson()).toList();
    }
    map['blocked_days'] = blockedDays;
    return map;
  }

}

class WeeklySchedule {
  WeeklySchedule({
      this.day, 
      this.enabled, 
      this.slots,});

  WeeklySchedule.fromJson(dynamic json) {
    day = json['day'];
    enabled = json['enabled'];
    if (json['slots'] != null) {
      slots = [];
      json['slots'].forEach((v) {
        slots?.add(Slots.fromJson(v));
      });
    }
  }
  String? day;
  bool? enabled;
  List<dynamic>? slots;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['day'] = day;
    map['enabled'] = enabled;
    if (slots != null) {
      map['slots'] = slots?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Slots {
  Slots({
    this.startTime,
    this.endTime,});

  Slots.fromJson(dynamic json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
  }
  String? startTime;
  String? endTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    return map;
  }

}