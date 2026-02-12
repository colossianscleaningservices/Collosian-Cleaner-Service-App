import 'package:ccs_app/app/network/response/base_response.dart';

class FaqResponse extends BaseResponse {
  FaqResponse({
      this.data,});

  FaqResponse.fromJson(dynamic json) {
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
      this.faq,});

  Data.fromJson(dynamic json) {
    if (json['faq'] != null) {
      faq = [];
      json['faq'].forEach((v) {
        faq?.add(Faq.fromJson(v));
      });
    }
  }
  List<Faq>? faq;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (faq != null) {
      map['faq'] = faq?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Faq {
  Faq({
      this.id, 
      this.question, 
      this.answer,});

  Faq.fromJson(dynamic json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
  }
  num? id;
  String? question;
  String? answer;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['question'] = question;
    map['answer'] = answer;
    return map;
  }

}