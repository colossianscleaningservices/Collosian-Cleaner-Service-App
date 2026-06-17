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
    this.category,
    this.questionText,
    this.answerType,
    this.options,});

  Questions.fromJson(dynamic json) {
    id = json['id'];
    categoryId = json['category_id'];
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    questionText = json['question_text'];
    answerType = json['answer_type'];
    if (json['options'] != null) {
      options = [];
      json['options'].forEach((v) {
        options?.add(Options.fromJson(v));
      });
    }
  }
  num? id;
  num? categoryId;
  Category? category;
  String? questionText;
  String? answerType;
  List<Options>? options;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['category_id'] = categoryId;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    map['question_text'] = questionText;
    map['answer_type'] = answerType;
    if (options != null) {
      map['options'] = options?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Category {
  Category({
    this.id,
    this.name,
    this.slug,});

  Category.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }
  num? id;
  String? name;
  String? slug;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['slug'] = slug;
    return map;
  }

}

class Options {
  Options({
    this.text,
    this.label,
    this.id
  });

  Options.fromJson(dynamic json) {
    text = json['text'];
    label = json['label'];
    id = json['id'];
  }

  String? text;
  String? label;
  num? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['text'] = text;
    map['label'] = label;
    map['id'] = id;
    return map;
  }
}
