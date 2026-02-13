import 'package:ccs_app/app/network/response/base_response.dart';

class PropertyTypeResponse extends BaseResponse {
  PropertyTypeResponse({
      this.data,});

  PropertyTypeResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Data? data;

  @override
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
      this.propertyTypes, 
      this.pagination,});

  Data.fromJson(dynamic json) {
    if (json['property_types'] != null) {
      propertyTypes = [];
      json['property_types'].forEach((v) {
        propertyTypes?.add(PropertyTypes.fromJson(v));
      });
    }
    pagination = json['pagination'];
  }
  List<PropertyTypes>? propertyTypes;
  dynamic pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (propertyTypes != null) {
      map['property_types'] = propertyTypes?.map((v) => v.toJson()).toList();
    }
    map['pagination'] = pagination;
    return map;
  }

}

class PropertyTypes {
  PropertyTypes({
      this.id, 
      this.name, 
      this.hasSubtypes, 
      this.subtypesCount, 
      this.createdAt, 
      this.updatedAt,});

  PropertyTypes.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    hasSubtypes = json['has_subtypes'];
    subtypesCount = json['subtypes_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? name;
  bool? hasSubtypes;
  num? subtypesCount;
  dynamic createdAt;
  dynamic updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['has_subtypes'] = hasSubtypes;
    map['subtypes_count'] = subtypesCount;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}