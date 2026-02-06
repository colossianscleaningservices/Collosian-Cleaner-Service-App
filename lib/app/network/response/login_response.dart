import 'base_response.dart';

class LoginResponse extends BaseResponse {
  LoginResponse({super.status, super.message, super.errorType, this.data});

  LoginResponse.fromJson(super.json)
      : data = json['data'] != null ? Data.fromJson(json['data']) : null,
        super.fromJson();

  Data? data;

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    this.id,
    this.roleId,
    this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.token,
  });

  Data.fromJson(dynamic json) {
    id = json['id'];
    roleId = json['role_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
  }

  num? id;
  num? roleId;
  String? firstName;
  String? lastName;
  String? name;
  String? email;
  String? token;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'role_id': roleId,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
