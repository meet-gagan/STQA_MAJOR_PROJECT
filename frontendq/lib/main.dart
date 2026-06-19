import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_list_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/teacher_home_screen.dart';
import 'screens/create_quiz_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/category_screen.dart';

void main() {
  runApp(const QuizMasterApp());
}

class QuizMasterApp extends StatelessWidget {
  const QuizMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'QuizMaster',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashScreen(),
          '/login': (ctx) => const LoginScreen(),
          '/register': (ctx) => const RegisterScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/categories': (ctx) => const CategoryScreen(),
          '/quiz-list': (ctx) => const QuizListScreen(),
          '/quiz': (ctx) => const QuizScreen(),
          '/result': (ctx) => const ResultScreen(),
          '/teacher-home': (ctx) => const TeacherHomeScreen(),
          '/create-quiz': (ctx) => const CreateQuizScreen(),
          '/profile': (ctx) => const ProfileScreen(),
        },
      ),
    );
  }
}
