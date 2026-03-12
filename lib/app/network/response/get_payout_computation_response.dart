class GetPayoutComputationResponse {
  GetPayoutComputationResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetPayoutComputationResponse.fromJson(dynamic json) {
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
    this.name,
    this.email,
    this.residentialRate,
    this.commercialRate,
    this.totalHours,
    this.residentialHours,
    this.commercialHours,
    this.residentialEarnings,
    this.commercialEarnings,
    this.totalPayout,
    this.paidAmount,
    this.unpaidAmount,
    this.workEntries,});

  Data.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    residentialRate = json['residential_rate'];
    commercialRate = json['commercial_rate'];
    totalHours = json['total_hours'];
    residentialHours = json['residential_hours'];
    commercialHours = json['commercial_hours'];
    residentialEarnings = json['residential_earnings'];
    commercialEarnings = json['commercial_earnings'];
    totalPayout = json['total_payout'];
    paidAmount = json['paid_amount'];
    unpaidAmount = json['unpaid_amount'];
    if (json['work_entries'] != null) {
      workEntries = [];
      json['work_entries'].forEach((v) {
        workEntries?.add(WorkEntries.fromJson(v));
      });
    }
  }
  String? name;
  String? email;
  num? residentialRate;
  num? commercialRate;
  num? totalHours;
  num? residentialHours;
  num? commercialHours;
  num? residentialEarnings;
  num? commercialEarnings;
  num? totalPayout;
  num? paidAmount;
  num? unpaidAmount;
  List<WorkEntries>? workEntries;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['residential_rate'] = residentialRate;
    map['commercial_rate'] = commercialRate;
    map['total_hours'] = totalHours;
    map['residential_hours'] = residentialHours;
    map['commercial_hours'] = commercialHours;
    map['residential_earnings'] = residentialEarnings;
    map['commercial_earnings'] = commercialEarnings;
    map['total_payout'] = totalPayout;
    map['paid_amount'] = paidAmount;
    map['unpaid_amount'] = unpaidAmount;
    if (workEntries != null) {
      map['work_entries'] = workEntries?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class WorkEntries {
  WorkEntries({
    this.payoutId,
    this.jobId,
    this.workedHours,
    this.totalPayout,
    this.paidOn,
    this.status,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.jobType,
    this.startDate,
    this.endDate,
    this.hourlyRate,
    this.residentialEarnings,
    this.commercialEarnings,
    this.commercialRate,
    this.note,});

  WorkEntries.fromJson(dynamic json) {
    payoutId = json['payout_id'];
    jobId = json['job_id'];
    workedHours = json['worked_hours'];
    totalPayout = json['total_payout'];
    paidOn = json['paid_on'];
    status = json['status'];
    clientName = json['client_name'];
    clientEmail = json['client_email'];
    clientPhone = json['client_phone'];
    jobType = json['job_type'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    hourlyRate = json['hourly_rate'];
    residentialEarnings = json['residential_earnings'];
    commercialEarnings = json['commercial_earnings'];
    commercialRate = json['commercial_rate'];
    note = json['note'];
  }
  num? payoutId;
  dynamic jobId;
  num? workedHours;
  String? totalPayout;
  String? paidOn;
  String? status;
  String? clientName;
  dynamic clientEmail;
  dynamic clientPhone;
  dynamic jobType;
  String? startDate;
  String? endDate;
  num? hourlyRate;
  num? residentialEarnings;
  num? commercialEarnings;
  dynamic commercialRate;
  dynamic note;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['payout_id'] = payoutId;
    map['job_id'] = jobId;
    map['worked_hours'] = workedHours;
    map['total_payout'] = totalPayout;
    map['paid_on'] = paidOn;
    map['status'] = status;
    map['client_name'] = clientName;
    map['client_email'] = clientEmail;
    map['client_phone'] = clientPhone;
    map['job_type'] = jobType;
    map['start_date'] = startDate;
    map['end_date'] = endDate;
    map['hourly_rate'] = hourlyRate;
    map['residential_earnings'] = residentialEarnings;
    map['commercial_earnings'] = commercialEarnings;
    map['commercial_rate'] = commercialRate;
    map['note'] = note;
    return map;
  }

}