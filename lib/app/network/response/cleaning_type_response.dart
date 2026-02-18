class CleaningTypeResponse {
  CleaningTypeResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  CleaningTypeResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(CleaningTypeModel.fromJson(v));
      });
    }
  }

  String? message;
  String? version;
  num? code;
  List<CleaningTypeModel>? data;

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

class CleaningTypeModel {
  CleaningTypeModel({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.isSelect = false,
    this.updatedAt,
  });

  CleaningTypeModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    isActive = json['is_active'];
    sortOrder = json['sort_order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  String? description;
  bool? isActive;
  num? sortOrder;
  String? createdAt;
  String? updatedAt;
  bool isSelect = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['description'] = description;
    map['is_active'] = isActive;
    map['sort_order'] = sortOrder;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
