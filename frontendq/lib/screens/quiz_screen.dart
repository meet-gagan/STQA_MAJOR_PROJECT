import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_model.dart';
import '../services/result_service.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  String? _quizId;
  QuizModel? _quiz;
  bool _loading = true;

  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _timeLeft = 30;
  Timer? _timer;
  bool _submitting = false;

  final List<Map<String, dynamic>> _answers = [];
  late AnimationController _feedbackController;
  late Animation<Color?> _feedbackColor;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _feedbackColor = ColorTween(begin: Colors.transparent, end: Colors.transparent)
        .animate(_feedbackController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_quizId == null) {
      _quizId = ModalRoute.of(context)?.settings.arguments as String?;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadQuiz();
      });
    }
  }

  Future<void> _loadQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.fetchQuizById(_quizId!);
    if (!mounted) return;
    
    if (quizProvider.currentQuiz != null) {
      setState(() {
        _quiz = quizProvider.currentQuiz;
        _timeLeft = _quiz!.timePerQuestion;
        _loading = false;
      });
      _startTimer();
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load: ${quizProvider.error ?? 'Unknown error'}'), backgroundColor: AppTheme.error),
      );
      Navigator.pop(context);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_answered) return;
      if (_timeLeft <= 1) {
        t.cancel();
        _handleTimeout();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleTimeout() {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = -1;
    });
    _answers.add({'questionIndex': _currentIndex, 'selectedOption': -1});
    _showFeedback(false);
    Future.delayed(const Duration(milliseconds: 1200), _nextQuestion);
  }

  void _selectOption(int index) {
    if (_answered) return;
    _timer?.cancel();
    final isCorrect = index == _quiz!.questions[_currentIndex].correctOption;

    setState(() {
      _selectedOption = index;
      _answered = true;
    });
    _answers.add({'questionIndex': _currentIndex, 'selectedOption': index});
    _showFeedback(isCorrect);

    Future.delayed(const Duration(milliseconds: 1200), _nextQuestion);
  }

  void _showFeedback(bool correct) {
    _feedbackColor = ColorTween(
      begin: (correct ? AppTheme.success : AppTheme.error).withOpacity(0.12),
      end: Colors.transparent,
    ).animate(_feedbackController);
    _feedbackController.forward(from: 0);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
        _timeLeft = _quiz!.timePerQuestion;
      });
      _startTimer();
    } else {
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();
    setState(() => _submitting = true);
    try {
      final resultService = ResultService();
      final result = await resultService.submitResult(_quizId!, _answers);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/result', arguments: {
        'result': result,
        'quiz': _quiz,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  Color _optionColor(int index) {
    if (!_answered) return Colors.white;
    final correctIndex = _quiz!.questions[_currentIndex].correctOption;
    if (index == correctIndex) return AppTheme.success.withOpacity(0.15);
    if (index == _selectedOption && _selectedOption != correctIndex) {
      return AppTheme.error.withOpacity(0.15);
    }
    return Colors.white;
  }

  Color _optionBorderColor(int index) {
    if (!_answered) {
      return _selectedOption == index ? AppTheme.primary : AppTheme.divider;
    }
    final correctIndex = _quiz!.questions[_currentIndex].correctOption;
    if (index == correctIndex) return AppTheme.success;
    if (index == _selectedOption && _selectedOption != correctIndex) return AppTheme.error;
    return AppTheme.divider;
  }

  IconData? _optionIcon(int index) {
    if (!_answered) return null;
    final correctIndex = _quiz!.questions[_currentIndex].correctOption;
    if (index == correctIndex) return Icons.check_circle;
    if (index == _selectedOption && _selectedOption != correctIndex) return Icons.cancel;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_quiz == null) {
      return const Scaffold(body: Center(child: Text('Quiz not found')));
    }
    if (_submitting) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Submitting your quiz...'),
            ],
          ),
        ),
      );
    }

    final question = _quiz!.questions[_currentIndex];
    final total = _quiz!.questions.length;
    final timerProgress = _timeLeft / _quiz!.timePerQuestion;
    final timerColor = _timeLeft > 10 ? AppTheme.success : (_timeLeft > 5 ? AppTheme.warning : AppTheme.error);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_quiz!.title, overflow: TextOverflow.ellipsis),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showExitDialog(),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _feedbackController,
        builder: (context, child) {
          return Container(
            color: _feedbackColor.value,
            child: child,
          );
        },
        child: Column(
          children: [
            // Progress section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of $total',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      // Timer
                      Row(
                        children: [
                          Icon(Icons.timer, size: 16, color: timerColor),
                          const SizedBox(width: 4),
                          Text(
                            '$_timeLeft s',
                            style: TextStyle(fontWeight: FontWeight.w700, color: timerColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(4)),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 8,
                        width: (MediaQuery.of(context).size.width - 40) * ((_currentIndex + 1) / total),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Timer progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: timerProgress,
                      backgroundColor: timerColor.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),

            // Question + options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Q${_currentIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.questionText,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Answer options
                    ...List.generate(question.options.length, (i) {
                      final icon = _optionIcon(i);
                      return GestureDetector(
                        onTap: () => _selectOption(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: _optionColor(i),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _optionBorderColor(i), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _optionBorderColor(i).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _optionBorderColor(i), width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + i), // A, B, C, D
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _optionBorderColor(i)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  question.options[i],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _answered && i == _quiz!.questions[_currentIndex].correctOption
                                        ? AppTheme.success
                                        : (_answered && i == _selectedOption && i != _quiz!.questions[_currentIndex].correctOption
                                            ? AppTheme.error
                                            : AppTheme.textPrimary),
                                  ),
                                ),
                              ),
                              if (icon != null) ...[
                                const SizedBox(width: 8),
                                Icon(icon, color: _optionBorderColor(i), size: 22),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                    // Feedback + explanation
                    if (_answered) ...[
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (_selectedOption == -1 || _selectedOption != _quiz!.questions[_currentIndex].correctOption
                                  ? AppTheme.error
                                  : AppTheme.success)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (_selectedOption == -1 || _selectedOption != _quiz!.questions[_currentIndex].correctOption
                                    ? AppTheme.error
                                    : AppTheme.success)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedOption == _quiz!.questions[_currentIndex].correctOption
                                  ? Icons.check_circle_outline
                                  : (_selectedOption == -1 ? Icons.access_time_outlined : Icons.cancel_outlined),
                              color: _selectedOption == _quiz!.questions[_currentIndex].correctOption
                                  ? AppTheme.success
                                  : AppTheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedOption == _quiz!.questions[_currentIndex].correctOption
                                    ? '🎉 Correct! Well done!'
                                    : (_selectedOption == -1
                                        ? '⏱️ Time\'s up! Moving to next question...'
                                        : '❌ Incorrect! The answer was: ${question.options[question.correctOption]}'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedOption == _quiz!.questions[_currentIndex].correctOption ? AppTheme.success : AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (question.explanation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '💡 ${question.explanation}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _currentIndex < _quiz!.questions.length - 1 ? 'Next Question →' : 'Submit Quiz',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continue')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
