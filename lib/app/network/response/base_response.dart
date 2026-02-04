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
