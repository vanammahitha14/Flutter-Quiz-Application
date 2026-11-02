class QuizResult {
  final String categoryId;
  final String categoryName;
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, int> selectedAnswers;
  final DateTime completedAt;

  const QuizResult({
    required this.categoryId,
    required this.categoryName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.selectedAnswers,
    required this.completedAt,
  });

  int get incorrectAnswers => totalQuestions - correctAnswers;

  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  bool get isPassed => percentage >= 50.0;

  String get feedbackMessage {
    if (percentage == 100) return 'Perfect Score! Outstanding work!';
    if (percentage >= 80) return 'Great job! You really know your stuff!';
    if (percentage >= 60) return 'Well done! A solid performance.';
    if (percentage >= 40) return 'Good effort! Keep practicing to improve.';
    return 'Don\'t give up! Review the answers and try again.';
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'selectedAnswers': selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['selectedAnswers'] as Map<String, dynamic>? ?? {};
    final answers = rawAnswers.map(
      (k, v) => MapEntry(int.tryParse(k) ?? 0, v as int? ?? 0),
    );

    return QuizResult(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      selectedAnswers: answers,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
