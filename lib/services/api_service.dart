import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches multiple-choice questions from Open Trivia DB API.
  /// Throws [ApiException] on network or HTTP error so the UI can show Error State.
  Future<List<Question>> fetchQuestions({
    required String categoryId,
    int amount = 10,
  }) async {
    // If it's the custom category, it's served by local storage
    if (categoryId == 'custom') {
      return [];
    }

    final uri = Uri.parse(
      'https://opentdb.com/api.php?amount=$amount&category=$categoryId&type=multiple',
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final int responseCode = data['response_code'] as int? ?? -1;

        if (responseCode == 0) {
          final List results = data['results'] as List? ?? [];
          if (results.isEmpty) {
            throw ApiException('No questions available for this category.');
          }

          return results.asMap().entries.map((entry) {
            return Question.fromApiJson(
              entry.value as Map<String, dynamic>,
              categoryId,
              seedIndex: entry.key,
            );
          }).toList();
        } else if (responseCode == 1) {
          throw ApiException('No questions found for the selected category.');
        } else if (responseCode == 5) {
          // Rate limit exceeded (OpenTDB allows 1 request / 5s)
          // Fall back to curated offline questions for a seamless experience
          return getCuratedFallbackQuestions(categoryId);
        } else {
          throw ApiException('Trivia service returned code: $responseCode');
        }
      } else {
        throw ApiException(
          'Server returned an error (${response.statusCode}). Please try again.',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException(
        'Unable to connect to the Internet. Please check your network connection.',
      );
    } on TimeoutException {
      throw ApiException(
        'Network request timed out. Please check your connection and retry.',
      );
    } on FormatException {
      throw ApiException('Received malformed response from quiz server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  /// High quality offline/fallback questions when API is rate-limited or offline.
  List<Question> getCuratedFallbackQuestions(String categoryId) {
    switch (categoryId) {
      case '18': // Science & Computers
        return const [
          Question(
            id: 'fb_comp_1',
            categoryId: '18',
            categoryName: 'Science & Computers',
            question: 'What does CPU stand for in computer hardware?',
            options: [
              'Central Processing Unit',
              'Computer Personal Unit',
              'Central Processor Utility',
              'Core Processing Unit',
            ],
            correctAnswerIndex: 0,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_comp_2',
            categoryId: '18',
            categoryName: 'Science & Computers',
            question: 'Which programming language is predominantly used to build Flutter apps?',
            options: ['Java', 'Dart', 'Kotlin', 'Swift'],
            correctAnswerIndex: 1,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_comp_3',
            categoryId: '18',
            categoryName: 'Science & Computers',
            question: 'What is the primary state management library recommended in the project specification?',
            options: ['Redux', 'Bloc', 'Provider', 'MobX'],
            correctAnswerIndex: 2,
            difficulty: 'medium',
          ),
          Question(
            id: 'fb_comp_4',
            categoryId: '18',
            categoryName: 'Science & Computers',
            question: 'What protocol does the web use to securely transfer hypermedia documents?',
            options: ['FTP', 'SSH', 'HTTPS', 'SMTP'],
            correctAnswerIndex: 2,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_comp_5',
            categoryId: '18',
            categoryName: 'Science & Computers',
            question: 'Which company originally created the Dart programming language and Flutter?',
            options: ['Apple', 'Microsoft', 'Google', 'Meta'],
            correctAnswerIndex: 2,
            difficulty: 'easy',
          ),
        ];

      case '21': // Sports
        return const [
          Question(
            id: 'fb_sport_1',
            categoryId: '21',
            categoryName: 'Sports',
            question: 'How many players are on the field for one team in a standard soccer match?',
            options: ['9', '10', '11', '12'],
            correctAnswerIndex: 2,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_sport_2',
            categoryId: '21',
            categoryName: 'Sports',
            question: 'In which sport would you perform a slam dunk?',
            options: ['Tennis', 'Basketball', 'Cricket', 'Baseball'],
            correctAnswerIndex: 1,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_sport_3',
            categoryId: '21',
            categoryName: 'Sports',
            question: 'How long is an official Olympic swimming pool in meters?',
            options: ['25 meters', '50 meters', '75 meters', '100 meters'],
            correctAnswerIndex: 1,
            difficulty: 'medium',
          ),
          Question(
            id: 'fb_sport_4',
            categoryId: '21',
            categoryName: 'Sports',
            question: 'Which country won the FIFA World Cup in 2022?',
            options: ['France', 'Argentina', 'Brazil', 'Croatia'],
            correctAnswerIndex: 1,
            difficulty: 'medium',
          ),
          Question(
            id: 'fb_sport_5',
            categoryId: '21',
            categoryName: 'Sports',
            question: 'What is the term for three consecutive strikes in bowling?',
            options: ['Eagle', 'Hat-trick', 'Turkey', 'Triple'],
            correctAnswerIndex: 2,
            difficulty: 'medium',
          ),
        ];

      case '23': // History
        return const [
          Question(
            id: 'fb_hist_1',
            categoryId: '23',
            categoryName: 'History',
            question: 'In which year did World War II officially end?',
            options: ['1941', '1943', '1945', '1950'],
            correctAnswerIndex: 2,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_hist_2',
            categoryId: '23',
            categoryName: 'History',
            question: 'Who was the first President of the United States?',
            options: [
              'Thomas Jefferson',
              'George Washington',
              'Abraham Lincoln',
              'John Adams',
            ],
            correctAnswerIndex: 1,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_hist_3',
            categoryId: '23',
            categoryName: 'History',
            question: 'The ancient city of Rome was founded on the banks of which river?',
            options: ['Danube', 'Tiber', 'Po', 'Rhine'],
            correctAnswerIndex: 1,
            difficulty: 'medium',
          ),
          Question(
            id: 'fb_hist_4',
            categoryId: '23',
            categoryName: 'History',
            question: 'Which civilization built the Machu Picchu citadel in Peru?',
            options: ['Aztec', 'Maya', 'Inca', 'Olmec'],
            correctAnswerIndex: 2,
            difficulty: 'medium',
          ),
          Question(
            id: 'fb_hist_5',
            categoryId: '23',
            categoryName: 'History',
            question: 'In which year did man first land on the Moon?',
            options: ['1965', '1969', '1971', '1975'],
            correctAnswerIndex: 1,
            difficulty: 'easy',
          ),
        ];

      case '22': // Geography
        return const [
          Question(
            id: 'fb_geo_1',
            categoryId: '22',
            categoryName: 'Geography',
            question: 'What is the largest ocean on Earth?',
            options: [
              'Atlantic Ocean',
              'Indian Ocean',
              'Arctic Ocean',
              'Pacific Ocean',
            ],
            correctAnswerIndex: 3,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_geo_2',
            categoryId: '22',
            categoryName: 'Geography',
            question: 'What is the capital city of Australia?',
            options: ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'],
            correctAnswerIndex: 2,
            difficulty: 'medium',
          ),
          Question(
            id: 'fb_geo_3',
            categoryId: '22',
            categoryName: 'Geography',
            question: 'Which is the longest river in the world?',
            options: ['Amazon River', 'Nile River', 'Yangtze', 'Mississippi'],
            correctAnswerIndex: 1,
            difficulty: 'medium',
          ),
          Question(
            id: 'fb_geo_4',
            categoryId: '22',
            categoryName: 'Geography',
            question: 'Mount Everest is situated along the border of China and which other nation?',
            options: ['India', 'Bhutan', 'Nepal', 'Pakistan'],
            correctAnswerIndex: 2,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_geo_5',
            categoryId: '22',
            categoryName: 'Geography',
            question: 'Which country has the most natural lakes in the world?',
            options: ['Russia', 'Canada', 'United States', 'Sweden'],
            correctAnswerIndex: 1,
            difficulty: 'hard',
          ),
        ];

      case '9': // General Knowledge
      default:
        return const [
          Question(
            id: 'fb_gen_1',
            categoryId: '9',
            categoryName: 'General Knowledge',
            question: 'What is the chemical symbol for Gold on the periodic table?',
            options: ['Ag', 'Au', 'Fe', 'Pb'],
            correctAnswerIndex: 1,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_gen_2',
            categoryId: '9',
            categoryName: 'General Knowledge',
            question: 'Which planet is popularly known as the Red Planet?',
            options: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
            correctAnswerIndex: 1,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_gen_3',
            categoryId: '9',
            categoryName: 'General Knowledge',
            question: 'How many days are there in a standard leap year?',
            options: ['364', '365', '366', '367'],
            correctAnswerIndex: 2,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_gen_4',
            categoryId: '9',
            categoryName: 'General Knowledge',
            question: 'Who painted the famous Mona Lisa portrait?',
            options: [
              'Vincent van Gogh',
              'Pablo Picasso',
              'Leonardo da Vinci',
              'Claude Monet',
            ],
            correctAnswerIndex: 2,
            difficulty: 'easy',
          ),
          Question(
            id: 'fb_gen_5',
            categoryId: '9',
            categoryName: 'General Knowledge',
            question: 'Which gas do plants primarily absorb during photosynthesis?',
            options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
            correctAnswerIndex: 1,
            difficulty: 'easy',
          ),
        ];
    }
  }
}
