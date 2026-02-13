import 'package:ccs_app/app/network/response/base_response.dart';
import 'package:ccs_app/app/network/response/property_type_response.dart';

class PropertySubTypeResponse extends BaseResponse {
  PropertySubTypeResponse({
    this.data,
  });

  PropertySubTypeResponse.fromJson(dynamic json) {
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
    this.propertySubtypes,
    this.pagination,
  });

  Data.fromJson(dynamic json) {
    if (json['property_subtypes'] != null) {
      propertySubtypes = [];
      json['property_subtypes'].forEach((v) {
        propertySubtypes?.add(PropertySubtypes.fromJson(v));
      });
    }
    pagination = json['pagination'];
  }

  List<PropertySubtypes>? propertySubtypes;
  dynamic pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (propertySubtypes != null) {
      map['property_subtypes'] = propertySubtypes?.map((v) => v.toJson()).toList();
    }
    map['pagination'] = pagination;
    return map;
  }
}

class PropertySubtypes {
  PropertySubtypes({
    this.id,
    this.name,
    this.propertyTypeId,
    this.propertyType,
    this.createdAt,
    this.updatedAt,
  });

  PropertySubtypes.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    propertyTypeId = json['property_type_id'];
    propertyType = json['property_type'] != null ? PropertyTypes.fromJson(json['property_type']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  num? propertyTypeId;
  PropertyTypes? propertyType;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['property_type_id'] = propertyTypeId;
    if (propertyType != null) {
      map['property_type'] = propertyType?.toJson();
    }
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
