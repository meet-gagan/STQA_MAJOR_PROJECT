import '../models/result_model.dart';
import 'api_service.dart';

class ResultService {
  Future<ResultModel> submitResult(
      String quizId, List<Map<String, dynamic>> answers) async {
    final response = await apiService.post('/results', {
      'quizId': quizId,
      'answers': answers,
    });
    return ResultModel.fromJson(response['result']);
  }

  Future<List<ResultModel>> getMyResults() async {
    final response = await apiService.get('/results/my');
    final list = response['results'] as List<dynamic>;
    return list.map((r) => ResultModel.fromJson(r)).toList();
  }

  Future<List<ResultModel>> getQuizResults(String quizId) async {
    final response = await apiService.get('/results/quiz/$quizId');
    final list = response['results'] as List<dynamic>;
    return list.map((r) => ResultModel.fromJson(r)).toList();
  }
}
