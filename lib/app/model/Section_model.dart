class SectionModel {
  SectionModel({
    required this.title,
    this.questions,
  });

  String? title;
  List<QuestionModel>? questions;
}

class QuestionModel {
  QuestionModel({
    required this.question,
    this.answers,
  });

  String? question;
  List<String>? answers;
}
