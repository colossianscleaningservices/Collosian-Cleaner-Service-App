class GetAgencyResponse {
  GetAgencyResponse({
      this.message, 
      this.version, 
      this.code, 
      this.data,});

  GetAgencyResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Agency.fromJson(v));
      });
    }
  }
  String? message;
  String? version;
  num? code;
  List<Agency>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['version'] = version;
    map['code'] = code;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Agency {
  Agency({
      this.id, 
      this.name,
     this.isSelect = false,
    this.owner,});

  Agency.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    owner = json['owner'] != null ? Owner.fromJson(json['owner']) : null;
  }
  int? id;
  String? name;
  bool isSelect = false;
  Owner? owner;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    if (owner != null) {
      map['owner'] = owner?.toJson();
    }
    return map;
  }

}

class Owner {
  Owner({
      this.id, 
      this.name, 
      this.email,});

  Owner.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }
  num? id;
  String? name;
  String? email;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    return map;
  }

}