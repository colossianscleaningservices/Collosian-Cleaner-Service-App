import 'get_client_job_response.dart';

class CleanerJobResponse {
  CleanerJobResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  CleanerJobResponse.fromJson(dynamic json) {
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
      this.jobs, 
      this.pagination,});

  Data.fromJson(dynamic json) {
    if (json['jobs'] != null) {
      jobs = [];
      json['jobs'].forEach((v) {
        jobs?.add(Jobs.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<Jobs>? jobs;
  Pagination? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (jobs != null) {
      map['jobs'] = jobs?.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    return map;
  }

}

class Jobs {
  Jobs({
      this.id, 
      this.date, 
      this.startTime, 
      this.endTime, 
      this.areaRequirement, 
      this.accessToProperty, 
      this.provideCleaningProducts, 
      this.staffPreference, 
      this.before, 
      this.after, 
      this.status, 
      this.isApproved, 
      this.propertyId, 
      this.userId, 
      this.pricingChartId, 
      this.isDeleted, 
      this.cleaningType, 
      this.additionalDetails, 
      this.hoover, 
      this.provideWashingMachine, 
      this.provideDryer, 
      this.additionalData, 
      this.notified, 
      this.scheduleId, 
      this.jobStartDate, 
      this.jobEndDate, 
      this.jobType, 
      this.numberOfCleaners, 
      this.numberOfGuests, 
      this.celebrationType, 
      this.venueAddress, 
      this.createdAt, 
      this.updatedAt, 
      this.user, 
      this.property, 
      this.jobCleaners,});

  Jobs.fromJson(dynamic json) {
    id = json['id'];
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    areaRequirement = json['area_requirement'];
    accessToProperty = json['access_to_property'];
    provideCleaningProducts = json['provide_cleaning_products'];
    staffPreference = json['staff_preference'];
    before = json['before'];
    after = json['after'];
    status = json['status'];
    isApproved = json['is_approved'];
    propertyId = json['property_id'];
    userId = json['user_id'];
    pricingChartId = json['pricing_chart_id'];
    isDeleted = json['is_deleted'];
    cleaningType = json['cleaning_type'] != null ? CleaningType.fromJson(json['cleaning_type']) : null;
    additionalDetails = json['additional_details'];
    hoover = json['hoover'];
    provideWashingMachine = json['provide_washing_machine'];
    provideDryer = json['provide_dryer'];
    additionalData = json['additional_data'];
    notified = json['notified'];
    scheduleId = json['schedule_id'];
    jobStartDate = json['job_start_Date'];
    jobEndDate = json['job_end_date'];
    jobType = json['job_type'];
    numberOfCleaners = json['number_of_cleaners'];
    numberOfGuests = json['number_of_guests'];
    celebrationType = json['celebration_type'];
    venueAddress = json['venue_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    property = json['property'] != null ? Property.fromJson(json['property']) : null;
    if (json['job_cleaners'] != null) {
      jobCleaners = [];
      json['job_cleaners'].forEach((v) {
        jobCleaners?.add(JobCleaners.fromJson(v));
      });
    }
  }
  num? id;
  String? date;
  String? startTime;
  String? endTime;
  dynamic areaRequirement;
  String? accessToProperty;
  bool? provideCleaningProducts;
  String? staffPreference;
  dynamic before;
  dynamic after;
  String? status;
  bool? isApproved;
  num? propertyId;
  num? userId;
  dynamic pricingChartId;
  bool? isDeleted;
  CleaningType? cleaningType;
  String? additionalDetails;
  String? hoover;
  bool? provideWashingMachine;
  bool? provideDryer;
  dynamic additionalData;
  dynamic notified;
  dynamic scheduleId;
  dynamic jobStartDate;
  dynamic jobEndDate;
  String? jobType;
  num? numberOfCleaners;
  dynamic numberOfGuests;
  dynamic celebrationType;
  dynamic venueAddress;
  String? createdAt;
  String? updatedAt;
  User? user;
  Property? property;
  List<JobCleaners>? jobCleaners;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['date'] = date;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['area_requirement'] = areaRequirement;
    map['access_to_property'] = accessToProperty;
    map['provide_cleaning_products'] = provideCleaningProducts;
    map['staff_preference'] = staffPreference;
    map['before'] = before;
    map['after'] = after;
    map['status'] = status;
    map['is_approved'] = isApproved;
    map['property_id'] = propertyId;
    map['user_id'] = userId;
    map['pricing_chart_id'] = pricingChartId;
    map['is_deleted'] = isDeleted;
    if (cleaningType != null) {
      map['cleaning_type'] = cleaningType?.toJson();
    }
    map['additional_details'] = additionalDetails;
    map['hoover'] = hoover;
    map['provide_washing_machine'] = provideWashingMachine;
    map['provide_dryer'] = provideDryer;
    map['additional_data'] = additionalData;
    map['notified'] = notified;
    map['schedule_id'] = scheduleId;
    map['job_start_Date'] = jobStartDate;
    map['job_end_date'] = jobEndDate;
    map['job_type'] = jobType;
    map['number_of_cleaners'] = numberOfCleaners;
    map['number_of_guests'] = numberOfGuests;
    map['celebration_type'] = celebrationType;
    map['venue_address'] = venueAddress;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (property != null) {
      map['property'] = property?.toJson();
    }
    if (jobCleaners != null) {
      map['job_cleaners'] = jobCleaners?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class JobCleaners {
  JobCleaners({
      this.id, 
      this.status, 
      this.reason, 
      this.startTime, 
      this.endTime, 
      this.jobId, 
      this.userId, 
      this.isReviewed, 
      this.checkInDate, 
      this.checkOutDate, 
      this.createdAt, 
      this.updatedAt, 
      this.user,});

  JobCleaners.fromJson(dynamic json) {
    id = json['id'];
    status = json['status'];
    reason = json['reason'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    jobId = json['job_id'];
    userId = json['user_id'];
    isReviewed = json['is_reviewed'];
    checkInDate = json['check_in_date'];
    checkOutDate = json['check_out_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  num? id;
  String? status;
  dynamic reason;
  String? startTime;
  String? endTime;
  num? jobId;
  num? userId;
  bool? isReviewed;
  dynamic checkInDate;
  dynamic checkOutDate;
  String? createdAt;
  String? updatedAt;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['status'] = status;
    map['reason'] = reason;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['job_id'] = jobId;
    map['user_id'] = userId;
    map['is_reviewed'] = isReviewed;
    map['check_in_date'] = checkInDate;
    map['check_out_date'] = checkOutDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

}

class ExtraFields {
  ExtraFields({
      this.device,});

  ExtraFields.fromJson(dynamic json) {
    device = json['device'] != null ? Device.fromJson(json['device']) : null;
  }
  Device? device;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (device != null) {
      map['device'] = device?.toJson();
    }
    return map;
  }

}

class Device {
  Device({
      this.platform, 
      this.appVersion, 
      this.debug, 
      this.ip, 
      this.timezone, 
      this.onesignalPlayerId, 
      this.lastUpdated,});

  Device.fromJson(dynamic json) {
    platform = json['platform'];
    appVersion = json['app_version'];
    debug = json['debug'];
    ip = json['ip'];
    timezone = json['timezone'];
    onesignalPlayerId = json['onesignal_player_id'];
    lastUpdated = json['last_updated'];
  }
  String? platform;
  String? appVersion;
  bool? debug;
  String? ip;
  String? timezone;
  String? onesignalPlayerId;
  String? lastUpdated;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['platform'] = platform;
    map['app_version'] = appVersion;
    map['debug'] = debug;
    map['ip'] = ip;
    map['timezone'] = timezone;
    map['onesignal_player_id'] = onesignalPlayerId;
    map['last_updated'] = lastUpdated;
    return map;
  }

}

class Property {
  Property({
      this.id, 
      this.propertyName, 
      this.city, 
      this.postalCode, 
      this.animalProperty, 
      this.userId, 
      this.propertyType, 
      this.subType, 
      this.isDeleted, 
      this.address, 
      this.additionalDetails, 
      this.accessToProperty, 
      this.hoover, 
      this.provideCleaningProducts, 
      this.provideWashingMachine, 
      this.provideDryer, 
      this.staffPreference, 
      this.bussinessType, 
      this.createdAt, 
      this.updatedAt, 
      this.bedrooms, 
      this.bathrooms, 
      this.separateGuestToilet, 
      this.livingRooms, 
      this.office, 
      this.conservatory, 
      this.diningRoom,});

  Property.fromJson(dynamic json) {
    id = json['id'];
    propertyName = json['property_name'];
    city = json['city'];
    postalCode = json['postal_code'];
    animalProperty = json['animal_property'];
    userId = json['user_id'];
    propertyType = json['property_type'];
    subType = json['sub_type'];
    isDeleted = json['is_deleted'];
    address = json['address'];
    additionalDetails = json['additional_details'];
    accessToProperty = json['access_to_property'];
    hoover = json['hoover'];
    provideCleaningProducts = json['provide_cleaning_products'];
    provideWashingMachine = json['provide_washing_machine'];
    provideDryer = json['provide_dryer'];
    staffPreference = json['staff_preference'];
    bussinessType = json['bussiness_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    separateGuestToilet = json['separate_guest_toilet'];
    livingRooms = json['living_rooms'];
    office = json['office'];
    conservatory = json['conservatory'];
    diningRoom = json['dining_room'];
  }
  num? id;
  String? propertyName;
  String? city;
  String? postalCode;
  String? animalProperty;
  num? userId;
  String? propertyType;
  String? subType;
  bool? isDeleted;
  String? address;
  dynamic additionalDetails;
  String? accessToProperty;
  String? hoover;
  bool? provideCleaningProducts;
  bool? provideWashingMachine;
  bool? provideDryer;
  String? staffPreference;
  String? bussinessType;
  String? createdAt;
  String? updatedAt;
  num? bedrooms;
  num? bathrooms;
  num? separateGuestToilet;
  num? livingRooms;
  num? office;
  num? conservatory;
  num? diningRoom;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['property_name'] = propertyName;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['animal_property'] = animalProperty;
    map['user_id'] = userId;
    map['property_type'] = propertyType;
    map['sub_type'] = subType;
    map['is_deleted'] = isDeleted;
    map['address'] = address;
    map['additional_details'] = additionalDetails;
    map['access_to_property'] = accessToProperty;
    map['hoover'] = hoover;
    map['provide_cleaning_products'] = provideCleaningProducts;
    map['provide_washing_machine'] = provideWashingMachine;
    map['provide_dryer'] = provideDryer;
    map['staff_preference'] = staffPreference;
    map['bussiness_type'] = bussinessType;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['bedrooms'] = bedrooms;
    map['bathrooms'] = bathrooms;
    map['separate_guest_toilet'] = separateGuestToilet;
    map['living_rooms'] = livingRooms;
    map['office'] = office;
    map['conservatory'] = conservatory;
    map['dining_room'] = diningRoom;
    return map;
  }

}

class User {
  User({
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
      this.extraFields, 
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
      this.accountNumber, 
      this.sortCode,});

  User.fromJson(dynamic json) {
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
    extraFields = json['extra_fields'] != null ? ExtraFields.fromJson(json['extra_fields']) : null;
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
    cleaningServices = json['cleaning_services'];
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
    accountNumber = json['account_number'];
    sortCode = json['sort_code'];
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
  ExtraFields? extraFields;
  dynamic status;
  String? company;
  String? emailSubscriptions;
  bool? isVerified;
  dynamic immigrationStatus;
  dynamic shareCode;
  dynamic hobbies;
  dynamic interests;
  String? imageUrl;
  bool? isStudent;
  bool? isActive;
  bool? isHide;
  bool? enableReminder;
  dynamic cleaningServices;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  dynamic drives;
  dynamic hasChildren;
  dynamic nextOfKinName;
  dynamic nextOfKinRelationship;
  dynamic nextOfKinContact;
  dynamic preferredStartDate;
  dynamic localAreas;
  dynamic bankName;
  dynamic accountHolderName;
  dynamic accountNumber;
  dynamic sortCode;

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
    if (extraFields != null) {
      map['extra_fields'] = extraFields?.toJson();
    }
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
    map['local_areas'] = localAreas;
    map['bank_name'] = bankName;
    map['account_holder_name'] = accountHolderName;
    map['account_number'] = accountNumber;
    map['sort_code'] = sortCode;
    return map;
  }

}

class CleaningType {
  CleaningType({
      this.id, 
      this.name, 
      this.description, 
      this.isActive, 
      this.isDeleted, 
      this.sortOrder, 
      this.createdAt, 
      this.updatedAt,});

  CleaningType.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    isActive = json['is_active'];
    isDeleted = json['is_deleted'];
    sortOrder = json['sort_order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? name;
  String? description;
  bool? isActive;
  bool? isDeleted;
  num? sortOrder;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['description'] = description;
    map['is_active'] = isActive;
    map['is_deleted'] = isDeleted;
    map['sort_order'] = sortOrder;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}