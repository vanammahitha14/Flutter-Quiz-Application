import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum CategoryListStatus { loading, loaded, empty, error }

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  QuizProvider({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  // Category List State (Home Screen)
  CategoryListStatus _categoryStatus = CategoryListStatus.loaded;
  CategoryListStatus get categoryStatus => _categoryStatus;

  List<Category> _categories = Category.predefinedCategories;
  List<Category> get categories => List.unmodifiable(_categories);

  String? _categoryError;
  String? get categoryError => _categoryError;

  // Selected Category & Details
  Category? _selectedCategory;
  Category? get selectedCategory => _selectedCategory;

  // Active Quiz State
  bool _isQuizLoading = false;
  bool get isQuizLoading => _isQuizLoading;

  String? _quizError;
  String? get quizError => _quizError;

  List<Question> _questions = [];
  List<Question> get questions => List.unmodifiable(_questions);

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  Question? get currentQuestion =>
      (_questions.isNotEmpty && _currentQuestionIndex < _questions.length)
          ? _questions[_currentQuestionIndex]
          : null;

  // Map of questionIndex -> selectedOptionIndex (0..3)
  final Map<int, int> _selectedAnswers = {};
  Map<int, int> get selectedAnswers => Map.unmodifiable(_selectedAnswers);

  int? get currentSelectedAnswer => _selectedAnswers[_currentQuestionIndex];

  // Best scores and persistent data
  Map<String, int> _bestScores = {};
  Map<String, int> get bestScores => Map.unmodifiable(_bestScores);

  List<Question> _customQuestions = [];
  List<Question> get customQuestions => List.unmodifiable(_customQuestions);

  QuizResult? _lastResult;
  QuizResult? get lastResult => _lastResult;

  bool _isNewBestScore = false;
  bool get isNewBestScore => _isNewBestScore;

  // Computed properties
  int get correctAnswersCount {
    int count = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctAnswerIndex) {
        count++;
      }
    }
    return count;
  }

  int get bestScoreForCurrentCategory {
    if (_selectedCategory == null) return 0;
    return _bestScores[_selectedCategory!.id] ?? 0;
  }

  int getBestScoreFor(String categoryId) {
    return _bestScores[categoryId] ?? 0;
  }

  bool get hasAnsweredCurrentQuestion =>
      _selectedAnswers.containsKey(_currentQuestionIndex);

  bool get isLastQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex == _questions.length - 1;

  double get quizProgress =>
      _questions.isEmpty ? 0 : (_currentQuestionIndex + 1) / _questions.length;

  /// Initialize provider by loading categories, custom questions, and best scores.
  Future<void> initialize() async {
    await Future.wait([
      loadCategories(),
      _loadCustomQuestions(),
      _loadBestScores(),
    ]);
  }

  /// Load categories into the Home Screen (supports Loading, Error, Empty, Data states).
  Future<void> loadCategories({bool forceEmpty = false, bool forceError = false}) async {
    _categoryStatus = CategoryListStatus.loading;
    _categoryError = null;
    notifyListeners();

    try {
      // Simulate brief network/storage transition
      await Future.delayed(const Duration(milliseconds: 300));

      if (forceError) {
        throw Exception('Failed to connect to category server. Please verify your connection.');
      }

      if (forceEmpty) {
        _categories = [];
        _categoryStatus = CategoryListStatus.empty;
      } else {
        _categories = Category.predefinedCategories;
        _categoryStatus = _categories.isEmpty
            ? CategoryListStatus.empty
            : CategoryListStatus.loaded;
      }
    } catch (e) {
      _categoryError = e.toString().replaceFirst('Exception: ', '');
      _categoryStatus = CategoryListStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Select a category to display in the Quiz Details screen.
  void selectCategory(Category category) {
    _selectedCategory = category;
    _questions = [];
    _selectedAnswers.clear();
    _currentQuestionIndex = 0;
    _quizError = null;
    notifyListeners();
  }

  /// Load questions and start the quiz for the chosen category.
  Future<bool> startQuizForCategory(Category category) async {
    _selectedCategory = category;
    _isQuizLoading = true;
    _quizError = null;
    _selectedAnswers.clear();
    _currentQuestionIndex = 0;
    _isNewBestScore = false;
    notifyListeners();

    try {
      if (category.id == 'custom') {
        final customs = await _storageService.getCustomQuestions();
        if (customs.isEmpty) {
          throw ApiException(
            'No custom questions found yet! Tap "Add Custom Question" to create your first quiz questions.',
          );
        }
        _questions = customs;
      } else {
        try {
          _questions = await _apiService.fetchQuestions(
            categoryId: category.id,
            amount: 10,
          );
        } catch (apiErr) {
          // If internet fails, we fallback to curated offline questions to avoid blocking the user,
          // but we also keep track of the error if strictly needed.
          final fallback = _apiService.getCuratedFallbackQuestions(category.id);
          if (fallback.isNotEmpty) {
            _questions = fallback;
          } else {
            rethrow;
          }
        }
      }

      _isQuizLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isQuizLoading = false;
      _quizError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Record user's chosen answer for the active question.
  void selectAnswer(int optionIndex) {
    _selectedAnswers[_currentQuestionIndex] = optionIndex;
    notifyListeners();
  }

  /// Navigate to next question.
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Navigate to previous question.
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Finalize the quiz, calculate score, and persist results & best scores to storage.
  Future<QuizResult> finishQuiz() async {
    final correct = correctAnswersCount;
    final total = _questions.length;
    final categoryId = _selectedCategory?.id ?? 'general';
    final categoryName = _selectedCategory?.name ?? 'General';

    // Save if new personal best
    final isNewBest = await _storageService.saveScoreIfBest(categoryId, correct);
    _isNewBestScore = isNewBest;

    // Refresh best scores
    await _loadBestScores();

    final result = QuizResult(
      categoryId: categoryId,
      categoryName: categoryName,
      totalQuestions: total,
      correctAnswers: correct,
      selectedAnswers: Map.from(_selectedAnswers),
      completedAt: DateTime.now(),
    );

    _lastResult = result;
    await _storageService.saveQuizResult(result);
    notifyListeners();
    return result;
  }

  /// Restart the current active quiz with same questions but cleared answers.
  void restartCurrentQuiz() {
    _selectedAnswers.clear();
    _currentQuestionIndex = 0;
    _isNewBestScore = false;
    notifyListeners();
  }

  /// Add and save a new user-created question.
  Future<void> addCustomQuestion(Question question) async {
    await _storageService.saveCustomQuestion(question);
    await _loadCustomQuestions();
    notifyListeners();
  }

  Future<void> _loadCustomQuestions() async {
    _customQuestions = await _storageService.getCustomQuestions();
  }

  Future<void> _loadBestScores() async {
    _bestScores = await _storageService.getAllBestScores();
  }

  void clearQuizError() {
    _quizError = null;
    notifyListeners();
  }

  /// Helper for widget testing to synchronously inject test questions
  void setQuestionsForTesting(List<Question> testQuestions) {
    _questions = List.from(testQuestions);
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    _isQuizLoading = false;
    notifyListeners();
  }
}
