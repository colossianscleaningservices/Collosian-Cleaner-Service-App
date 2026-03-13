class GetStaffDetailResponse {
  GetStaffDetailResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetStaffDetailResponse.fromJson(dynamic json) {
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
      this.staff,});

  Data.fromJson(dynamic json) {
    staff = json['staff'] != null ? Staff.fromJson(json['staff']) : null;
  }
  Staff? staff;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (staff != null) {
      map['staff'] = staff?.toJson();
    }
    return map;
  }

}

class Staff {
  Staff({
      this.id, 
      this.firstName, 
      this.lastName, 
      this.email, 
      this.dob, 
      this.phoneNumber, 
      this.city, 
      this.postalCode, 
      this.firstLogin, 
      this.isDeleted, 
      this.gender, 
      this.country, 
      this.address, 
      this.status, 
      this.company, 
      this.emailSubscriptions, 
      this.isVerified, 
      this.immigrationStatus, 
      this.shareCode, 
      this.hobbies, 
      this.interests, 
      this.imageUrl, 
      this.isStudent, 
      this.isActive, 
      this.isHide, 
      this.enableReminder, 
      this.cleaningServices, 
      this.emailVerifiedAt, 
      this.createdAt, 
      this.updatedAt, 
      this.drives, 
      this.hasChildren, 
      this.nextOfKinName, 
      this.nextOfKinRelationship, 
      this.nextOfKinContact, 
      this.preferredStartDate, 
      this.localAreas, 
      this.bankName, 
      this.accountHolderName, 
      this.preferred,
      this.accountNumber,
      this.sortCode, 
      this.cleaningServicesData, 
      this.availableSlots, 
      this.hourBlocks,});

  Staff.fromJson(dynamic json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    dob = json['dob'];
    phoneNumber = json['phone_number'];
    city = json['city'];
    postalCode = json['postal_code'];
    firstLogin = json['first_login'];
    isDeleted = json['is_deleted'];
    gender = json['gender'];
    country = json['country'];
    address = json['address'];
    status = json['status'];
    company = json['company'];
    emailSubscriptions = json['email_subscriptions'];
    isVerified = json['is_verified'];
    immigrationStatus = json['immigration_status'];
    shareCode = json['share_code'];
    hobbies = json['hobbies'];
    interests = json['interests'];
    imageUrl = json['image_url'];
    isStudent = json['is_student'];
    isActive = json['is_active'];
    isHide = json['is_hide'];
    enableReminder = json['enable_reminder'];
    cleaningServices = json['cleaning_services'] != null ? json['cleaning_services'].cast<num>() : [];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    drives = json['drives'];
    hasChildren = json['has_children'];
    nextOfKinName = json['next_of_kin_name'];
    nextOfKinRelationship = json['next_of_kin_relationship'];
    nextOfKinContact = json['next_of_kin_contact'];
    preferredStartDate = json['preferred_start_date'];
    localAreas = json['local_areas'];
    bankName = json['bank_name'];
    accountHolderName = json['account_holder_name'];
    preferred = json['preferred'];
    accountNumber = json['account_number'];
    sortCode = json['sort_code'];
    if (json['cleaning_services_data'] != null) {
      cleaningServicesData = [];
      json['cleaning_services_data'].forEach((v) {
        cleaningServicesData?.add(CleaningServicesData.fromJson(v));
      });
    }
    if (json['available_slots'] != null) {
      availableSlots = [];
      json['available_slots'].forEach((v) {
        availableSlots?.add(AvailableSlots.fromJson(v));
      });
    }
    if (json['hour_blocks'] != null) {
      hourBlocks = [];
      json['hour_blocks'].forEach((v) {
        hourBlocks?.add(String);
      });
    }
  }
  num? id;
  String? firstName;
  String? lastName;
  String? email;
  String? dob;
  String? phoneNumber;
  String? city;
  String? postalCode;
  dynamic firstLogin;
  bool? isDeleted;
  String? gender;
  dynamic country;
  String? address;
  String? status;
  dynamic company;
  dynamic emailSubscriptions;
  bool? isVerified;
  num? immigrationStatus;
  dynamic shareCode;
  String? hobbies;
  dynamic interests;
  String? imageUrl;
  bool? isStudent;
  bool? isActive;
  bool? isHide;
  bool? enableReminder;
  bool? preferred;
  List<num>? cleaningServices;
  dynamic emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? drives;
  String? hasChildren;
  String? nextOfKinName;
  String? nextOfKinRelationship;
  String? nextOfKinContact;
  String? preferredStartDate;
  String? localAreas;
  String? bankName;
  String? accountHolderName;
  String? accountNumber;
  String? sortCode;
  List<CleaningServicesData>? cleaningServicesData;
  List<AvailableSlots>? availableSlots;
  List<dynamic>? hourBlocks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['email'] = email;
    map['dob'] = dob;
    map['phone_number'] = phoneNumber;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['first_login'] = firstLogin;
    map['is_deleted'] = isDeleted;
    map['gender'] = gender;
    map['country'] = country;
    map['address'] = address;
    map['status'] = status;
    map['company'] = company;
    map['email_subscriptions'] = emailSubscriptions;
    map['is_verified'] = isVerified;
    map['immigration_status'] = immigrationStatus;
    map['share_code'] = shareCode;
    map['hobbies'] = hobbies;
    map['interests'] = interests;
    map['image_url'] = imageUrl;
    map['is_student'] = isStudent;
    map['is_active'] = isActive;
    map['is_hide'] = isHide;
    map['enable_reminder'] = enableReminder;
    map['cleaning_services'] = cleaningServices;
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['drives'] = drives;
    map['has_children'] = hasChildren;
    map['next_of_kin_name'] = nextOfKinName;
    map['next_of_kin_relationship'] = nextOfKinRelationship;
    map['next_of_kin_contact'] = nextOfKinContact;
    map['preferred_start_date'] = preferredStartDate;
    map['preferred'] = preferred;
    map['local_areas'] = localAreas;
    map['bank_name'] = bankName;
    map['account_holder_name'] = accountHolderName;
    map['account_number'] = accountNumber;
    map['sort_code'] = sortCode;
    if (cleaningServicesData != null) {
      map['cleaning_services_data'] = cleaningServicesData?.map((v) => v.toJson()).toList();
    }
    if (availableSlots != null) {
      map['available_slots'] = availableSlots?.map((v) => v.toJson()).toList();
    }
    if (hourBlocks != null) {
      map['hour_blocks'] = hourBlocks?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class AvailableSlots {
  AvailableSlots({
      this.id, 
      this.day, 
      this.startTime, 
      this.endTime, 
      this.userId, 
      this.createdAt, 
      this.updatedAt, 
      this.dayName,});

  AvailableSlots.fromJson(dynamic json) {
    id = json['id'];
    day = json['day'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    dayName = json['day_name'];
  }
  num? id;
  String? day;
  String? startTime;
  String? endTime;
  num? userId;
  String? createdAt;
  String? updatedAt;
  String? dayName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['day'] = day;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['user_id'] = userId;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['day_name'] = dayName;
    return map;
  }

}

class CleaningServicesData {
  CleaningServicesData({
      this.id, 
      this.name,});

  CleaningServicesData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
  num? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }

}