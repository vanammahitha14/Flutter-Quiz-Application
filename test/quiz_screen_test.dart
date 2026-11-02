import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_master/models/category.dart';
import 'package:quiz_master/models/question.dart';
import 'package:quiz_master/providers/quiz_provider.dart';
import 'package:quiz_master/screens/home_screen.dart';
import 'package:quiz_master/screens/quiz_screen.dart';
import 'package:quiz_master/screens/add_question_screen.dart';
import 'package:quiz_master/theme/app_theme.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Provider & Model Unit Tests', () {
    test('Calculates quiz scores and answers count accurately', () {
      final provider = QuizProvider();

      provider.selectCategory(Category.predefinedCategories.first);
      expect(provider.selectedCategory, isNotNull);
      expect(provider.correctAnswersCount, 0);

      // Select an answer
      provider.selectAnswer(1);
      expect(provider.hasAnsweredCurrentQuestion, true);
      expect(provider.selectedAnswers[0], 1);
    });

    test('Question model unescapes HTML entities properly', () {
      final unescaped = Question.unescapeHtml(
        'What is &quot;Dart&quot; &amp; Flutter&#039;s primary goal?',
      );
      expect(unescaped, "What is \"Dart\" & Flutter's primary goal?");
    });
  });

  group('Widget Tests', () {
    testWidgets('Home screen displays QuizMaster title and categories',
        (WidgetTester tester) async {
      final provider = QuizProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<QuizProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('QuizMaster'), findsOneWidget);
      expect(find.text('Science & Computers'), findsOneWidget);
      expect(find.text('General Knowledge'), findsOneWidget);
    });

    testWidgets('Home screen handles Loading state with CircularProgressIndicator',
        (WidgetTester tester) async {
      final provider = QuizProvider();
      provider.loadCategories(); // Triggers loading status

      await tester.pumpWidget(
        ChangeNotifierProvider<QuizProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      // Verify Loading State (GP3)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Quiz Categories...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('Empty question form displays all validation error messages',
        (WidgetTester tester) async {
      // Set larger test viewport so all fields and button are visible
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final provider = QuizProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<QuizProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddQuestionScreen(),
          ),
        ),
      );

      await tester.pump();

      final saveButton = find.text('Save Custom Question');
      expect(saveButton, findsOneWidget);
      await tester.ensureVisible(saveButton);
      await tester.pump();

      await tester.tap(saveButton);
      await tester.pump();

      // Form validation error messages must appear
      expect(find.text('Question text cannot be empty'), findsOneWidget);
      expect(find.text('Option A cannot be empty'), findsOneWidget);
      expect(find.text('Option B cannot be empty'), findsOneWidget);
      expect(find.text('Option C cannot be empty'), findsOneWidget);
      expect(find.text('Option D cannot be empty'), findsOneWidget);
    });

    testWidgets('Quiz screen displays question, 4 options, and allows selection',
        (WidgetTester tester) async {
      final provider = QuizProvider();
      provider.selectCategory(Category.predefinedCategories.first);
      provider.setQuestionsForTesting([
        const Question(
          id: 'test_1',
          categoryId: 'test_cat',
          categoryName: 'Test Category',
          question: 'In Flutter, which widget listens to a ChangeNotifier?',
          options: ['Consumer', 'FutureBuilder', 'StreamBuilder', 'LayoutBuilder'],
          correctAnswerIndex: 0,
        ),
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<QuizProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const QuizScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Question 1 of 1'), findsOneWidget);
      expect(find.text('Consumer'), findsOneWidget);
      expect(find.text('FutureBuilder'), findsOneWidget);

      await tester.tap(find.text('Consumer'));
      await tester.pump();

      expect(provider.currentSelectedAnswer, 0);
    });
  });
}
