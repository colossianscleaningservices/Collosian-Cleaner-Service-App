class SaveCleanerAssessmentRequest {
  SaveCleanerAssessmentRequest({
      this.answers,});

  SaveCleanerAssessmentRequest.fromJson(dynamic json) {
    if (json['answers'] != null) {
      answers = [];
      json['answers'].forEach((v) {
        answers?.add(Answers.fromJson(v));
      });
    }
  }
  List<Answers>? answers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (answers != null) {
      map['answers'] = answers?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Answers {
  Answers({
      this.categoryId, 
      this.questionId, 
      this.option,});

  Answers.fromJson(dynamic json) {
    categoryId = json['category_id'];
    questionId = json['question_id'];
    if (json['option'] != null) {
      option = [];
      json['option'].forEach((v) {
        option?.add(v);
      });
    }
  }
  num? categoryId;
  num? questionId;
  List<num>? option;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['category_id'] = categoryId;
    map['question_id'] = questionId;
    map['option'] = option;
    return map;
  }

}