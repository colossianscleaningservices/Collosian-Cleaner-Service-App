import 'package:ccs_app/app/network/response/property_list_response.dart';
import 'package:ccs_app/app/network/response/staff_dashboard_response.dart';

class GetClientDashResponse {
  GetClientDashResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetClientDashResponse.fromJson(dynamic json) {
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
      this.properties, 
      this.todayJobs, 
      this.upcomingJobs,});

  Data.fromJson(dynamic json) {
    if (json['properties'] != null) {
      properties = [];
      json['properties'].forEach((v) {
        properties?.add(PropertyModel.fromJson(v));
      });
    }
    if (json['today_jobs'] != null) {
      todayJobs = [];
      json['today_jobs'].forEach((v) {
        // todayJobs?.add(Dynamic.fromJson(v));
      });
    }
    if (json['upcoming_jobs'] != null) {
      upcomingJobs = [];
      json['upcoming_jobs'].forEach((v) {
        upcomingJobs?.add(UpcomingJob.fromJson(v));
      });
    }
  }
  List<PropertyModel>? properties;
  List<dynamic>? todayJobs;
  List<UpcomingJob>? upcomingJobs;

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

