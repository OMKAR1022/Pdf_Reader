/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Free PDF Maker';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // File Settings
  static const String defaultPageSize = 'A4';
  static const String defaultQuality = 'high';
  
  // Directories
  static const String pdfDirectory = 'PDFs';
  static const String tempDirectory = 'temp';
  static const String signaturesDirectory = 'signatures';
  
  // Limits
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxPdfSize = 50 * 1024 * 1024; // 50MB
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
