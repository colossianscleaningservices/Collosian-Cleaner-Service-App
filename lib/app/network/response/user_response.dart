class UserResponse {
  UserResponse({
    this.user,
  });

  UserResponse.fromJson(dynamic json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }
}

class User {
  User({
    this.id,
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.name,
    this.email,
    this.phoneNumber,
    this.roles,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.isStudent,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    imageUrl = json['image_url'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    // roles = json['roles'] != null ? json['roles'].cast<String>() : [];
    roles = json['roles'] != null ? (json['roles'] as List).map((e) => Roles.fromJson(e as Map<String, dynamic>)).toList() : null;
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];
    isStudent = json['is_student'];
  }

  num? id;
  String? firstName;
  String? lastName;
  String? imageUrl;
  String? name;
  String? email;
  String? phoneNumber;
  List<Roles>? roles;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? token;
  bool? isStudent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['image_url'] = imageUrl;
    map['name'] = name;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    if (roles != null) {
      map['roles'] = roles!.map((e) => e.toJson()).toList();
    }
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['token'] = token;
    map['is_student'] = isStudent;
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
