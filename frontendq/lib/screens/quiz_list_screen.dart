import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_model.dart';
import '../theme/app_theme.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  String? _category;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _category = ModalRoute.of(context)?.settings.arguments as String?;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<QuizProvider>(context, listen: false).fetchQuizzes(category: _category);
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_category ?? 'All Quizzes'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: quizProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizProvider.quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 80, color: AppTheme.primary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('No quizzes available', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: quizProvider.quizzes.length,
                  itemBuilder: (ctx, i) {
                    return _QuizCard(quiz: quizProvider.quizzes[i]);
                  },
                ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[quiz.title.length % AppTheme.categoryColors.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/quiz', arguments: quiz.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(quiz.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                      ),
                      const Spacer(),
                      Icon(Icons.timer_outlined, size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text('${quiz.timePerQuestion}s/Q', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(quiz.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  if (quiz.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(quiz.description, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text('By ${quiz.createdByName}', style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Start Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
