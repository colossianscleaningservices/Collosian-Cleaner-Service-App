class GetTransactionHistoryResponse {
  GetTransactionHistoryResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetTransactionHistoryResponse.fromJson(dynamic json) {
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
      this.payouts, 
      this.pagination,});

  Data.fromJson(dynamic json) {
    if (json['payouts'] != null) {
      payouts = [];
      json['payouts'].forEach((v) {
        payouts?.add(Payouts.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<Payouts>? payouts;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (payouts != null) {
      map['payouts'] = payouts?.map((v) => v.toJson()).toList();
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

class Payouts {
  Payouts({
      this.id, 
      this.workedHours, 
      this.totalPayout, 
      this.paidOn, 
      this.status,
      this.job,});

  Payouts.fromJson(dynamic json) {
    id = json['id'];
    workedHours = json['worked_hours'];
    totalPayout = json['total_payout'];
    paidOn = json['paid_on'];
    status = json['status'];
    job = json['job'] != null ? Job.fromJson(json['job']) : null;
  }
  num? id;
  num? workedHours;
  num? totalPayout;
  String? paidOn;
  String? status;
  Job? job;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['worked_hours'] = workedHours;
    map['total_payout'] = totalPayout;
    map['paid_on'] = paidOn;
    map['status'] = status;
    if (job != null) {
      map['job'] = job?.toJson();
    }
    return map;
  }

}

class Job {
  Job({
      this.id, 
      this.jobType, 
      this.cleaningService,});

  Job.fromJson(dynamic json) {
    id = json['id'];
    jobType = json['job_type'];
    cleaningService = json['cleaning_service'];
  }
  num? id;
  String? jobType;
  String? cleaningService;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['job_type'] = jobType;
    map['cleaning_service'] = cleaningService;
    return map;
  }

}