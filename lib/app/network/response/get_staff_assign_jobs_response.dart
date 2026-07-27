import 'get_client_job_response.dart';
import 'jobs.dart';

class GetStaffAssignJobsResponse {
  GetStaffAssignJobsResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetStaffAssignJobsResponse.fromJson(dynamic json) {
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
    this.total,
    this.pagination,
  });

  Data.fromJson(dynamic json) {
    if (json['jobs'] != null) {
      jobs = [];
      json['jobs'].forEach((v) {
        jobs?.add(Jobs.fromJson(v));
      });
    }
    total = json['total'];
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }

  List<Jobs>? jobs;
  num? total;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (jobs != null) {
      map['jobs'] = jobs?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    return map;
  }
}