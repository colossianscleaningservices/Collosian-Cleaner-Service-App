import 'package:ccs_app/app/network/response/base_response.dart';

class NotificationResponse extends BaseResponse {
  NotificationResponse({
      this.data,});

  NotificationResponse.fromJson(dynamic json) {
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
      this.notifications, 
      this.pagination, 
      this.unreadCount,});

  Data.fromJson(dynamic json) {
    if (json['notifications'] != null) {
      notifications = [];
      json['notifications'].forEach((v) {
        notifications?.add(Notifications.fromJson(v)); //Data format not shown in API
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
    unreadCount = json['unread_count'];
  }
  List<Notifications>? notifications;
  Pagination? pagination;
  num? unreadCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (notifications != null) {
      map['notifications'] = notifications?.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    map['unread_count'] = unreadCount;
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

class Notifications {
  Notifications({
    this.id,
    this.userId,
    this.message,
    this.isRead,
    this.count,
    this.flag,
    this.createdAt,
    this.updatedAt,});

  Notifications.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    message = json['message'];
    isRead = json['is_read'];
    count = json['count'];
    flag = json['flag'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? userId;
  String? message;
  bool? isRead;
  dynamic count;
  dynamic flag;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['message'] = message;
    map['is_read'] = isRead;
    map['count'] = count;
    map['flag'] = flag;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}