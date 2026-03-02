class CleanerPropertiesResponse {
  CleanerPropertiesResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  CleanerPropertiesResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }

  String? message;
  String? version;
  num? code;
  List<Data>? data;

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

class Data {
  Data({
    this.id,
    this.propertyName,
  });

  Data.fromJson(dynamic json) {
    id = json['id'];
    propertyName = json['property_name'];
  }

  num? id;
  String? propertyName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['property_name'] = propertyName;
    return map;
  }
}
