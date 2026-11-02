# QuizMaster – Quiz Application Using Flutter

A modern, interactive, and resilient Quiz Application built with **Flutter**, **Dart**, and **Provider** state management. Designed and developed according to the Flutter Group Project Specification.

---

## 📱 Project Overview

- **Application Name:** QuizMaster
- **Topic:** Interactive Learning & Trivia Quiz Application
- **Platform:** Android, iOS, Web, Windows
- **State Management:** Provider (`ChangeNotifier` & `Consumer`)
- **Data Persistence:** `shared_preferences`
- **Remote API:** Open Trivia Database (OpenTDB)

### Purpose
To deliver an engaging educational quiz experience where users can browse diverse trivia categories, challenge their knowledge through timed/untimed multiple-choice questions, analyze results with detailed review screens, persist high scores across app sessions, and author custom questions.

---

## ✨ Main Features

1. **Category Selection & Discovery:** Browse categories with question counts and personal high-score badges.
2. **Four Mandatory List States (GP3):**
   - **Loading State:** Circular indicator and feedback while categories initialize.
   - **Error State:** Network failure graphic, message, and **Retry Connection** button.
   - **Empty State:** Friendly graphic and **Reload** button when no items exist.
   - **Data State:** Interactive grid of quiz categories with search filtering.
3. **Comprehensive Quiz Experience:**
   - Real-time progress bar and counter (e.g. *Question 3 of 10*).
   - 4 response options with clean typography and selection highlight.
   - Prevention of accidental quits via modal confirmation (`PopScope`).
   - Fast-tap debouncing to avoid double submissions.
4. **Detailed Quiz Results & Analysis:**
   - Total score and percentage calculation.
   - Personal high score comparison with **NEW PERSONAL BEST!** badge.
   - Correct vs. Incorrect answer statistics.
   - Question-by-question review highlighting selected answers vs. correct answers.
5. **Add Custom Questions (Form with Strict Validation - Step 8):**
   - Category selection validation.
   - Question text validation (cannot be empty, minimum 5 characters).
   - Options A, B, C, D validation (none can be empty).
   - Correct answer selection validation.
   - Immediate persistence to local storage.
6. **Persistent Data:**
   - Best scores per category preserved after app restarts.
   - Custom user-created questions safely stored locally.

---

## 🏛️ Application Architecture & Folder Structure

```
quiz_master/
│
├── lib/
│   ├── main.dart                      # App entry point with Provider & Theme
│   │
│   ├── models/
│   │   ├── category.dart              # Quiz category model & curated topics
│   │   ├── question.dart              # Question model with HTML unescaping
│   │   └── quiz_result.dart           # Final score, accuracy, & question review
│   │
│   ├── services/
│   │   ├── api_service.dart           # OpenTDB REST client with offline fallback
│   │   └── storage_service.dart       # SharedPreferences persistence engine
│   │
│   ├── providers/
│   │   └── quiz_provider.dart         # Central ChangeNotifier state controller
│   │
│   ├── screens/
│   │   ├── home_screen.dart           # Screen 1: Home & 4 Mandatory States
│   │   ├── quiz_details_screen.dart   # Screen 2: Topic overview & start button
│   │   ├── quiz_screen.dart           # Screen 3: Active quiz & question options
│   │   ├── result_screen.dart         # Screen 4: Score, best record, & review
│   │   └── add_question_screen.dart   # Screen 5: Validated custom question form
│   │
│   ├── widgets/
│   │   ├── category_card.dart         # Reusable category tile widget
│   │   └── answer_option.dart         # Option card (A, B, C, D) with state styles
│   │
│   └── theme/
│       └── app_theme.dart             # Material 3 typography, colors, and styles
│
├── test/
│   └── quiz_screen_test.dart          # Unit and widget test suite
│
├── pubspec.yaml                       # Dependencies and assets
└── README.md                          # Documentation and defect log
```

---

## 🖥️ Screen Demonstrations

| Screen 1: Home (Data State) | Screen 2: Quiz Details | Screen 3: Quiz Active |
|:---:|:---:|:---:|
| Category selection with search bar & high score badges | Overview, rules, estimated duration, and start action | Progress counter, question card, and 4 styled choices |

| Screen 4: Quiz Results | Screen 5: Add Custom Question | Home: Error / Empty State |
|:---:|:---:|:---:|
| Score %, breakdown, record celebration, & answer review | Strict validation on question, 4 choices, & correct key | Full GP3 compliance with retry and recovery actions |

---

## 🌐 Data Sources

1. **Public API (Online Questions):**
   - **Service:** Open Trivia Database (`https://opentdb.com`)
   - **Endpoints:** `https://opentdb.com/api.php?amount=10&category={id}&type=multiple`
   - **Features:** Categorized multiple-choice questions, HTML entity decoding, offline fallback during rate limits or connectivity loss.
2. **Local Storage (Persistent Storage):**
   - **Service:** `shared_preferences`
   - **Stored Entities:**
     - Best scores per category (`quizmaster_best_scores`)
     - User-created custom questions (`quizmaster_custom_questions`)
     - Quiz completion history (`quizmaster_quiz_history`)

---

## 🚀 Steps to Run the Application

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code with Flutter extension
- Connected Android Device or Emulator

### Execution Commands

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/Flutter-Quiz-Application.git
   cd Flutter-Quiz-Application/quiz_master
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify static analysis:**
   ```bash
   flutter analyze
   ```
   *(Expected output: No issues found!)*

4. **Run test suite:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   flutter run
   ```

6. **Generate Release APK (Step 13):**
   ```bash
   flutter build apk --release
   ```
   The production APK will be created at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing and Validation

All tests adhere to project requirements under `test/quiz_screen_test.dart`:

- **Unit Test 1:** Score calculation matches correct option indices.
- **Unit Test 2:** HTML entities in trivia questions (e.g., `&quot;`, `&#039;`, `&amp;`) unescape cleanly.
- **Widget Test 1:** Home screen properly displays `QuizMaster` header and category cards in Data state.
- **Widget Test 2:** Home screen presents `CircularProgressIndicator` during the Loading state.
- **Widget Test 3:** Empty form submission on Add Custom Question triggers all 5 required validation error messages:
  - *"Question text cannot be empty"*
  - *"Option A cannot be empty"*
  - *"Option B cannot be empty"*
  - *"Option C cannot be empty"*
  - *"Option D cannot be empty"*
- **Widget Test 4:** Quiz screen renders question text, 4 choices, and updates selection state.

---

## 👥 Team Members and Contributions

| Member Name | Student ID | Core Responsibilities & Contributions |
|:---|:---|:---|
| **Member 1 (Lead)** | `FA21-BCS-001` | Project architecture, `QuizProvider` state management, and API integration |
| **Member 2** | `FA21-BCS-002` | Home Screen with 4 list states (Loading, Error, Empty, Data) & Details Screen |
| **Member 3** | `FA21-BCS-003` | Quiz Screen, option selection animations, and Results Screen review system |
| **Member 4** | `FA21-BCS-004` | Add Custom Question Screen form validation, Local Storage, & Release APK build |

---

## 📋 Defect Log

| Defect # | Description | Reproduction Steps | Root Cause | Status |
|:---|:---|:---|:---|:---:|
| **DEF-01** | OpenTDB questions displayed raw HTML entities like `&#039;` and `&quot;`. | Fetch any general knowledge question containing quotes. | API returns URL/HTML-encoded string formatting. | **Fixed** (Added `Question.unescapeHtml()` parser). |
| **DEF-02** | Rapid double-tapping on "Submit Quiz" caused multiple navigation transitions. | Quickly tap Submit button twice on the last question. | Absence of submission debounce / lock. | **Fixed** (Added `_isSubmitting` guard flag). |
| **DEF-03** | Best scores reset upon closing the application. | Finish quiz, close app from task switcher, reopen. | Score was only kept in RAM memory. | **Fixed** (Persisted best scores to `SharedPreferences`). |
| **DEF-04** | Missing internet crashed app with unhandled exception on category tap. | Turn on Airplane Mode and start a quiz. | Unhandled socket timeout in API call. | **Fixed** (Added try/catch with offline curated question fallback). |
| **DEF-05** | Empty custom question form allowed saving empty options. | Navigate to Add Question screen and press Save. | Missing Form validator rules. | **Fixed** (Added full `FormState` validation across all 5 fields). |

---

## ⏱️ Five-Minute Project Demonstration Guide (Step 15)

| Time | Segment | Demonstration Walkthrough |
|:---|:---|:---|
| **0:00 - 0:30** | **Introduction** | Present the team, purpose of **QuizMaster**, and architecture overview (Flutter + Provider + OpenTDB + SharedPreferences). |
| **0:30 - 3:30** | **Live App Demo** | • **Home Screen:** Show Data state, search filtering, and demonstrate 4 states (Loading, Error with Retry, Empty, Loaded) via top menu.<br>• **Details Screen:** Show category stats, instructions, and start button.<br>• **Quiz Screen:** Answer questions, show progress bar and answer selection.<br>• **Result Screen:** Display calculated score, high-score badge, and question-by-question review.<br>• **Add Question:** Submit empty form to show validation errors, then add a custom question and verify it appears in Custom Quizzes. |
| **3:30 - 4:30** | **Technical Challenge** | Explain handling API rate limiting & HTML entities from OpenTDB, and how the app seamlessly falls back to curated questions without red screen crashes. |
| **4:30 - 5:00** | **GitHub & APK** | Show Git commit history following continuous integration, running `flutter test`, and show generated release APK file. |
