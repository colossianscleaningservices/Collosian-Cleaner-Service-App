class SaveCleanerAssessmentResponse {
  SaveCleanerAssessmentResponse({
      this.data, 
      this.version, 
      this.code, 
      this.message,});

  SaveCleanerAssessmentResponse.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    version = json['version'];
    code = json['code'];
    message = json['message'];
  }
  Data? data;
  String? version;
  num? code;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['version'] = version;
    map['code'] = code;
    map['message'] = message;
    return map;
  }

}

class Data {
  Data({
      this.answerIds, 
      this.questionResults, 
      this.overall,});

  Data.fromJson(dynamic json) {
    answerIds = json['answer_ids'] != null ? json['answer_ids'].cast<num>() : [];
    if (json['question_results'] != null) {
      questionResults = [];
      json['question_results'].forEach((v) {
        questionResults?.add(QuestionResults.fromJson(v));
      });
    }
    overall = json['overall'] != null ? Overall.fromJson(json['overall']) : null;
  }
  List<num>? answerIds;
  List<QuestionResults>? questionResults;
  Overall? overall;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['answer_ids'] = answerIds;
    if (questionResults != null) {
      map['question_results'] = questionResults?.map((v) => v.toJson()).toList();
    }
    if (overall != null) {
      map['overall'] = overall?.toJson();
    }
    return map;
  }

}

class Overall {
  Overall({
      this.totalQuestions, 
      this.correctAnswers, 
      this.incorrectAnswers, 
      this.percentage, 
      this.status,});

  Overall.fromJson(dynamic json) {
    totalQuestions = json['total_questions'];
    correctAnswers = json['correct_answers'];
    incorrectAnswers = json['incorrect_answers'];
    percentage = json['percentage'];
    status = json['status'];
  }
  num? totalQuestions;
  num? correctAnswers;
  num? incorrectAnswers;
  num? percentage;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_questions'] = totalQuestions;
    map['correct_answers'] = correctAnswers;
    map['incorrect_answers'] = incorrectAnswers;
    map['percentage'] = percentage;
    map['status'] = status;
    return map;
  }

}

class QuestionResults {
  QuestionResults({
      this.answerId, 
      this.questionId, 
      this.categoryId, 
      this.selectedOption, 
      this.isCorrect,});

  QuestionResults.fromJson(dynamic json) {
    answerId = json['answer_id'];
    questionId = json['question_id'];
    categoryId = json['category_id'];
    selectedOption = json['selected_option'];
    isCorrect = json['is_correct'];
  }
  num? answerId;
  num? questionId;
  num? categoryId;
  String? selectedOption;
  bool? isCorrect;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['answer_id'] = answerId;
    map['question_id'] = questionId;
    map['category_id'] = categoryId;
    map['selected_option'] = selectedOption;
    map['is_correct'] = isCorrect;
    return map;
  }

}