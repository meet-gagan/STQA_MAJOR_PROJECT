import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../models/result_model.dart';
import '../services/result_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ResultService _resultService = ResultService();
  List<ResultModel> _myResults = [];
  bool _resultsLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await Future.wait([
      quizProvider.fetchCategories(),
      _fetchResults(),
    ]);
  }

  Future<void> _fetchResults() async {
    try {
      final results = await _resultService.getMyResults();
      if (mounted) {
        setState(() {
          _myResults = results.take(3).toList();
          _resultsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _resultsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final quizProvider = Provider.of<QuizProvider>(context);
    final user = authProvider.user!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user.name.split(' ').first}! 👋',
                                style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ready to test your knowledge?',
                                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/profile'),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await authProvider.logout();
                                  if (mounted) Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.quiz_outlined,
                            label: 'Quizzes Taken',
                            value: '${_myResults.isNotEmpty ? _myResults.length : 0}+',
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.category_outlined,
                            label: 'Categories',
                            value: '${quizProvider.categories.length}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Browse Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/categories'),
                        child: const Text('See All', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                quizProvider.categories.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Loading categories...', style: TextStyle(color: AppTheme.textSecondary)),
                      )
                    : SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: quizProvider.categories.length,
                          itemBuilder: (ctx, i) {
                            final category = quizProvider.categories[i];
                            final color = AppTheme.categoryColors[i % AppTheme.categoryColors.length];
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/quiz-list', arguments: category),
                              child: Container(
                                width: 130,
                                margin: const EdgeInsets.only(right: 14),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_getCategoryIcon(category), color: Colors.white, size: 30),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        category,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 28),

                // Recent Results
                if (_myResults.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Recent Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ),
                  const SizedBox(height: 12),
                  ...(_myResults.map((result) => _ResultTile(result: result))),
                ] else if (!_resultsLoading) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.quiz_outlined, size: 64, color: AppTheme.primary.withOpacity(0.3)),
                          const SizedBox(height: 14),
                          const Text('No quizzes taken yet!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          const Text('Pick a category and start your first quiz', style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'general knowledge': return Icons.lightbulb_outline;
      case 'science': return Icons.science_outlined;
      case 'mathematics': return Icons.calculate_outlined;
      case 'computer science': return Icons.computer_outlined;
      case 'history': return Icons.history_edu_outlined;
      case 'geography': return Icons.public_outlined;
      default: return Icons.quiz_outlined;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final ResultModel result;
  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final isPass = result.score >= 50;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isPass ? AppTheme.success : AppTheme.error).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                result.grade,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isPass ? AppTheme.success : AppTheme.error,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.quizTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                Text(result.quizCategory, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.score}%',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: isPass ? AppTheme.success : AppTheme.error),
              ),
              Text('${result.correctAnswers}/${result.totalQuestions}', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
