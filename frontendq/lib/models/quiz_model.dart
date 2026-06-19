class QuestionModel {
  final String questionText;
  final List<String> options;
  final int correctOption;
  final String explanation;

  QuestionModel({
    required this.questionText,
    required this.options,
    required this.correctOption,
    this.explanation = '',
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOption: json['correctOption'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOption': correctOption,
      'explanation': explanation,
    };
  }
}

class QuizModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<QuestionModel> questions;
  final int timePerQuestion;
  final bool isActive;
  final String createdByName;

  QuizModel({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    this.questions = const [],
    this.timePerQuestion = 30,
    this.isActive = true,
    this.createdByName = '',
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final createdBy = json['createdBy'];
    String creatorName = '';
    if (createdBy is Map) {
      creatorName = createdBy['name'] ?? '';
    }

    return QuizModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      timePerQuestion: json['timePerQuestion'] ?? 30,
      isActive: json['isActive'] ?? true,
      createdByName: creatorName,
    );
  }
}
