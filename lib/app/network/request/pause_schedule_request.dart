class PauseScheduleRequest {
  PauseScheduleRequest({
    this.inactiveStartDate,
    this.inactiveEndDate,
  });

  PauseScheduleRequest.fromJson(dynamic json) {
    inactiveStartDate = json['inactive_start_date'];
    inactiveEndDate = json['inactive_end_date'];
  }

  String? inactiveStartDate;
  String? inactiveEndDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (inactiveStartDate != null) {
      map['inactive_start_date'] = inactiveStartDate;
    }
    if (inactiveEndDate != null) {
      map['inactive_end_date'] = inactiveEndDate;
    }
    return map;
  }
}
