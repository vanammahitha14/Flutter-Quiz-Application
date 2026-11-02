# QuizMaster – Quiz Application Using Flutter

[![Build and Release Android APK](https://github.com/vanammahitha14/Flutter-Quiz-Application/actions/workflows/build-apk.yml/badge.svg)](https://github.com/vanammahitha14/Flutter-Quiz-Application/actions/workflows/build-apk.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.3-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.3-0175C2?logo=dart)](https://dart.dev)
[![Provider](https://img.shields.io/badge/State-Provider%206.1-blue)](https://pub.dev/packages/provider)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An interactive, responsive, and robust Quiz Application built with **Flutter**, **Dart**, and **Provider** state management. Designed and developed according to the official **Flutter Group Project Specification**.

---

## 🔗 Project Links

- **Public GitHub Repository:** [https://github.com/vanammahitha14/Flutter-Quiz-Application](https://github.com/vanammahitha14/Flutter-Quiz-Application)
- **Direct Download Release APK:** [https://github.com/vanammahitha14/Flutter-Quiz-Application/releases/tag/v1.0.0](https://github.com/vanammahitha14/Flutter-Quiz-Application/releases/tag/v1.0.0)
- **Live Web Application (Vercel):** [https://flutter-quiz-application.vercel.app](https://flutter-quiz-application.vercel.app)
- **Live Web Application (GitHub Pages):** [https://vanammahitha14.github.io/Flutter-Quiz-Application/](https://vanammahitha14.github.io/Flutter-Quiz-Application/)

---

## 📱 1. Application Name, Topic & Description

- **Application Name:** QuizMaster
- **Project Title:** Quiz Application Using Flutter
- **Topic:** Interactive Mobile Quiz & Learning Application
- **Platform:** Android (Release APK), Web, iOS, Desktop
- **Architecture:** Provider Pattern (`ChangeNotifier`, `Consumer`) with Service Layer (`ApiService`, `StorageService`)

### Short Description
QuizMaster is an interactive educational quiz platform that lets learners test their knowledge across multiple domains (Computer Science, General Knowledge, Sports, History, Geography, and user-created custom quizzes). The application features online trivia synchronization, local persistent storage for personal best scores and custom questions, four mandatory list states, form validation, and question-by-question performance review.

---

## 🖼️ 2. Screen Visuals & Architecture

### Five Mandatory Screens

```
┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐
│     1. HOME SCREEN     │      │   2. DETAILS SCREEN    │      │    3. QUIZ SCREEN      │
├────────────────────────┤      ├────────────────────────┤      ├────────────────────────┤
│ 🧠 QuizMaster       ⋮  │      │ <  Quiz Details        │      │ Science & Computers    │
│ ┌────────────────────┐ │      │ ┌────────────────────┐ │      │ ████████░░░  Q 3 of 10 │
│ │ Ready to test?     │ │      │ │ 💻 Science & Tech  │ │      │ ┌────────────────────┐ │
│ └────────────────────┘ │      │ └────────────────────┘ │      │ │ What does CPU      │ │
│ 🔍 Search categories   │ ===> │ 📊 10 Qs | ~3 Mins     │ ===> │ │ stand for?         │ │
│ ┌────────┐ ┌────────┐  │      │ 🏆 Best Score: 9/10    │      │ └────────────────────┘ │
│ │Science │ │General │  │      │ 📜 5 Quiz Instructions │      │ [A] Central Proc Unit  │
│ └────────┘ └────────┘  │      │                        │      │ [B] Computer Personal  │
│ ┌────────┐ ┌────────┐  │      │ [  START QUIZ NOW   ]  │      │ [C] Central Processor  │
│ │Sports  │ │History │  │      │                        │      │ [D] Core Unit          │
│ └────────┘ └────────┘  │      │                        │      │                        │
│         [+ Add Question]      │                        │      │ [< Back]  [Next Q >]   │
└────────────────────────┘      └────────────────────────┘      └────────────────────────┘
            │                                                                │
            │                                                                ▼
┌────────────────────────┐                                      ┌────────────────────────┐
│  5. ADD QUESTION FORM  │                                      │   4. RESULTS SCREEN    │
├────────────────────────┤                                      ├────────────────────────┤
│ <  Add Custom Question │                                      │ Quiz Results           │
│ Category: [Custom   ▼] │                                      │ 🏆 NEW PERSONAL BEST!  │
│ Question: [__________] │ <=================================== │        8 / 10          │
│ Option A: [__________] │       (Add Custom Question)          │       80% Score        │
│ Option B: [__________] │                                      │ ┌──────┐┌──────┐┌────┐ │
│ Option C: [__________] │                                      │ │8 Cor ││2 Inc ││9 Rec│ │
│ Option D: [__________] │                                      │ └──────┘└──────┘└────┘ │
│ Correct: [A] [B] [C][D]│                                      │ 📝 Question Review:    │
│ [SAVE CUSTOM QUESTION] │                                      │   Q1. ✓ Correct        │
└────────────────────────┘                                      │   Q2. ✗ Wrong (Ans: B) │
                                                                │ [Play Again] [Home]    │
                                                                └────────────────────────┘
```

---

## 🌐 3. Data Sources Used

QuizMaster implements a hybrid data architecture combining live network data and local persistence:

1. **Public REST API (Remote Questions):**
   - **Provider:** Open Trivia Database (OpenTDB)
   - **Endpoint:** `https://opentdb.com/api.php?amount=10&category={id}&type=multiple`
   - **Resilience:** Implements automatic HTML entity decoding (`&quot;` → `"`, `&#039;` → `'`, `&amp;` → `&`) and an offline fallback mechanism with curated offline questions to guarantee zero crashes during network loss.
2. **Local Storage (Persistent Real Data):**
   - **Library:** `shared_preferences`
   - **Saved Data:**
     - Best scores per category (`quizmaster_best_scores`)
     - User-created custom questions (`quizmaster_custom_questions`)
     - Complete quiz completion history (`quizmaster_quiz_history`)
   - **Persistence Guarantee:** Best scores and custom questions remain saved even after force-closing or restarting the app.

---

## ⚡ 4. Four Mandatory List States (GP3 Compliance)

The Home Screen handles all four required states:
1. **Loading State:** Centered `CircularProgressIndicator` with real-time connection status.
2. **Error State:** Network error graphic, explanation text, and an active **Retry Connection** button.
3. **Empty State:** Empty inventory graphic and a **Reload Categories** button.
4. **Data State:** Dynamic grid of categories with search filtering, question count, and personal high-score badges.

> 💡 **Demonstration Feature:** Tap the **`⋮`** menu in the Home Screen app bar to toggle between all 4 states on demand during your project presentation.

---

## 🛡️ 5. Form Validation (Step 8 Compliance)

The **Add Custom Question Screen** enforces strict validation:
- **Category:** Must be selected from the category dropdown.
- **Question Text:** Cannot be empty; must be at least 5 characters long.
- **Option A:** Cannot be empty.
- **Option B:** Cannot be empty.
- **Option C:** Cannot be empty.
- **Option D:** Cannot be empty.
- **Correct Answer:** Must select which option (A, B, C, or D) is the correct answer.

---

## 🚀 6. Steps to Run the Project

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.22.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (3.3.0 or higher)
- Android Device with USB Debugging enabled, OR Google Chrome browser

### Commands
```bash
# 1. Clone the repository
git clone https://github.com/vanammahitha14/Flutter-Quiz-Application.git
cd Flutter-Quiz-Application/quiz_master

# 2. Install dependencies
flutter pub get

# 3. Verify static analysis (Zero issues guaranteed)
flutter analyze

# 4. Run automated test suite
flutter test

# 5. Run on your connected phone or emulator
flutter run

# 6. Or run instantly on Google Chrome
flutter run -d chrome
```

---

## 📦 7. How to Install the Release APK

1. On your physical Android phone, open the browser and visit:
   👉 **[https://github.com/vanammahitha14/Flutter-Quiz-Application/releases/tag/v1.0.0](https://github.com/vanammahitha14/Flutter-Quiz-Application/releases/tag/v1.0.0)**
2. Tap **`app-release.apk`** to download it.
3. Open the downloaded file and tap **Install** (allow installation from this source if prompted).
4. Launch **QuizMaster** directly on your device.

---

## 👥 8. Team Members & Contributions (2-Member Team)

| Member Name | Role & Contact | Parts Built & Core Contributions |
|:---|:---|:---|
| **Mahitha Vanam** *(Member 1 - Lead)* | • Role: Project Lead & State Architect<br>• GitHub: [`@vanammahitha14`](https://github.com/vanammahitha14)<br>• Email: `vanammahitha@gmail.com` | • Application architecture, layout & directory structure<br>• Central `QuizProvider` state management (`ChangeNotifier`)<br>• Screen 1: Home Screen with 4 mandatory list states (Loading, Error, Empty, Loaded - GP3)<br>• Screen 2: Quiz Details Screen with rules, duration & statistics<br>• `ApiService` Open Trivia DB REST integration & HTML unescaping<br>• GitHub Actions CI/CD workflows for automated testing, GitHub Pages & Release APK generation |
| **Team Partner** *(Member 2 - Co-Developer)* | • Role: Full-Stack Mobile Developer & QA<br>• GitHub: `@co-developer`<br>• Email: `member2@quizmaster.local` | • Screen 3: Quiz Screen with question progress (`Q 3 of 10`), 4 answer options & tap debouncing<br>• Screen 4: Results Screen with score percentage, personal best badge & question-by-question review<br>• Screen 5: Add Custom Question Form with strict 5-field validation<br>• `StorageService` using `SharedPreferences` for persistent high scores & custom questions<br>• Reusable UI widgets (`CategoryCard`, `AnswerOption`) and Material 3 theme styling<br>• Automated unit and widget tests in `quiz_screen_test.dart` & physical device testing |

---

## 📋 9. Defect Log

| Defect # | Description | Steps to Reproduce | Root Cause | Status |
|:---:|:---|:---|:---|:---:|
| **DEF-01** | OpenTDB trivia questions displayed HTML entities (e.g. `&#039;` for apostrophe and `&quot;` for quotes). | Start any General Knowledge quiz containing quote marks. | OpenTDB API delivers HTML-encoded entities instead of plaintext. | **Fixed** (Added regex-based `Question.unescapeHtml()` decoder). |
| **DEF-02** | Rapid fast tapping on "Submit Quiz" triggered duplicate navigation pushes. | Double-tap "Submit Quiz" rapidly on question 10. | No submission lock guard on the submit handler. | **Fixed** (Implemented `_isSubmitting` debounce flag). |
| **DEF-03** | Highest scores were wiped after closing and restarting the application. | Complete a quiz, establish a score of 8, force close app, reopen. | Scores were stored in runtime RAM memory only. | **Fixed** (Integrated `SharedPreferences` in `StorageService.saveScoreIfBest`). |
| **DEF-04** | App crashed with unhandled exception if user started a quiz while offline. | Enable Airplane mode and tap "Start Quiz". | Unhandled `SocketException` in `http.get`. | **Fixed** (Added try/catch with fallback to curated high-quality offline questions). |
| **DEF-05** | Form allowed submitting empty options when adding custom questions. | Navigate to Add Question screen and press "Save". | Missing Form `validator` logic on text fields. | **Fixed** (Added strict `FormState` validation across all 5 fields). |

---

## ⏱️ 10. Five-Minute Live Demonstration Schedule (Step 15 - 2-Member Team)

| Time | Presenter | Demonstration Script & Activity |
|:---:|:---:|:---|
| **0:00 - 0:30** *(30s)* | **Member 1** | **Introduction:** *"Good morning. We are presenting **QuizMaster**, an interactive Flutter learning app built with Provider state management, Open Trivia API integration, persistent storage, and strict form validation."* |
| **0:30 - 2:00** *(1.5m)* | **Member 1** | **Home & Details Screens:**<br>• Demonstrate Data state and category search filtering.<br>• Tap the `⋮` menu to show the other 3 mandatory GP3 states (Loading, Error with Retry, Empty).<br>• Open Details Screen, show rules and tap "Start Quiz Now". |
| **2:00 - 3:30** *(1.5m)* | **Member 2** | **Quiz, Results & Form Screens:**<br>• Demonstrate active quiz, answer selection highlight, and progress bar.<br>• Submit quiz: show score percentage, new personal best badge, and question-by-question review.<br>• Open Add Custom Question: tap Save on empty form to show validation errors, then add a custom question and verify it saves to Custom Questions. |
| **3:30 - 4:30** *(1m)* | **Member 1 & 2** | **Technical Problem & Solution:** *"One key challenge was API rate limiting and raw HTML entities from Open Trivia DB. We resolved this by implementing an HTML unescaping parser and an offline fallback repository so the application never shows an unhandled red error screen."* |
| **4:30 - 5:00** *(30s)* | **Both** | **GitHub & APK:** Show the Git commits demonstrating continuous development from both members, and demonstrate the release APK running on a physical Android phone. |
