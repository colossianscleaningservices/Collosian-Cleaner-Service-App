class BaseResponse {
  BaseResponse({this.status, this.message, this.errorType});

  BaseResponse.fromJson(dynamic json) {
    status = json['status'] as String?;
    message = json['message'] as String?;
    errorType = json['error_type'] as String?;
  }

  String? status;
  String? message;
  String? errorType;

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'error_type': errorType};
  }
}

/// Generic success response with a [data] payload (e.g. categories, forms, list results).
class DataResponse extends BaseResponse {
  DataResponse({super.status, super.message, super.errorType, this.data});

  DataResponse.fromJson(dynamic json) : data = json['data'], super.fromJson(json);

  dynamic data;

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    if (data != null) map['data'] = data;
    return map;
  }
}
