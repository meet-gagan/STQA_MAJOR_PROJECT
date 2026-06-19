import 'package:flutter_test/flutter_test.dart';
import 'package:quizapp/main.dart';

void main() {
  testWidgets('QuizMaster smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizMasterApp());
  });
}
