import '../models/quiz_model.dart';
import 'api_service.dart';

class QuizService {
  Future<List<QuizModel>> getQuizzes({String? category}) async {
    String endpoint = '/quizzes';
    if (category != null) endpoint += '?category=${Uri.encodeComponent(category)}';
    final response = await apiService.get(endpoint);
    final list = response['quizzes'] as List<dynamic>;
    return list.map((q) => QuizModel.fromJson(q)).toList();
  }

  Future<List<String>> getCategories() async {
    final response = await apiService.get('/quizzes/categories');
    return List<String>.from(response['categories']);
  }

  Future<QuizModel> getQuizById(String id) async {
    final response = await apiService.get('/quizzes/$id');
    return QuizModel.fromJson(response['quiz']);
  }

  Future<List<QuizModel>> getMyQuizzes() async {
    final response = await apiService.get('/quizzes/teacher/mine');
    final list = response['quizzes'] as List<dynamic>;
    return list.map((q) => QuizModel.fromJson(q)).toList();
  }

  Future<QuizModel> createQuiz(Map<String, dynamic> quizData) async {
    final response = await apiService.post('/quizzes', quizData);
    return QuizModel.fromJson(response['quiz']);
  }

  Future<QuizModel> updateQuiz(String id, Map<String, dynamic> quizData) async {
    final response = await apiService.put('/quizzes/$id', quizData);
    return QuizModel.fromJson(response['quiz']);
  }

  Future<void> deleteQuiz(String id) async {
    await apiService.delete('/quizzes/$id');
  }
}
