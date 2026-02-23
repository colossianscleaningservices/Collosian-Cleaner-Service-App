class GetClientCalenderResponse {
  GetClientCalenderResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetClientCalenderResponse.fromJson(dynamic json) {
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
      this.total,});

  Data.fromJson(dynamic json) {
    jobs = json['jobs'] != null ? CalendarJobsWrapper.fromJson(json['jobs']) : null;
    total = json['total'] is num ? json['total'] : null;
  }
  CalendarJobsWrapper? jobs;
  num? total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (jobs != null) {
      map['jobs'] = jobs?.toJson();
    }
    map['total'] = total;
    return map;
  }

}

/// Wrapper for calendar API: list of job items and pagination.
class CalendarJobsWrapper {
  CalendarJobsWrapper({this.jobs, this.pagination});

  factory CalendarJobsWrapper.fromJson(dynamic json) {
    List<CalendarJobItem>? list;
    if (json is List) {
      list = [];
      for (final v in json) {
        list.add(CalendarJobItem.fromJson(v));
      }
    } else if (json is Map && json['jobs'] != null && json['jobs'] is List) {
      list = [];
      for (final v in json['jobs'] as List) {
        list.add(CalendarJobItem.fromJson(v));
      }
    }
    return CalendarJobsWrapper(
      jobs: list,
      pagination: json is Map ? json['pagination'] : null,
    );
  }
  List<CalendarJobItem>? jobs;
  dynamic pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (jobs != null) {
      map['jobs'] = jobs?.map((v) => v.toJson()).toList();
    }
    map['pagination'] = pagination;
    return map;
  }
}

/// Single calendar job item from API (date, time, status, cleaning type, property, cleaners).
class CalendarJobItem {
  CalendarJobItem({
    this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    this.propertyName,
    this.address,
    this.cleaningTypeName,
    this.cleanerInfo,
    this.subtitle,
  });

  factory CalendarJobItem.fromJson(dynamic json) {
    String? propertyName;
    String? address;
    if (json['property'] != null && json['property'] is Map) {
      final p = json['property'] as Map;
      propertyName ??= p['property_name'] ?? p['address'];
      address = p['address'];
    }
    propertyName ??= json['property_name'];
    address ??= json['address'];

    String? cleaningTypeName;
    if (json['cleaning_type'] != null && json['cleaning_type'] is Map) {
      cleaningTypeName = json['cleaning_type']['name'];
    }
    cleaningTypeName ??= json['job_type'] ?? json['cleaning_type'];

    String? cleanerInfo;
    if (json['cleaners'] != null && json['cleaners'] is List) {
      final names = <String>[];
      for (final c in json['cleaners'] as List) {
        if (c is Map) {
          final n = c['name'] ?? (c['first_name'] != null || c['last_name'] != null
              ? '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}'.trim()
              : null);
          if (n != null && n.isNotEmpty) names.add(n);
        }
      }
      cleanerInfo = names.isNotEmpty ? names.join(', ') : null;
    }
    if (cleanerInfo == null && json['number_of_cleaners'] != null) {
      final n = json['number_of_cleaners'];
      cleanerInfo = n == 1 ? '1 cleaner' : '$n cleaners';
    }

    final subtitle = json['additional_details'] ?? json['notes'] ?? json['description'];

    return CalendarJobItem(
      id: json['id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      propertyName: propertyName,
      address: address,
      cleaningTypeName: cleaningTypeName is String ? cleaningTypeName : null,
      cleanerInfo: cleanerInfo,
      subtitle: subtitle is String ? subtitle : null,
    );
  }
  num? id;
  String? date;
  String? startTime;
  String? endTime;
  String? status;
  String? propertyName;
  String? address;
  String? cleaningTypeName;
  String? cleanerInfo;
  String? subtitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['date'] = date;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['status'] = status;
    map['property_name'] = propertyName;
    map['address'] = address;
    map['cleaning_type_name'] = cleaningTypeName;
    map['cleaner_info'] = cleanerInfo;
    map['subtitle'] = subtitle;
    return map;
  }
}

class Cleaners {
  Cleaners({
      this.id, 
      this.firstName, 
      this.lastName, 
      this.name, 
      this.email, 
      this.phoneNumber, 
      this.dob, 
      this.gender, 
      this.company, 
      this.address, 
      this.city, 
      this.postalCode, 
      this.country, 
      this.nextOfKinName, 
      this.nextOfKinRelationship, 
      this.nextOfKinContact, 
      this.preferredStartDate, 
      this.drives, 
      this.localAreas, 
      this.hasChildren, 
      this.bankName, 
      this.accountHolderName, 
      this.accountNumber, 
      this.sortCode, 
      this.immigrationStatus, 
      this.immigration, 
      this.status, 
      this.firstLogin, 
      this.isDeleted, 
      this.isVerified, 
      this.isStudent, 
      this.isActive, 
      this.isHide, 
      this.enableReminder, 
      this.extraFields, 
      this.emailSubscriptions, 
      this.shareCode, 
      this.hobbies, 
      this.interests, 
      this.imageUrl, 
      this.roles, 
      this.cleaningServices, 
      this.emailVerifiedAt, 
      this.createdAt, 
      this.updatedAt,});

  Cleaners.fromJson(dynamic json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    dob = json['dob'];
    gender = json['gender'];
    company = json['company'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    country = json['country'];
    nextOfKinName = json['next_of_kin_name'];
    nextOfKinRelationship = json['next_of_kin_relationship'];
    nextOfKinContact = json['next_of_kin_contact'];
    preferredStartDate = json['preferred_start_date'];
    drives = json['drives'];
    localAreas = json['local_areas'];
    hasChildren = json['has_children'];
    bankName = json['bank_name'];
    accountHolderName = json['account_holder_name'];
    accountNumber = json['account_number'];
    sortCode = json['sort_code'];
    immigrationStatus = json['immigration_status'];
    immigration = json['immigration'] != null ? Immigration.fromJson(json['immigration']) : null;
    status = json['status'];
    firstLogin = json['first_login'];
    isDeleted = json['is_deleted'];
    isVerified = json['is_verified'];
    isStudent = json['is_student'];
    isActive = json['is_active'];
    isHide = json['is_hide'];
    enableReminder = json['enable_reminder'];
    extraFields = json['extra_fields'] != null ? ExtraFields.fromJson(json['extra_fields']) : null;
    emailSubscriptions = json['email_subscriptions'];
    shareCode = json['share_code'];
    hobbies = json['hobbies'];
    interests = json['interests'];
    imageUrl = json['image_url'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles?.add(Roles.fromJson(v));
      });
    }
    if (json['cleaning_services'] != null) {
      cleaningServices = [];
      json['cleaning_services'].forEach((v) {
        cleaningServices?.add(CleaningServices.fromJson(v));
      });
    }
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? firstName;
  String? lastName;
  String? name;
  String? email;
  String? phoneNumber;
  String? dob;
  String? gender;
  dynamic company;
  String? address;
  String? city;
  String? postalCode;
  dynamic country;
  String? nextOfKinName;
  String? nextOfKinRelationship;
  String? nextOfKinContact;
  String? preferredStartDate;
  String? drives;
  String? localAreas;
  String? hasChildren;
  String? bankName;
  String? accountHolderName;
  String? accountNumber;
  String? sortCode;
  num? immigrationStatus;
  Immigration? immigration;
  String? status;
  dynamic firstLogin;
  bool? isDeleted;
  bool? isVerified;
  bool? isStudent;
  bool? isActive;
  bool? isHide;
  bool? enableReminder;
  ExtraFields? extraFields;
  String? emailSubscriptions;
  dynamic shareCode;
  String? hobbies;
  dynamic interests;
  String? imageUrl;
  List<Roles>? roles;
  List<CleaningServices>? cleaningServices;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['name'] = name;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    map['dob'] = dob;
    map['gender'] = gender;
    map['company'] = company;
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['country'] = country;
    map['next_of_kin_name'] = nextOfKinName;
    map['next_of_kin_relationship'] = nextOfKinRelationship;
    map['next_of_kin_contact'] = nextOfKinContact;
    map['preferred_start_date'] = preferredStartDate;
    map['drives'] = drives;
    map['local_areas'] = localAreas;
    map['has_children'] = hasChildren;
    map['bank_name'] = bankName;
    map['account_holder_name'] = accountHolderName;
    map['account_number'] = accountNumber;
    map['sort_code'] = sortCode;
    map['immigration_status'] = immigrationStatus;
    if (immigration != null) {
      map['immigration'] = immigration?.toJson();
    }
    map['status'] = status;
    map['first_login'] = firstLogin;
    map['is_deleted'] = isDeleted;
    map['is_verified'] = isVerified;
    map['is_student'] = isStudent;
    map['is_active'] = isActive;
    map['is_hide'] = isHide;
    map['enable_reminder'] = enableReminder;
    if (extraFields != null) {
      map['extra_fields'] = extraFields?.toJson();
    }
    map['email_subscriptions'] = emailSubscriptions;
    map['share_code'] = shareCode;
    map['hobbies'] = hobbies;
    map['interests'] = interests;
    map['image_url'] = imageUrl;
    if (roles != null) {
      map['roles'] = roles?.map((v) => v.toJson()).toList();
    }
    if (cleaningServices != null) {
      map['cleaning_services'] = cleaningServices?.map((v) => v.toJson()).toList();
    }
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}

class CleaningServices {
  CleaningServices({
      this.id, 
      this.name, 
      this.options,});

  CleaningServices.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    if (json['options'] != null) {
      options = [];
      json['options'].forEach((v) {
        options?.add(Options.fromJson(v));
      });
    }
  }
  num? id;
  String? name;
  List<Options>? options;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    if (options != null) {
      map['options'] = options?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Options {
  Options({
      this.id, 
      this.name, 
      this.area,});

  Options.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    area = json['area'];
  }
  num? id;
  String? name;
  dynamic area;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['area'] = area;
    return map;
  }

}

class Roles {
  Roles({
      this.id, 
      this.name,});

  Roles.fromJson(dynamic json) {
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

class Immigration {
  Immigration({
      this.id, 
      this.name, 
      this.isActive,});

  Immigration.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    isActive = json['is_active'];
  }
  num? id;
  String? name;
  num? isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['is_active'] = isActive;
    return map;
  }

}

class Property {
  Property({
      this.id, 
      this.userId, 
      this.propertyName, 
      this.address, 
      this.city, 
      this.postalCode, 
      this.bussinessType, 
      this.propertyType, 
      this.subType, 
      this.animalProperty, 
      this.hoover, 
      this.provideCleaningProducts, 
      this.provideWashingMachine, 
      this.provideDryer, 
      this.staffPreference, 
      this.accessToProperty, 
      this.additionalDetails, 
      this.isDeleted, 
      this.bedrooms, 
      this.bathrooms, 
      this.separateGuestToilet, 
      this.livingRooms, 
      this.office, 
      this.conservatory, 
      this.diningRoom, 
      this.createdAt, 
      this.updatedAt,});

  Property.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    propertyName = json['property_name'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    bussinessType = json['bussiness_type'];
    propertyType = json['property_type'];
    subType = json['sub_type'];
    animalProperty = json['animal_property'];
    hoover = json['hoover'];
    provideCleaningProducts = json['provide_cleaning_products'];
    provideWashingMachine = json['provide_washing_machine'];
    provideDryer = json['provide_dryer'];
    staffPreference = json['staff_preference'];
    accessToProperty = json['access_to_property'];
    additionalDetails = json['additional_details'];
    isDeleted = json['is_deleted'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    separateGuestToilet = json['separate_guest_toilet'];
    livingRooms = json['living_rooms'];
    office = json['office'];
    conservatory = json['conservatory'];
    diningRoom = json['dining_room'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? userId;
  String? propertyName;
  String? address;
  String? city;
  String? postalCode;
  String? bussinessType;
  String? propertyType;
  String? subType;
  String? animalProperty;
  String? hoover;
  bool? provideCleaningProducts;
  bool? provideWashingMachine;
  bool? provideDryer;
  String? staffPreference;
  String? accessToProperty;
  dynamic additionalDetails;
  bool? isDeleted;
  num? bedrooms;
  num? bathrooms;
  num? separateGuestToilet;
  num? livingRooms;
  num? office;
  num? conservatory;
  num? diningRoom;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['property_name'] = propertyName;
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['bussiness_type'] = bussinessType;
    map['property_type'] = propertyType;
    map['sub_type'] = subType;
    map['animal_property'] = animalProperty;
    map['hoover'] = hoover;
    map['provide_cleaning_products'] = provideCleaningProducts;
    map['provide_washing_machine'] = provideWashingMachine;
    map['provide_dryer'] = provideDryer;
    map['staff_preference'] = staffPreference;
    map['access_to_property'] = accessToProperty;
    map['additional_details'] = additionalDetails;
    map['is_deleted'] = isDeleted;
    map['bedrooms'] = bedrooms;
    map['bathrooms'] = bathrooms;
    map['separate_guest_toilet'] = separateGuestToilet;
    map['living_rooms'] = livingRooms;
    map['office'] = office;
    map['conservatory'] = conservatory;
    map['dining_room'] = diningRoom;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}

class User {
  User({
      this.id, 
      this.firstName, 
      this.lastName, 
      this.name, 
      this.email, 
      this.phoneNumber, 
      this.dob, 
      this.gender, 
      this.company, 
      this.address, 
      this.city, 
      this.postalCode, 
      this.country, 
      this.nextOfKinName, 
      this.nextOfKinRelationship, 
      this.nextOfKinContact, 
      this.preferredStartDate, 
      this.drives, 
      this.localAreas, 
      this.hasChildren, 
      this.bankName, 
      this.accountHolderName, 
      this.accountNumber, 
      this.sortCode, 
      this.immigrationStatus, 
      this.immigration, 
      this.status, 
      this.firstLogin, 
      this.isDeleted, 
      this.isVerified, 
      this.isStudent, 
      this.isActive, 
      this.isHide, 
      this.enableReminder, 
      this.extraFields, 
      this.emailSubscriptions, 
      this.shareCode, 
      this.hobbies, 
      this.interests, 
      this.imageUrl, 
      this.roles, 
      this.cleaningServices, 
      this.emailVerifiedAt, 
      this.createdAt, 
      this.updatedAt,});

  User.fromJson(dynamic json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    dob = json['dob'];
    gender = json['gender'];
    company = json['company'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    country = json['country'];
    nextOfKinName = json['next_of_kin_name'];
    nextOfKinRelationship = json['next_of_kin_relationship'];
    nextOfKinContact = json['next_of_kin_contact'];
    preferredStartDate = json['preferred_start_date'];
    drives = json['drives'];
    localAreas = json['local_areas'];
    hasChildren = json['has_children'];
    bankName = json['bank_name'];
    accountHolderName = json['account_holder_name'];
    accountNumber = json['account_number'];
    sortCode = json['sort_code'];
    immigrationStatus = json['immigration_status'];
    immigration = json['immigration'];
    status = json['status'];
    firstLogin = json['first_login'];
    isDeleted = json['is_deleted'];
    isVerified = json['is_verified'];
    isStudent = json['is_student'];
    isActive = json['is_active'];
    isHide = json['is_hide'];
    enableReminder = json['enable_reminder'];
    extraFields = json['extra_fields'] != null ? ExtraFields.fromJson(json['extra_fields']) : null;
    emailSubscriptions = json['email_subscriptions'];
    shareCode = json['share_code'];
    hobbies = json['hobbies'];
    interests = json['interests'];
    imageUrl = json['image_url'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles?.add(Roles.fromJson(v));
      });
    }
    if (json['cleaning_services'] != null) {
      cleaningServices = [];
      json['cleaning_services'].forEach((v) {
        cleaningServices?.add(CleaningServices.fromJson(v));
      });
    }
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? firstName;
  String? lastName;
  String? name;
  String? email;
  String? phoneNumber;
  String? dob;
  String? gender;
  String? company;
  String? address;
  String? city;
  String? postalCode;
  dynamic country;
  dynamic nextOfKinName;
  dynamic nextOfKinRelationship;
  dynamic nextOfKinContact;
  dynamic preferredStartDate;
  dynamic drives;
  dynamic localAreas;
  dynamic hasChildren;
  dynamic bankName;
  dynamic accountHolderName;
  dynamic accountNumber;
  dynamic sortCode;
  dynamic immigrationStatus;
  dynamic immigration;
  dynamic status;
  dynamic firstLogin;
  bool? isDeleted;
  bool? isVerified;
  bool? isStudent;
  bool? isActive;
  bool? isHide;
  bool? enableReminder;
  ExtraFields? extraFields;
  String? emailSubscriptions;
  dynamic shareCode;
  dynamic hobbies;
  dynamic interests;
  String? imageUrl;
  List<Roles>? roles;
  List<CleaningServices>? cleaningServices;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['name'] = name;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    map['dob'] = dob;
    map['gender'] = gender;
    map['company'] = company;
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['country'] = country;
    map['next_of_kin_name'] = nextOfKinName;
    map['next_of_kin_relationship'] = nextOfKinRelationship;
    map['next_of_kin_contact'] = nextOfKinContact;
    map['preferred_start_date'] = preferredStartDate;
    map['drives'] = drives;
    map['local_areas'] = localAreas;
    map['has_children'] = hasChildren;
    map['bank_name'] = bankName;
    map['account_holder_name'] = accountHolderName;
    map['account_number'] = accountNumber;
    map['sort_code'] = sortCode;
    map['immigration_status'] = immigrationStatus;
    map['immigration'] = immigration;
    map['status'] = status;
    map['first_login'] = firstLogin;
    map['is_deleted'] = isDeleted;
    map['is_verified'] = isVerified;
    map['is_student'] = isStudent;
    map['is_active'] = isActive;
    map['is_hide'] = isHide;
    map['enable_reminder'] = enableReminder;
    if (extraFields != null) {
      map['extra_fields'] = extraFields?.toJson();
    }
    map['email_subscriptions'] = emailSubscriptions;
    map['share_code'] = shareCode;
    map['hobbies'] = hobbies;
    map['interests'] = interests;
    map['image_url'] = imageUrl;
    if (roles != null) {
      map['roles'] = roles?.map((v) => v.toJson()).toList();
    }
    if (cleaningServices != null) {
      map['cleaning_services'] = cleaningServices?.map((v) => v.toJson()).toList();
    }
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}
