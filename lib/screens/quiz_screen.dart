import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_option.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isSubmitting = false;

  Future<bool> _showQuitDialog() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress for this quiz will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  void _handleSubmit() async {
    if (_isSubmitting) return; // Prevent repeated fast taps
    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<QuizProvider>();
    final result = await provider.finishQuiz();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final currentQuestion = provider.currentQuestion;
        final totalQuestions = provider.questions.length;
        final currentIndex = provider.currentQuestionIndex;
        final selectedOption = provider.currentSelectedAnswer;
        final isLast = provider.isLastQuestion;

        if (currentQuestion == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No questions available.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldLeave = await _showQuitDialog();
            if (shouldLeave && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                provider.selectedCategory?.name ?? 'Quiz',
                style: const TextStyle(fontSize: 18),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(6),
                child: LinearProgressIndicator(
                  value: provider.quizProgress,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Top Progress & Indicator Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Question ${currentIndex + 1} of $totalQuestions',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.selectedAnswers.length}/$totalQuestions Answered',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Scrollable Question Card and Options
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppTheme.borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                currentQuestion.question,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Answer Options List
                            ...currentQuestion.options.asMap().entries.map((entry) {
                              final optionIndex = entry.key;
                              final optionText = entry.value;
                              return AnswerOption(
                                index: optionIndex,
                                text: optionText,
                                isSelected: selectedOption == optionIndex,
                                onTap: () {
                                  provider.selectAnswer(optionIndex);
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bottom Navigation Bar
                    Row(
                      children: [
                        if (currentIndex > 0)
                          Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                provider.previousQuestion();
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                            ),
                          ),
                        if (currentIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: selectedOption == null
                                ? null
                                : () {
                                    if (isLast) {
                                      _handleSubmit();
                                    } else {
                                      provider.nextQuestion();
                                    }
                                  },
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(isLast
                                    ? Icons.check_circle
                                    : Icons.arrow_forward),
                            label: Text(
                              isLast ? 'Submit Quiz' : 'Next Question',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
