import 'jobs.dart';

class GetClientCalenderResponse {
  GetClientCalenderResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetClientCalenderResponse.fromJson(dynamic json) {
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
      this.jobs, 
      this.total,});

  Data.fromJson(dynamic json) {
    if (json['jobs'] != null) {
      jobs = [];
      json['jobs'].forEach((v) {
        jobs?.add(Jobs.fromJson(v));
      });
    }
    total = json['total'];
  }
  List<Jobs>? jobs;
  num? total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (jobs != null) {
      map['jobs'] = jobs?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    return map;
  }

}