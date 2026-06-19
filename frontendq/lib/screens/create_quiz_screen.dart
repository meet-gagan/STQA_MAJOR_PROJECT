import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final QuizService _quizService = QuizService();
  int _timePerQuestion = 30;

  QuizModel? _editingQuiz;
  bool _isEdit = false;
  bool _submitting = false;

  final List<_QuestionData> _questions = [_QuestionData()];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is QuizModel && !_isEdit) {
      _isEdit = true;
      _editingQuiz = args;
      _titleCtrl.text = args.title;
      _categoryCtrl.text = args.category;
      _descCtrl.text = args.description;
      _timePerQuestion = args.timePerQuestion;
      _questions.clear();
      for (final q in args.questions) {
        _questions.add(_QuestionData(
          questionText: q.questionText,
          options: List<String>.from(q.options),
          correctOption: q.correctOption,
          explanation: q.explanation,
        ));
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question'), backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _submitting = true);

    final quizData = {
      'title': _titleCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'timePerQuestion': _timePerQuestion,
      'questions': _questions.map((q) => {
            'questionText': q.questionController.text.trim(),
            'options': q.optionControllers.map((c) => c.text.trim()).toList(),
            'correctOption': q.correctOption,
            'explanation': q.explanationController.text.trim(),
          }).toList(),
    };

    try {
      if (_isEdit && _editingQuiz != null) {
        await _quizService.updateQuiz(_editingQuiz!.id, quizData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz updated!'), backgroundColor: AppTheme.success),
          );
          Navigator.pop(context, true);
        }
      } else {
        await _quizService.createQuiz(quizData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz created!'), backgroundColor: AppTheme.success),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Quiz' : 'Create Quiz'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Quiz details card
            _SectionCard(
              title: 'Quiz Details',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Quiz Title'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'e.g. Science, Math, History',
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Time per question:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text('$_timePerQuestion s', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ],
                  ),
                  Slider(
                    value: _timePerQuestion.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 22,
                    label: '$_timePerQuestion s',
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() => _timePerQuestion = v.round()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Questions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Questions (${_questions.length})', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                GestureDetector(
                  onTap: () => setState(() => _questions.add(_QuestionData())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...List.generate(_questions.length, (i) {
              return _QuestionEditor(
                index: i,
                data: _questions[i],
                onRemove: _questions.length > 1
                    ? () => setState(() => _questions.removeAt(i))
                    : null,
              );
            }),

            const SizedBox(height: 30),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEdit ? 'Update Quiz' : 'Create Quiz'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _QuestionData {
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  final TextEditingController explanationController;
  int correctOption = 0;

  _QuestionData({
    String questionText = '',
    List<String>? options,
    int correctOption = 0,
    String explanation = '',
  })  : questionController = TextEditingController(text: questionText),
        optionControllers = List.generate(
          4,
          (i) => TextEditingController(text: options != null && i < options.length ? options[i] : ''),
        ),
        explanationController = TextEditingController(text: explanation) {
    this.correctOption = correctOption;
  }

  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) c.dispose();
    explanationController.dispose();
  }
}

class _QuestionEditor extends StatefulWidget {
  final int index;
  final _QuestionData data;
  final VoidCallback? onRemove;

  const _QuestionEditor({required this.index, required this.data, this.onRemove});

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Text('Question ${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary, fontSize: 14)),
                const Spacer(),
                if (widget.onRemove != null)
                  GestureDetector(
                    onTap: widget.onRemove,
                    child: const Icon(Icons.remove_circle_outline, color: AppTheme.error, size: 20),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: widget.data.questionController,
                  decoration: const InputDecoration(labelText: 'Question Text', hintText: 'Enter the question...'),
                  maxLines: 2,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Options (tap circle to set correct answer)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                ...List.generate(4, (i) {
                  final isCorrect = widget.data.correctOption == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => widget.data.correctOption = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCorrect ? AppTheme.success : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: isCorrect ? AppTheme.success : AppTheme.divider, width: 2),
                            ),
                            child: Center(
                              child: isCorrect
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : Text(String.fromCharCode(65 + i), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: widget.data.optionControllers[i],
                            decoration: InputDecoration(
                              labelText: 'Option ${String.fromCharCode(65 + i)}',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextFormField(
                  controller: widget.data.explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Explanation (optional)',
                    hintText: 'Brief explanation of the correct answer',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primary)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
