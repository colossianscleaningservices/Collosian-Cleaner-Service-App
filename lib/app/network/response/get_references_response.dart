class GetReferencesResponse {
  GetReferencesResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetReferencesResponse.fromJson(dynamic json) {
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
      this.references, 
      this.pagination,});

  Data.fromJson(dynamic json) {
    if (json['references'] != null) {
      references = [];
      json['references'].forEach((v) {
        references?.add(References.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<References>? references;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (references != null) {
      map['references'] = references?.map((v) => v.toJson()).toList();
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

class References {
  References({
      this.id, 
      this.userId, 
      this.firstName, 
      this.lastName, 
      this.email, 
      this.companyName, 
      this.phoneNumber, 
      this.relationship, 
      this.refPhotoUrl, 
      this.applicantName, 
      this.refereeName, 
      this.createdAt, 
      this.updatedAt,});

  References.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    companyName = json['company_name'];
    phoneNumber = json['phone_number'];
    relationship = json['relationship'];
    refPhotoUrl = json['ref_photo_url'];
    applicantName = json['applicant_name'];
    refereeName = json['referee_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? companyName;
  String? phoneNumber;
  String? relationship;
  dynamic refPhotoUrl;
  String? applicantName;
  String? refereeName;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['email'] = email;
    map['company_name'] = companyName;
    map['phone_number'] = phoneNumber;
    map['relationship'] = relationship;
    map['ref_photo_url'] = refPhotoUrl;
    map['applicant_name'] = applicantName;
    map['referee_name'] = refereeName;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}