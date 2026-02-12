import 'package:ccs_app/app/network/response/base_response.dart';

class TrainingResourceResponse extends BaseResponse {
  TrainingResourceResponse({
      this.data,});

  TrainingResourceResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Data? data;

  @override
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
      this.resources, 
      this.counts,});

  Data.fromJson(dynamic json) {
    resources = json['resources'] != null ? Resources.fromJson(json['resources']) : null;
    counts = json['counts'] != null ? Counts.fromJson(json['counts']) : null;
  }
  Resources? resources;
  Counts? counts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (resources != null) {
      map['resources'] = resources?.toJson();
    }
    if (counts != null) {
      map['counts'] = counts?.toJson();
    }
    return map;
  }

}

class Counts {
  Counts({
      this.total, 
      this.seen, 
      this.unseen,});

  Counts.fromJson(dynamic json) {
    total = json['total'];
    seen = json['seen'];
    unseen = json['unseen'];
  }
  num? total;
  num? seen;
  num? unseen;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total'] = total;
    map['seen'] = seen;
    map['unseen'] = unseen;
    return map;
  }

}

class Resources {
  Resources({
      this.trainings, 
      this.pagination,});

  Resources.fromJson(dynamic json) {
    if (json['trainings'] != null) {
      trainings = [];
      json['trainings'].forEach((v) {
        // trainings?.add(Dynamic.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<dynamic>? trainings;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (trainings != null) {
      map['trainings'] = trainings?.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    return map;
  }

}

class Pagination {
  Pagination({
      this.total, 
      this.count, 
      this.perPage, 
      this.currentPage, 
      this.totalPages,});

  Pagination.fromJson(dynamic json) {
    total = json['total'];
    count = json['count'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
  }
  num? total;
  num? count;
  num? perPage;
  num? currentPage;
  num? totalPages;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total'] = total;
    map['count'] = count;
    map['per_page'] = perPage;
    map['current_page'] = currentPage;
    map['total_pages'] = totalPages;
    return map;
  }

}