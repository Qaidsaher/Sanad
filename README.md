# Sanad

Sanad is more than just an application; it's the future of organizing pilgrims. Designed as a comprehensive Flutter solution, Sanad helps pilgrims submit and track plantation reports, earn points, and stay connected with authorities—all through a modern, user-friendly interface.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Resources](#resources)
- [Contributing](#contributing)
- [License](#license)

## Features

- User Authentication (Login & Register)
- Interactive Map for marking plantation locations
- Submission & tracking of plantation reports
- Points collection system with proof uploads
- Admin panel for report review, approval, and statistics
- Multi-language support (English & Arabic)
- Dark & Light modes
- Responsive design for mobile and tablet

## Prerequisites

Before you begin, ensure you have met the following requirements:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- [Dart SDK](https://dart.dev/get-dart) (installed with Flutter)
- An Android/iOS emulator or physical device for testing
- Optional: [Firebase CLI](https://firebase.google.com/docs/cli) for configuring Firebase

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Qaidsaher/sanad.git
   ```

2. **Navigate into the project directory**

   ```bash
   cd sanad
   ```

3. **Fetch dependencies**

   ```bash
   flutter pub get
   ```

4. **Configure Firebase (if applicable)**

   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```

5. **Set up environment variables**

    - Copy `.env.example` to `.env`
    - Fill in your Firebase and API keys

## Running the App

To launch the application on an emulator or connected device:

```bash
flutter run
```

To build a production-ready APK:

```bash
flutter build apk --release
```

To build for iOS (requires Xcode on macOS):

```bash
flutter build ios --release
```

## Project Structure

```
sanad/
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── lib/
│   ├── components/        # Reusable widgets
│   ├── models/            # Data models
│   ├── screens/           # UI pages (Login, Register, Map, Reports...)
│   ├── services/          # API & Firebase services
│   ├── utils/             # Utility functions & constants
│   ├── main.dart          # App entry point
│   └── theme.dart         # Theme configurations
├── test/                  # Unit & widget tests
├── .env.example           # Environment variable template
├── pubspec.yaml           # Flutter dependencies
└── README.md              # Project documentation
```

## Getting Started

If this is your first Flutter project, check out these resources to learn the basics:

- [Flutter Codelab: Your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook: Useful samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

## Resources

- Flutter Docs: https://docs.flutter.dev/
- Dart Docs: https://dart.dev/
- Firebase Docs: https://firebase.google.com/docs

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements.

1. Fork the repository
2. Create a new branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

