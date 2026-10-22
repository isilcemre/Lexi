# Lexi — Your Personal Vocabulary Learning Companion

Lexi is a cross-platform vocabulary learning app built with Flutter and Firebase. Users sign in, build their own word lists, study them with swipeable flashcards, test themselves with quizzes, and track their progress with charts.

---

## Features

- Sign in with email, Google, or Apple (Firebase Authentication)
- Multiple languages, each with its own word lists
- Swipe-based flashcards for reviewing words (known / still learning)
- Quiz mode with a result screen at the end
- Word list and word detail screens
- Progress statistics with charts
- Cloud sync with Cloud Firestore, plus local caching for fast access
- Smooth animations and Lottie illustrations

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.12.0) |
| State Management | Riverpod (`flutter_riverpod`, `riverpod_annotation`) |
| Navigation | GoRouter |
| Backend | Firebase Auth, Cloud Firestore, Firebase Analytics |
| Auth Providers | Google Sign-In, Sign in with Apple |
| Local Storage | Hive, SharedPreferences |
| UI & Design | Google Fonts, Flutter Animate, Lottie |
| Charts | fl_chart |
| Flashcards | flutter_card_swiper |
| Utilities | uuid, intl |

---

## Project Structure

```
Lexi/
├── android/                  # Android platform code
├── ios/                      # iOS platform code
├── web/                      # Web platform code
├── macos/ linux/ windows/    # Desktop platform code
├── lib/                      # Application source code
│   ├── ...                   # Screens: flashcard, quiz, quiz result,
│   │                         # word list, word detail, etc.
├── test/                     # Tests
├── assets/
│   ├── animations/           # Lottie animations
│   └── images/
├── firebase.json             # Firebase configuration
├── firestore.rules           # Firestore security rules
├── firestore.indexes.json    # Firestore indexes
└── pubspec.yaml              # Dependencies
```

---

## Getting Started

### Prerequisites

- Flutter SDK (Dart ^3.12.0)
- A Firebase project
- Android Studio / Xcode (for running on emulators or devices)

### Firebase Setup

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email, Google, Apple) and **Cloud Firestore**.
3. Install the FlutterFire CLI and connect the app to your project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Deploy the Firestore rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### Running the App

```bash
git clone https://github.com/isilcemre/Lexi.git
cd Lexi
flutter pub get
flutter run
```

---

## Usage

1. Open the app and sign in.
2. Choose a language and add words to your list.
3. Open **Flashcards** and swipe cards to review words.
4. Take a **Quiz** to test what you have learned.
5. Tap any word in the list to see its details.
6. Check your progress on the statistics screen.

---

## Screenshots

<img width="250"  alt="Screenshot_1792676219" src="https://github.com/user-attachments/assets/b6b8893c-e20d-45c1-90ad-228d5b818808" />
<img width="250"  alt="Screenshot_1792676382" src="https://github.com/user-attachments/assets/29001690-2dfa-4ab8-bd46-6b0f3a63d9f8" />
<img width="250"  alt="Screenshot_1792676409" src="https://github.com/user-attachments/assets/7ce27904-8abf-4220-8605-49b577af442d" />
<img width="250"  alt="Screenshot_1792676636" src="https://github.com/user-attachments/assets/6b2ee541-b0da-4a63-bfba-fabf762b3603" />
<img width="250"  alt="Screenshot_1792676931" src="https://github.com/user-attachments/assets/c04eda17-d6af-4bac-8cba-bac78f7676c1" />
<img width="250"  alt="Screenshot_1792676946" src="https://github.com/user-attachments/assets/40e3c2ef-26f7-4d97-826f-e301f87ed4f8" />
<img width="250"  alt="Screenshot_1792676960" src="https://github.com/user-attachments/assets/7ac2bf8b-c3f9-41c6-8d43-ce0653e4573c" />
<img width="250"  alt="Screenshot_1792676971" src="https://github.com/user-attachments/assets/42d541c6-24bf-42f5-8a81-9e28050fe162" />
<img width="250"  alt="Screenshot_1792677012" src="https://github.com/user-attachments/assets/b45c119a-81ca-4ea7-8b52-427187b620b5" />

<img width="250"  alt="Ekran görüntüsü 2026-10-22 165050" src="https://github.com/user-attachments/assets/f6a69afd-508a-4577-99f7-edda9154f3de" />
<img width="250"  alt="Ekran görüntüsü 2026-10-22 165036" src="https://github.com/user-attachments/assets/5d41a019-5d7f-48aa-9bbb-1ba54a103283" />

<img width="250"  alt="Screenshot_1792677063" src="https://github.com/user-attachments/assets/c63706c2-238d-4156-b9f7-96ba2b48ec18" />
<img width="250"  alt="Screenshot_1792677070" src="https://github.com/user-attachments/assets/c4c12649-b539-48e5-b07b-2da77a69163d" />
<img width="250"  alt="Screenshot_1792677077" src="https://github.com/user-attachments/assets/9486a88d-c544-424e-b02c-a79ef3debbfe" />
<img width="250" alt="Screenshot_1792677080" src="https://github.com/user-attachments/assets/bb8c8da3-78c3-42c7-b819-5d8c5b7de959" />

---

## Author

[@isilcemre](https://github.com/isilcemre)
