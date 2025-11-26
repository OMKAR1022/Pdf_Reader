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
│   ├── splash/         ✅ Animated splash screen
│   ├── onboarding/     🔄 Coming soon
│   ├── home/           🔄 Coming soon
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

### Quick Start (No Flavor)
```bash
flutter run
```
This will use the production flavor by default.

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

### Debug Build (Development)
```bash
flutter build apk -t lib/main_dev.dart --flavor dev
```

### Debug Build (Staging)
```bash
flutter build apk -t lib/main_staging.dart --flavor staging
```

### Release Build (Production)
```bash
flutter build apk -t lib/main_production.dart --flavor production --release
```

### Build All Flavors
```bash
cd android && ./gradlew assembleDebug
```
This will create APKs for all flavors in:
- `build/app/outputs/apk/dev/debug/app-dev-debug.apk`
- `build/app/outputs/apk/staging/debug/app-staging-debug.apk`
- `build/app/outputs/apk/production/debug/app-production-debug.apk`

## 📦 Dependencies

- **flutter_bloc**: State management
- **equatable**: Value equality
- **get_it**: Dependency injection
- **shared_preferences**: Local storage
- **lottie**: Animations
- **syncfusion_flutter_pdfviewer**: PDF viewing
- **pdf**: PDF generation
- **image_picker**: Image selection from gallery/camera
- **image_cropper**: Image cropping and rotation
- **reorderable_grid_view**: Drag-and-drop grid
- **path_provider**: File system paths
- **file_picker**: File selection
- **permission_handler**: Runtime permissions
- **hive**: Local database (to be added)

## 🎨 Features Implemented

- ✅ **Project Setup**
  - Flutter flavors (dev, staging, production)
  - BLoC architecture
  - Theme configuration (light/dark)
  
- ✅ **Splash Screen** (Task 2.1)
  - Animated logo with fade and scale effects
  - Loading indicator
  - Smart navigation (onboarding/home)
  - Version display
  
- ✅ **PDF Creator - Image to PDF** (Task 4.1)
  - Multi-image selection from gallery
  - Camera integration for single images
  - Drag-and-drop reordering of images
  - Image crop/rotate functionality
  - PDF generation from images
  - Beautiful preview grid with page numbers
  - Empty state and success dialogs
  
- 🔄 **Onboarding** (Task 2.2 - Coming Next)
- 🔄 **Home Screen** (Task 2.3)
- 🔄 **PDF Reader**
- 🔄 **PDF Editor**
- 🔄 **Annotations**
- 🔄 **File Management**
- 🔄 **Settings**

## 📝 Development Progress

See [implementation_plan.md](/.gemini/antigravity/brain/e6afa5ca-199d-452f-9c1f-0b7a71c60d4e/implementation_plan.md) for detailed roadmap.

## 🐛 Troubleshooting

### Gradle build failed error
If you see "Gradle build failed to produce an .apk file", try:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Use a specific flavor: `flutter run -t lib/main_dev.dart --flavor dev`

### Multiple devices
If prompted to select a device, choose:
- Android emulator for testing
- Physical device for real-world testing

## 📄 License

Free and open source.
