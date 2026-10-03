# Cashflo 💸

A shared expense tracker built with Flutter and Firebase. Create a **Flo** (a shared expense group), add expenses together, and see where the money goes with a clean, category-wise breakdown.

> Replace the placeholders marked with `TODO` with your own details (screenshots, repo URL, etc.).

---

## ✨ Features

- **Shared Flos**: expenses are grouped under a Flo, and everyone in it sees the same data in real time.
- **Quick expense entry**: add a description, amount (₹) and a mandatory **category** from a bottom-sheet form.
- **Category icons and colors**: every category has its own icon and color, shown in the expense list and charts.
- **Spending insights**: a donut chart of total spending, switchable between **By Category** and **By Person**, with per-row amounts, percentages and progress bars.
- **Interactive charts**: tap a slice or a row to highlight it and see its details in the center of the donut.
- **Live updates**: Cloud Firestore streams keep every screen in sync.
- **Offline-friendly**: expense entry never blocks on the network; Firestore syncs when you're back online.
- **Indian number formatting**: amounts are shown as `₹1,23,456.00`.
- **Safe with old data**: expenses saved before categories existed show up as *Uncategorized* instead of crashing.

## 🛠 Tech Stack

| Area | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart) |
| Auth | [Firebase Authentication](https://firebase.google.com/docs/auth) |
| Database | [Cloud Firestore](https://firebase.google.com/docs/firestore) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A Firebase project
- Android Studio or VS Code with the Flutter extension
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) (recommended)

### 1. Clone the repository

```bash
git clone <TODO: your-repo-url>
cd cashflo
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up Firebase

1. Create a project in the [Firebase Console](https://console.firebase.google.com).
2. Enable **Authentication** and the sign-in method(s) the app uses.
3. Create a **Cloud Firestore** database.
4. Connect the app to your project:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This generates `firebase_options.dart` and the platform config files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).

5. For Android, add your debug/release **SHA-1 and SHA-256** fingerprints to the Firebase project settings if you use Google or phone sign-in:

   ```bash
   cd android && ./gradlew signingReport
   ```

### 4. Run the app

```bash
flutter run
```

## 📦 Building the APK

```bash
# Universal release APK
flutter build apk --release

# Smaller APKs, one per CPU architecture
flutter build apk --split-per-abi
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

For the Play Store, build an app bundle instead (`flutter build appbundle`) and sign it with your own release keystore. See Flutter's guide on [building and releasing an Android app](https://docs.flutter.dev/deployment/android).

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "Add my feature"`
4. Push the branch: `git push origin feature/my-feature`
5. Open a pull request

---

Built with ❤️ using Flutter and Firebase.