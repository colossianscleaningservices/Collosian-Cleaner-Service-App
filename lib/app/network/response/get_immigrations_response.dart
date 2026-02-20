class GetImmigrationsResponse {
  GetImmigrationsResponse({
      this.data,});

  GetImmigrationsResponse.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ImmigrationsModel.fromJson(v));
      });
    }
  }
  List<ImmigrationsModel>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class ImmigrationsModel {
  ImmigrationsModel({
      this.id, 
      this.name, 
      this.status,});

  ImmigrationsModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
  }
  num? id;
  String? name;
  dynamic status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['status'] = status;
    return map;
  }

}