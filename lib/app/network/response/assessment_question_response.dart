class AssessmentQuestionResponse {
  AssessmentQuestionResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  AssessmentQuestionResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  String? message;
  String? version;
  num? code;
  Data? data;

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
    this.categoryId,
    this.questions,
    this.total,
  });

  Data.fromJson(dynamic json) {
    categoryId = json['category_id'];
    if (json['questions'] != null) {
      questions = [];
      json['questions'].forEach((v) {
        questions?.add(Questions.fromJson(v));
      });
    }
    total = json['total'];
  }

  num? categoryId;
  List<Questions>? questions;
  num? total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['category_id'] = categoryId;
    if (questions != null) {
      map['questions'] = questions?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    return map;
  }
}

class Questions {
  Questions({
    this.id,
    this.categoryId,
    this.questionText,
    this.options,
  });

  Questions.fromJson(dynamic json) {
    id = json['id'];
    categoryId = json['category_id'];
    questionText = json['question_text'];
    if (json['options'] != null) {
      options = [];
      json['options'].forEach((v) {
        options?.add(Options.fromJson(v));
      });
    }
  }

  num? id;
  num? categoryId;
  String? questionText;
  List<Options>? options;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['category_id'] = categoryId;
    map['question_text'] = questionText;
    if (options != null) {
      map['options'] = options?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Options {
  Options({
    this.text,
    this.label,
  });

  Options.fromJson(dynamic json) {
    text = json['text'];
    label = json['label'];
  }

  String? text;
  String? label;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['text'] = text;
    map['label'] = label;
    return map;
  }
}
