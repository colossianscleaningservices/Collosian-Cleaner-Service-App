class ProfileResponse {
  ProfileResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

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
      this.profileCompletion,});

  Data.fromJson(dynamic json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    profileCompletion = json['profile_completion'];
  }
  User? user;
  num? profileCompletion;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (user != null) {
      map['user'] = user?.toJson();
    }
    map['profile_completion'] = profileCompletion;
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
      this.address, 
      this.city, 
      this.postalCode, 
      this.dob, 
      this.gender, 
      this.company, 
      this.roles, 
      this.emailVerifiedAt, 
      this.imageUrl, 
      this.enableReminder, 
      this.createdAt, 
      this.updatedAt,});

  User.fromJson(dynamic json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    city = json['city'];
    postalCode = json['postal_code'];
    dob = json['dob'];
    gender = json['gender'];
    company = json['company'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles?.add(Roles.fromJson(v));
      });
    }
    emailVerifiedAt = json['email_verified_at'];
    imageUrl = json['image_url'];
    enableReminder = json['enable_reminder'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? firstName;
  String? lastName;
  String? name;
  String? email;
  String? phoneNumber;
  String? address;
  String? city;
  String? postalCode;
  String? dob;
  String? gender;
  String? company;
  List<Roles>? roles;
  String? emailVerifiedAt;
  String? imageUrl;
  bool? enableReminder;
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
    map['address'] = address;
    map['city'] = city;
    map['postal_code'] = postalCode;
    map['dob'] = dob;
    map['gender'] = gender;
    map['company'] = company;
    if (roles != null) {
      map['roles'] = roles?.map((v) => v.toJson()).toList();
    }
    map['email_verified_at'] = emailVerifiedAt;
    map['image_url'] = imageUrl;
    map['enable_reminder'] = enableReminder;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
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