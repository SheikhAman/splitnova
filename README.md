# 🧾 SplitNova — Bill & Tip Calculator

<p align="center">
  <img src="screenshots/gif/demo.gif" alt="SplitNova Demo" style="width: 80%; max-height: 80vh; object-fit: cover; border-radius: 12px;" />
</p>

<p align="center">
  <img src="screenshots/badges/built-with-love.svg" height="28px" />&nbsp;&nbsp;
  <img src="screenshots/badges/flutter-dart.svg" height="28px" />&nbsp;&nbsp;
  <a href="https://choosealicense.com/licenses/mit/" target="_blank">
    <img src="screenshots/badges/license-MIT.svg" height="28px" />
  </a>&nbsp;&nbsp;
  <img src="screenshots/badges/Flutter-3.svg" height="28px" />&nbsp;&nbsp;
  <img src="screenshots/badges/dart-null_safety-blue.svg" height="28px" />
</p>

<p align="center">
  <b>A clean, modern Flutter app that makes splitting bills and calculating tips effortless.</b><br/>
  Built for learning, built for real use.
</p>

---

## 🎯 Overview

Every day, all around the world, people face the same uncomfortable moment — the bill arrives, and nobody knows who owes what.

Friends splitting a dinner. Colleagues dividing a team lunch. Families sharing a vacation expense. Housemates settling monthly utilities. Travelers calculating a shared cab. No matter the relationship or the occasion, the problem is universal: **money conversations are awkward, and mental math makes them worse.**

**SplitNova** removes that friction entirely. Enter the total, choose a tip, set the number of people — and everyone instantly sees exactly what they owe. Unequal splits are handled too, so if someone ordered more, they pay more, no spreadsheet required. Share the result as an image or send it straight to WhatsApp, and the conversation is over before it starts.

Built as a real-world Flutter project, SplitNova goes beyond a basic calculator — featuring voice input, QR code sharing, local history, multi-language support, and a Firebase-backed remote config system for version management and maintenance control.

---

## ✨ Features

| Feature | Description |
|---|---|
| 💡 Dynamic Tip Calculator | Select from preset tip percentages or enter a custom value |
| 👥 Equal & Unequal Splits | Split evenly or itemize by what each person ordered |
| ⚡ Real-time Calculation | Results update instantly as you type — no submit button needed |
| 🎙️ Voice Input | Speak the bill amount using the device microphone |
| 📸 Save as Image | Capture the split summary and save it directly to the gallery |
| 🔗 Share Anywhere | Share via WhatsApp, iMessage, email, or any installed app |
| 📲 QR Code Generator | Generate a scannable QR code others can use to view the split |
| 🕓 History Tracking | Persist past splits locally for quick reference |
| 🌍 Multi-language Support | Full i18n support via GetX translations |
| 🎨 Modern Dark UI | Responsive dark design that scales across all screen sizes |

---

## 🛠️ Tech Stack

### Core & State Management

| Package | Role |
|---|---|
| [Flutter](https://flutter.dev/) | Cross-platform framework — single codebase for Android & iOS |
| [GetX](https://pub.dev/packages/get) | State management, navigation, dependency injection, and i18n |
| [GetStorage](https://pub.dev/packages/get_storage) | Fast key-value local storage for split history |

### Backend & Data

| Package | Role |
|---|---|
| [firebase_core](https://pub.dev/packages/firebase_core) | Firebase SDK initialization |
| [cloud_firestore](https://pub.dev/packages/cloud_firestore) | Cloud database for real-time remote configuration |
| [http](https://pub.dev/packages/http) | HTTP requests for external data fetching |
| [html](https://pub.dev/packages/html) | Parses HTML from web responses |

### UI & Design

| Package | Role |
|---|---|
| [google_fonts](https://pub.dev/packages/google_fonts) | Custom typography without manual font setup |
| [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) | Responsive layout scaling across all screen sizes |
| [flutter_animate](https://pub.dev/packages/flutter_animate) | Declarative, composable UI animations |
| [curved_navigation_bar](https://pub.dev/packages/curved_navigation_bar) | Stylish curved bottom navigation bar |
| [fluttertoast](https://pub.dev/packages/fluttertoast) | Lightweight toast notifications |

### Device Features & Sharing

| Package | Role |
|---|---|
| [speech_to_text](https://pub.dev/packages/speech_to_text) | Voice input for bill amount entry |
| [screenshot](https://pub.dev/packages/screenshot) | Captures any widget as an image |
| [saver_gallery](https://pub.dev/packages/saver_gallery) | Saves screenshot to the device gallery |
| [share_plus](https://pub.dev/packages/share_plus) | Cross-platform share sheet integration |
| [qr_flutter](https://pub.dev/packages/qr_flutter) | QR code generation from split data |
| [url_launcher](https://pub.dev/packages/url_launcher) | Opens external links in the browser |
| [permission_handler](https://pub.dev/packages/permission_handler) | Runtime permission requests (storage, microphone) |

### Utilities

| Package | Role |
|---|---|
| [intl](https://pub.dev/packages/intl) | Number, currency, and date formatting by locale |
| [package_info_plus](https://pub.dev/packages/package_info_plus) | Reads the installed app version |
| [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) | Generates Android and iOS launcher icons from a single source image |

---

## 📂 Project Structure

SplitNova uses a **feature-first architecture** — each screen owns its own controller, view, and bindings. This mirrors production Flutter patterns and makes the codebase easy to navigate and extend.

```
lib/
├── app/
│   ├── controllers/        # Shared logic (tip calculation, language, theme)
│   ├── core/               # Constants, utilities, global theme config
│   ├── data/               # Data models (e.g. HistoryItem)
│   ├── modules/            # One folder per feature/screen
│   │   ├── home/           #   Main bill splitter screen
│   │   ├── splash/         #   Animated launch screen
│   │   ├── history/        #   Past splits list
│   │   ├── settings/       #   Language, theme, preferences
│   │   ├── support/        #   Feedback & support
│   │   └── config_screens/ #   Update, maintenance, and other config screens
│   ├── routes/             # Centralized route definitions
│   ├── services/           # Background services (local storage, remote config)
│   ├── theme/              # Color palettes and text styles
│   └── widgets/            # Shared, reusable UI components
├── translations/           # i18n language files
└── main.dart               # App entry point
```

> **Getting started?** Begin with `main.dart`, then explore `modules/home/` — that's where the core calculation logic lives.

---

## 🚀 Running Locally

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `>=3.0.0 <4.0.0`)
- Android emulator, iOS simulator, or a connected device
- A Firebase project with:
    - `google-services.json` placed in `android/app/`
    - `GoogleService-Info.plist` placed in `ios/Runner/`

### Steps

```bash
# Clone the repository
git clone https://github.com/SheikhAman/splitnova.git
cd splitnova

# Install dependencies
flutter pub get

# Run the app
flutter run
```

> New to Flutter? Follow the [official setup guide](https://docs.flutter.dev/get-started/install) for your OS.

---

## 💡 What I Learned Building This

- **GetX** for scalable, low-boilerplate state management, routing, and dependency injection
- **GetStorage** as a faster, GetX-native alternative to SharedPreferences
- **Firebase & Firestore** for integrating a cloud backend into a mobile app
- **Speech-to-text and runtime permissions** for native device feature integration
- **Screenshot + gallery saving** for capturing and exporting rendered Flutter widgets as images
- **QR code generation and deep sharing** across platforms
- **flutter_screenutil** for building truly responsive UIs across all screen sizes
- **Feature-first architecture** that scales cleanly as the app grows
- **Localization (i18n) with GetX** for multi-language, global-ready apps

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**Sheikh Aman** — Flutter Developer focused on clean UI, scalable architecture, and real-world app patterns.

🔗 [GitHub](https://github.com/SheikhAman) · Open to collaborations and opportunities