import 'package:ccs_app/app/network/response/base_response.dart';
import 'package:video_player/video_player.dart';

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
        trainings?.add(Trainings.fromJson(v));   //Data format not shown in API
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<Trainings>? trainings;
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

class Trainings {
  Trainings({
    this.id,
    this.title,
    this.fileUrl,
    this.fileCategory,
    this.fileExtension,
    this.description,
    this.content,
    this.allowedTypes,
    this.contentType,
    this.isSelected = false,
    this.isSeen,
    this.createdAt,
    this.videoPlayerController,
    this.updatedAt,});

  Trainings.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    fileUrl = json['file_url'];
    fileCategory = json['file_category'];
    fileExtension = json['file_extension'];
    description = json['description'];
    content = json['content'];
    allowedTypes = json['allowed_types'];
    contentType = json['content_type'];
    isSeen = json['is_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? title;
  String? fileUrl;
  String? fileCategory;
  String? fileExtension;
  String? description;
  dynamic content;
  dynamic allowedTypes;
  String? contentType;
  bool? isSeen;
  String? createdAt;
  String? updatedAt;
  bool? isSelected;
  VideoPlayerController? videoPlayerController;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['file_url'] = fileUrl;
    map['file_category'] = fileCategory;
    map['file_extension'] = fileExtension;
    map['description'] = description;
    map['content'] = content;
    map['allowed_types'] = allowedTypes;
    map['content_type'] = contentType;
    map['is_seen'] = isSeen;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}