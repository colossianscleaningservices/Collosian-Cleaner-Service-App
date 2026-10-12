class GetPreferredStaffResponse {
  GetPreferredStaffResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetPreferredStaffResponse.fromJson(dynamic json) {
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
      this.preferredStaff,});

  Data.fromJson(dynamic json) {
    if (json['preferred_staff'] != null) {
      preferredStaff = [];
      json['preferred_staff'].forEach((v) {
        preferredStaff?.add(PreferredStaff.fromJson(v));
      });
    }
  }
  List<PreferredStaff>? preferredStaff;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (preferredStaff != null) {
      map['preferred_staff'] = preferredStaff?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class PreferredStaff {
  PreferredStaff({
      this.id, 
      this.name, 
      this.firstName, 
      this.lastName, 
      this.email, 
      this.phoneNumber, 
      this.imageUrl, 
      this.city, 
      this.country, 
      this.address, 
      this.preferred, 
      this.cleaningServices, 
      this.workShifts,});

  PreferredStaff.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    imageUrl = json['image_url'];
    city = json['city'];
    country = json['country'];
    address = json['address'];
    preferred = json['preferred'];
    cleaningServices = json['cleaning_services'] != null ? json['cleaning_services'].cast<num>() : [];
    if (json['work_shifts'] != null) {
      workShifts = [];
      json['work_shifts'].forEach((v) {
        workShifts?.add(WorkShifts.fromJson(v));
      });
    }
  }
  num? id;
  String? name;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? imageUrl;
  String? city;
  dynamic country;
  String? address;
  bool? preferred;
  List<num>? cleaningServices;
  List<WorkShifts>? workShifts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    map['image_url'] = imageUrl;
    map['city'] = city;
    map['country'] = country;
    map['address'] = address;
    map['preferred'] = preferred;
    map['cleaning_services'] = cleaningServices;
    if (workShifts != null) {
      map['work_shifts'] = workShifts?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class WorkShifts {
  WorkShifts({
      this.day, 
      this.startTime, 
      this.endTime,});

  WorkShifts.fromJson(dynamic json) {
    day = json['day'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }
  String? day;
  String? startTime;
  String? endTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['day'] = day;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    return map;
  }

}