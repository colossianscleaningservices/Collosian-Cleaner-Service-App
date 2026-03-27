class ProfileResponse {
  ProfileResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  ProfileResponse.fromJson(dynamic json) {
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
    this.user,
    this.profileCompletion,
  });

  Data.fromJson(dynamic json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    profileCompletion = json['profile_completion'];
    if (json['admins'] != null) {
      admins = [];
      json['admins'].forEach((v) {
        admins?.add(Admins.fromJson(v));
      });
    }
  }

  User? user;
  num? profileCompletion;
  List<Admins>? admins;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (user != null) {
      map['user'] = user?.toJson();
    }
    map['profile_completion'] = profileCompletion;
    if (admins != null) {
      map['admins'] = admins?.map((v) => v.toJson()).toList();
    }
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
    this.nationalInsuranceNumber,
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
    this.updatedAt,
  });

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
    immigration = json['immigration'] != null ? Immigration.fromJson(json['immigration']) : null;
    status = json['status'];
    firstLogin = json['first_login'];
    nationalInsuranceNumber = json['national_insurance_number'];
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
  String? nextOfKinName;
  String? nextOfKinRelationship;
  String? nationalInsuranceNumber;
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
  dynamic emailSubscriptions;
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
    map['national_insurance_number'] = nationalInsuranceNumber;
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
    this.options,
  });

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
    this.area,
  });

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
    this.name,
  });

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
    this.device,
  });

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
    this.lastUpdated,
  });

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
    this.isActive,
  });

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

class Admins {
  Admins({
    this.id,
    this.firstName,
    this.lastName,
  });

  Admins.fromJson(dynamic json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  num? id;
  String? firstName;
  String? lastName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    return map;
  }
}
