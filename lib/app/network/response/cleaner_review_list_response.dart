class CleanerReviewListResponse {
  CleanerReviewListResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  CleanerReviewListResponse.fromJson(dynamic json) {
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
    this.overallRating,
    this.totalReviews,
    this.reviews,
    this.pagination,});

  Data.fromJson(dynamic json) {
    overallRating = json['overall_rating'];
    totalReviews = json['total_reviews'];
    if (json['reviews'] != null) {
      reviews = [];
      json['reviews'].forEach((v) {
        reviews?.add(Reviews.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  num? overallRating;
  num? totalReviews;
  List<Reviews>? reviews;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['overall_rating'] = overallRating;
    map['total_reviews'] = totalReviews;
    if (reviews != null) {
      map['reviews'] = reviews?.map((v) => v.toJson()).toList();
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

class Reviews {
  Reviews({
    this.id,
    this.jobId,
    this.clientId,
    this.cleanerId,
    this.arrivedOnTime,
    this.woreUniform,
    this.completedOnTime,
    this.satisfactionRating,
    this.comments,
    this.wouldRehire,
    this.submittedAt,
    this.isSubmitted,
    this.createdAt,
    this.updatedAt,
    this.cleaner,
    this.client,
    this.job,});

  Reviews.fromJson(dynamic json) {
    id = json['id'];
    jobId = json['job_id'];
    clientId = json['client_id'];
    cleanerId = json['cleaner_id'];
    arrivedOnTime = json['arrived_on_time'];
    woreUniform = json['wore_uniform'];
    completedOnTime = json['completed_on_time'];
    satisfactionRating = json['satisfaction_rating'];
    comments = json['comments'];
    wouldRehire = json['would_rehire'];
    submittedAt = json['submitted_at'];
    isSubmitted = json['is_submitted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cleaner = json['cleaner'] != null ? Cleaner.fromJson(json['cleaner']) : null;
    client = json['client'] != null ? Client.fromJson(json['client']) : null;
    job = json['job'] != null ? Job.fromJson(json['job']) : null;
  }
  num? id;
  num? jobId;
  num? clientId;
  num? cleanerId;
  bool? arrivedOnTime;
  bool? woreUniform;
  bool? completedOnTime;
  num? satisfactionRating;
  String? comments;
  bool? wouldRehire;
  String? submittedAt;
  bool? isSubmitted;
  String? createdAt;
  String? updatedAt;
  Cleaner? cleaner;
  Client? client;
  Job? job;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['job_id'] = jobId;
    map['client_id'] = clientId;
    map['cleaner_id'] = cleanerId;
    map['arrived_on_time'] = arrivedOnTime;
    map['wore_uniform'] = woreUniform;
    map['completed_on_time'] = completedOnTime;
    map['satisfaction_rating'] = satisfactionRating;
    map['comments'] = comments;
    map['would_rehire'] = wouldRehire;
    map['submitted_at'] = submittedAt;
    map['is_submitted'] = isSubmitted;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (cleaner != null) {
      map['cleaner'] = cleaner?.toJson();
    }
    if (client != null) {
      map['client'] = client?.toJson();
    }
    if (job != null) {
      map['job'] = job?.toJson();
    }
    return map;
  }

}

class Job {
  Job({
    this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    this.cleaningType,
    this.property,});

  Job.fromJson(dynamic json) {
    id = json['id'];
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    cleaningType = json['cleaning_type'];
    property = json['property'] != null ? Property.fromJson(json['property']) : null;
  }
  num? id;
  String? date;
  String? startTime;
  String? endTime;
  String? status;
  String? cleaningType;
  Property? property;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['date'] = date;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['status'] = status;
    map['cleaning_type'] = cleaningType;
    if (property != null) {
      map['property'] = property?.toJson();
    }
    return map;
  }

}

class Property {
  Property({
    this.id,
    this.propertyName,
    this.address,
    this.city,
    this.postalCode,});

  Property.fromJson(dynamic json) {
    id = json['id'];
    propertyName = json['property_name'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
  }
  num? id;
  String? propertyName;
  String? address;
  String? city;
  String? postalCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['property_name'] = propertyName;
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    return map;
  }

}

class Client {
  Client({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,});

  Client.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
  }
  num? id;
  String? name;
  String? email;
  String? phoneNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    return map;
  }

}

class Cleaner {
  Cleaner({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,});

  Cleaner.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
  }
  num? id;
  String? name;
  String? email;
  String? phoneNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    return map;
  }

}