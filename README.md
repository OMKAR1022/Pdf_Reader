# Free PDF Maker

A comprehensive, feature-rich PDF reader and maker application for Android built with Flutter.

## 🏗️ Architecture

This project uses **BLoC (Business Logic Component)** architecture with **Flutter Flavors** for different build environments.

### Project Structure

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── theme/          # Theme configuration
│   ├── utils/          # Utility functions
│   ├── errors/         # Error handling
│   └── network/        # Network utilities
├── features/           # Feature modules
│   ├── splash/
│   ├── onboarding/
│   ├── home/
│   ├── pdf_reader/
│   ├── pdf_creator/
│   ├── pdf_editor/
│   ├── annotations/
│   ├── file_management/
│   ├── tools/
│   └── settings/
├── config/             # App configuration
│   └── flavor_config.dart
├── main.dart           # Common main entry
├── main_dev.dart       # Development flavor
├── main_staging.dart   # Staging flavor
└── main_production.dart # Production flavor
```

## 🚀 Running the App

### Development Flavor
```bash
flutter run -t lib/main_dev.dart --flavor dev
```

### Staging Flavor
```bash
flutter run -t lib/main_staging.dart --flavor staging
```

### Production Flavor
```bash
flutter run -t lib/main_production.dart --flavor production
```

## 🔧 Build Commands

### Debug Build
```bash
flutter build apk -t lib/main_dev.dart --flavor dev
```

### Release Build
```bash
flutter build apk -t lib/main_production.dart --flavor production --release
```

## 📦 Dependencies

- **flutter_bloc**: State management
- **equatable**: Value equality
- **get_it**: Dependency injection
- **syncfusion_flutter_pdf**: PDF handling (to be added)
- **hive**: Local storage (to be added)

## 🎨 Features (Planned)

- ✅ Project setup with flavors
- ✅ BLoC architecture
- ✅ Theme configuration
- 🔄 Splash screen
- 🔄 Onboarding
- 🔄 PDF Reader
- 🔄 PDF Creator
- 🔄 PDF Editor
- 🔄 Annotations
- 🔄 File Management
- 🔄 Settings

## 📝 Development Progress

See [implementation_plan.md](/.gemini/antigravity/brain/e6afa5ca-199d-452f-9c1f-0b7a71c60d4e/implementation_plan.md) for detailed roadmap.

## 📄 License

Free and open source.
