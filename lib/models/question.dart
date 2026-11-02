class Question {
  final String id;
  final String categoryId;
  final String categoryName;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String difficulty;

  const Question({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.difficulty = 'medium',
  });

  String get correctAnswer =>
      (correctAnswerIndex >= 0 && correctAnswerIndex < options.length)
          ? options[correctAnswerIndex]
          : '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'difficulty': difficulty,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? 'custom',
      categoryName: json['categoryName'] as String? ?? 'Custom',
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      difficulty: json['difficulty'] as String? ?? 'medium',
    );
  }

  /// Parses OpenTDB API response format:
  /// {
  ///   "category": "Science: Computers",
  ///   "type": "multiple",
  ///   "difficulty": "medium",
  ///   "question": "What does CPU stand for?",
  ///   "correct_answer": "Central Processing Unit",
  ///   "incorrect_answers": ["Central Process Unit", "Computer Personal Unit", "Central Processor Unit"]
  /// }
  factory Question.fromApiJson(Map<String, dynamic> json, String categoryId, {int? seedIndex}) {
    final rawQuestion = unescapeHtml(json['question'] as String? ?? '');
    final rawCorrect = unescapeHtml(json['correct_answer'] as String? ?? '');
    final rawIncorrect = (json['incorrect_answers'] as List? ?? [])
        .map((e) => unescapeHtml(e.toString()))
        .toList();

    // Combine and shuffle options deterministically or pseudo-randomly
    final allOptions = <String>[...rawIncorrect, rawCorrect];
    allOptions.shuffle();

    final correctIndex = allOptions.indexOf(rawCorrect);

    return Question(
      id: 'api_${DateTime.now().microsecondsSinceEpoch}_${seedIndex ?? 0}',
      categoryId: categoryId,
      categoryName: unescapeHtml(json['category'] as String? ?? 'General'),
      question: rawQuestion,
      options: allOptions,
      correctAnswerIndex: correctIndex >= 0 ? correctIndex : 0,
      difficulty: json['difficulty'] as String? ?? 'medium',
    );
  }

  static String unescapeHtml(String input) {
    if (input.isEmpty) return '';
    return input
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&aacute;', 'á')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&ntilde;', 'ñ')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&auml;', 'ä')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&deg;', '°')
        .replaceAll('&micro;', 'µ')
        .replaceAll('&plusmn;', '±')
        .replaceAll('&sup2;', '²')
        .replaceAll('&sup3;', '³')
        .replaceAll('&frac12;', '½')
        .replaceAll('&lrm;', '')
        .replaceAll('&rlm;', '');
  }
}
