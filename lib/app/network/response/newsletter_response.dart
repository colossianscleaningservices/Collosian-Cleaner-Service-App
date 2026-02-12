class NewsletterResponse {
  NewsletterResponse({
      this.data, 
      this.version, 
      this.code, 
      this.message,});

  NewsletterResponse.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    version = json['version'];
    code = json['code'];
    message = json['message'];
  }
  Data? data;
  String? version;
  num? code;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['version'] = version;
    map['code'] = code;
    map['message'] = message;
    return map;
  }

}

class Data {
  Data({
      this.newsletters, 
      this.pagination,});

  Data.fromJson(dynamic json) {
    if (json['newsletters'] != null) {
      newsletters = [];
      json['newsletters'].forEach((v) {
        newsletters?.add(Newsletters.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<Newsletters>? newsletters;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (newsletters != null) {
      map['newsletters'] = newsletters?.map((v) => v.toJson()).toList();
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

class Newsletters {
  Newsletters({
      this.id, 
      this.title, 
      this.description, 
      this.isActive, 
      this.createdAt, 
      this.updatedAt,});

  Newsletters.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? title;
  String? description;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['is_active'] = isActive;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}