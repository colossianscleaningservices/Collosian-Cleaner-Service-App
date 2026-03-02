import 'package:ccs_app/app/network/response/property_list_response.dart';

import 'jobs.dart';

class GetClientDashResponse {
  GetClientDashResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  GetClientDashResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? ClientDashModel.fromJson(json['data']) : null;
  }

  String? message;
  String? version;
  num? code;
  ClientDashModel? data;

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

class ClientDashModel {
  ClientDashModel({
    this.properties,
    this.todayJobs,
    this.upcomingJobs,
  });

  ClientDashModel.fromJson(dynamic json) {
    if (json['properties'] != null) {
      properties = [];
      json['properties'].forEach((v) {
        properties?.add(PropertyModel.fromJson(v));
      });
    }
    if (json['today_jobs'] != null) {
      todayJobs = [];
      json['today_jobs'].forEach((v) {
        todayJobs?.add(Jobs.fromJson(v));
      });
    }
    if (json['upcoming_jobs'] != null) {
      upcomingJobs = [];
      json['upcoming_jobs'].forEach((v) {
        upcomingJobs?.add(Jobs.fromJson(v));
      });
    }
  }

  List<PropertyModel>? properties;
  List<Jobs>? todayJobs;
  List<Jobs>? upcomingJobs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (properties != null) {
      map['properties'] = properties?.map((v) => v.toJson()).toList();
    }
    if (todayJobs != null) {
      map['today_jobs'] = todayJobs?.map((v) => v.toJson()).toList();
    }
    if (upcomingJobs != null) {
      map['upcoming_jobs'] = upcomingJobs?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
