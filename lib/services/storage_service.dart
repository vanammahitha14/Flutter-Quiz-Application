import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';

class StorageService {
  static const String _keyBestScores = 'quizmaster_best_scores';
  static const String _keyCustomQuestions = 'quizmaster_custom_questions';
  static const String _keyQuizHistory = 'quizmaster_quiz_history';

  final SharedPreferences? _prefsInstance;

  StorageService({SharedPreferences? prefs}) : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  /// Get the best score recorded for a specific category.
  Future<int> getBestScore(String categoryId) async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_keyBestScores);
    if (rawJson == null) return 0;
    try {
      final Map<String, dynamic> scores = jsonDecode(rawJson);
      return (scores[categoryId] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Saves the score if it exceeds the previously recorded best score for the category.
  /// Returns `true` if a new personal best was established.
  Future<bool> saveScoreIfBest(String categoryId, int newScore) async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_keyBestScores);
    Map<String, dynamic> scores = {};
    if (rawJson != null) {
      try {
        scores = jsonDecode(rawJson);
      } catch (_) {
        scores = {};
      }
    }

    final currentBest = (scores[categoryId] as int?) ?? 0;
    if (newScore > currentBest) {
      scores[categoryId] = newScore;
      await prefs.setString(_keyBestScores, jsonEncode(scores));
      return true;
    }
    return false;
  }

  /// Get all best scores map (categoryId -> score).
  Future<Map<String, int>> getAllBestScores() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_keyBestScores);
    if (rawJson == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((k, v) => MapEntry(k, v as int? ?? 0));
    } catch (_) {
      return {};
    }
  }

  /// Save a user-created question to local storage.
  Future<void> saveCustomQuestion(Question question) async {
    final prefs = await _getPrefs();
    final existing = await getCustomQuestions();
    // Add new question at top
    final updated = [question, ...existing];
    final encoded = updated.map((q) => q.toJson()).toList();
    await prefs.setString(_keyCustomQuestions, jsonEncode(encoded));
  }

  /// Retrieve all user-created questions from local storage.
  Future<List<Question>> getCustomQuestions() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_keyCustomQuestions);
    if (rawJson == null || rawJson.isEmpty) {
      // Provide some initial default custom questions if empty so user has something to play with immediately!
      return _initialDefaultCustomQuestions;
    }
    try {
      final List decoded = jsonDecode(rawJson) as List;
      return decoded
          .map((item) => Question.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _initialDefaultCustomQuestions;
    }
  }

  /// Save quiz completed result to history.
  Future<void> saveQuizResult(QuizResult result) async {
    final prefs = await _getPrefs();
    final existing = await getQuizHistory();
    final updated = [result, ...existing];
    // Keep max 20 history records
    final trimmed = updated.take(20).map((r) => r.toJson()).toList();
    await prefs.setString(_keyQuizHistory, jsonEncode(trimmed));
  }

  /// Get all completed quiz results.
  Future<List<QuizResult>> getQuizHistory() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_keyQuizHistory);
    if (rawJson == null) return [];
    try {
      final List decoded = jsonDecode(rawJson) as List;
      return decoded
          .map((item) => QuizResult.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Reset all stored data (useful for testing or full app reset).
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyBestScores);
    await prefs.remove(_keyCustomQuestions);
    await prefs.remove(_keyQuizHistory);
  }

  static const List<Question> _initialDefaultCustomQuestions = [
    Question(
      id: 'custom_seed_1',
      categoryId: 'custom',
      categoryName: 'Custom Questions',
      question: 'In Flutter, which widget is commonly used to listen to a ChangeNotifier?',
      options: ['Consumer', 'FutureBuilder', 'StreamBuilder', 'LayoutBuilder'],
      correctAnswerIndex: 0,
      difficulty: 'easy',
    ),
    Question(
      id: 'custom_seed_2',
      categoryId: 'custom',
      categoryName: 'Custom Questions',
      question: 'Which method on ChangeNotifier notifies all active listeners of a state change?',
      options: ['setState()', 'notifyListeners()', 'update()', 'refresh()'],
      correctAnswerIndex: 1,
      difficulty: 'easy',
    ),
  ];
}
