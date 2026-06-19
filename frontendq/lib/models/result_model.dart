class AnswerModel {
  final int questionIndex;
  final int selectedOption; // -1 = skipped
  final bool isCorrect;

  AnswerModel({
    required this.questionIndex,
    required this.selectedOption,
    required this.isCorrect,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      questionIndex: json['questionIndex'] ?? 0,
      selectedOption: json['selectedOption'] ?? -1,
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'selectedOption': selectedOption,
      'isCorrect': isCorrect,
    };
  }
}

class ResultModel {
  final String id;
  final String quizId;
  final String quizTitle;
  final String quizCategory;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final List<AnswerModel> answers;
  final DateTime completedAt;

  ResultModel({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.quizCategory,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.answers,
    required this.completedAt,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    final quiz = json['quiz'];
    String quizId = '';
    String quizTitle = '';
    String quizCategory = '';
    if (quiz is Map) {
      quizId = quiz['_id'] ?? '';
      quizTitle = quiz['title'] ?? '';
      quizCategory = quiz['category'] ?? '';
    } else if (quiz is String) {
      quizId = quiz;
    }

    return ResultModel(
      id: json['_id'] ?? '',
      quizId: quizId,
      quizTitle: quizTitle,
      quizCategory: quizCategory,
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      skippedAnswers: json['skippedAnswers'] ?? 0,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((a) => AnswerModel.fromJson(a))
              .toList() ??
          [],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : DateTime.now(),
    );
  }

  String get grade {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
}
