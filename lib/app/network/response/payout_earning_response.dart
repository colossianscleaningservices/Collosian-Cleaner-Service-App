class PayoutEarningResponse {
  PayoutEarningResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  PayoutEarningResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? PayoutEarningModel.fromJson(json['data']) : null;
  }
  String? message;
  String? version;
  num? code;
  PayoutEarningModel? data;

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

class PayoutEarningModel {
  PayoutEarningModel({
      this.totalEarnings, 
      this.nextPayout, 
      this.latestPayouts,});

  PayoutEarningModel.fromJson(dynamic json) {
    totalEarnings = json['total_earnings'];
    nextPayout = json['next_payout'];
    if (json['latest_payouts'] != null) {
      latestPayouts = [];
      json['latest_payouts'].forEach((v) {
        latestPayouts?.add(LatestPayouts.fromJson(v));
      });
    }
  }
  num? totalEarnings;
  num? nextPayout;
  List<LatestPayouts>? latestPayouts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_earnings'] = totalEarnings;
    map['next_payout'] = nextPayout;
    if (latestPayouts != null) {
      map['latest_payouts'] = latestPayouts?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class LatestPayouts {
  LatestPayouts({
      this.id, 
      this.totalPayout, 
      this.paidOn, 
      this.job,});

  LatestPayouts.fromJson(dynamic json) {
    id = json['id'];
    totalPayout = json['total_payout'];
    paidOn = json['paid_on'];
    job = json['job'] != null ? Job.fromJson(json['job']) : null;
  }
  num? id;
  num? totalPayout;
  String? paidOn;
  Job? job;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['total_payout'] = totalPayout;
    map['paid_on'] = paidOn;
    if (job != null) {
      map['job'] = job?.toJson();
    }
    return map;
  }

}

class Job {
  Job({
      this.id, 
      this.jobType, 
      this.cleaningService,});

  Job.fromJson(dynamic json) {
    id = json['id'];
    jobType = json['job_type'];
    cleaningService = json['cleaning_service'];
  }
  num? id;
  String? jobType;
  String? cleaningService;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['job_type'] = jobType;
    map['cleaning_service'] = cleaningService;
    return map;
  }

}