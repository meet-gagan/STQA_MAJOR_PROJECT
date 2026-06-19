import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService = QuizService();

  List<QuizModel> _quizzes = [];
  List<String> _categories = [];
  QuizModel? _currentQuiz;
  bool _isLoading = false;
  String? _error;

  List<QuizModel> get quizzes => _quizzes;
  List<String> get categories => _categories;
  QuizModel? get currentQuiz => _currentQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQuizzes({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _quizzes = await _quizService.getQuizzes(category: category);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _quizService.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchQuizById(String id) async {
    _isLoading = true;
    _currentQuiz = null;
    _error = null;
    notifyListeners();
    try {
      _currentQuiz = await _quizService.getQuizById(id);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<QuizModel>> fetchMyQuizzes() async {
    try {
      return await _quizService.getMyQuizzes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return [];
    }
  }

  Future<bool> createQuiz(Map<String, dynamic> quizData) async {
    try {
      await _quizService.createQuiz(quizData);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuiz(String id, Map<String, dynamic> quizData) async {
    try {
      await _quizService.updateQuiz(id, quizData);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteQuiz(String id) async {
    try {
      await _quizService.deleteQuiz(id);
      _quizzes.removeWhere((q) => q.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
