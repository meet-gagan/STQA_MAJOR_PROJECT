import 'package:flutter/material.dart';
import '../models/result_model.dart';
import '../models/quiz_model.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ResultModel result = args['result'];
    final QuizModel quiz = args['quiz'];

    final isPass = result.score >= 50;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPass
                      ? [const Color(0xFF059669), const Color(0xFF047857)]
                      : [AppTheme.error, const Color(0xFFB91C1C)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isPass ? AppTheme.success : AppTheme.error).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isPass ? '🎉 Congratulations!' : '😔 Better Luck Next Time',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: result.score / 100,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 10,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${result.score}%',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          Text(
                            result.grade,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(quiz.title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ScoreStat(label: 'Correct', value: '${result.correctAnswers}', icon: Icons.check_circle_outline, color: Colors.white),
                      _ScoreStat(label: 'Wrong', value: '${result.wrongAnswers}', icon: Icons.cancel_outlined, color: Colors.white70),
                      _ScoreStat(label: 'Skipped', value: '${result.skippedAnswers}', icon: Icons.access_time_outlined, color: Colors.white60),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question review
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Answer Review', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 12),

            ...List.generate(quiz.questions.length, (i) {
              final question = quiz.questions[i];
              final answer = result.answers.length > i ? result.answers[i] : null;
              final isCorrect = answer?.isCorrect ?? false;
              final selectedOpt = answer?.selectedOption ?? -1;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isCorrect ? AppTheme.success : AppTheme.error).withOpacity(0.3),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isCorrect ? AppTheme.success : AppTheme.error).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Q${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isCorrect ? AppTheme.success : AppTheme.error)),
                        ),
                        const Spacer(),
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? AppTheme.success : AppTheme.error,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(question.questionText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    if (selectedOpt >= 0 && !isCorrect)
                      _AnswerRow(label: 'Your Answer', text: question.options[selectedOpt], color: AppTheme.error),
                    if (selectedOpt == -1)
                      const _AnswerRow(label: 'Your Answer', text: 'Skipped (Time Out)', color: AppTheme.error),
                    _AnswerRow(label: 'Correct', text: question.options[question.correctOption], color: AppTheme.success),
                    if (question.explanation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('💡 ${question.explanation}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/quiz', arguments: quiz.id),
                    icon: const Icon(Icons.replay, color: Colors.white),
                    label: const Text('Retry Quiz'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _ScoreStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  const _AnswerRow({required this.label, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color))),
        ],
      ),
    );
  }
}
