class BaseResponse {
  BaseResponse({this.version, this.code, this.message, this.errorType});

  BaseResponse.fromJson(dynamic json) {
    message = json['message'] as String?;
    version = json['version'] as String?;
    code = json['code'] as num?;
    errorType = json['error_type'] as String?;
  }

  String? version;
  num? code;
  String? message;
  String? errorType;

  Map<String, dynamic> toJson() {
    return {'status': version, 'code': code, 'message': message, 'error_type': errorType};
  }
}

/// Generic success response with a [data] payload (e.g. categories, forms, list results).
class DataResponse extends BaseResponse {
  DataResponse({super.version, super.code, super.message, super.errorType, this.data});

  DataResponse.fromJson(super.json) : data = json['data'], super.fromJson();

  dynamic data;

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    if (data != null) map['data'] = data;
    return map;
  }
}
