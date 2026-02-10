/// API error body model (mirrors WAVTech DefaultApiError).
/// Map your backend error JSON keys here (e.g. status, error_type, message, data).
class DefaultApiError {
  DefaultApiError({this.status, this.type, this.message, this.data});

  DefaultApiError.fromJson(dynamic json) {
    status = json['status']?.toString();
    type = json['error_type']?.toString();
    message = json['message']?.toString();
    data = json['data'];
  }

  String? status;
  String? type;
  String? message;
  dynamic data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['error_type'] = type;
    map['message'] = message;
    map['data'] = data;
    return map;
  }
}
