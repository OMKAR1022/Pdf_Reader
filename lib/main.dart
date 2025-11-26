import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/flavor_config.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/pdf_creator/presentation/pages/image_to_pdf_page.dart';
import 'features/pdf_reader/presentation/pages/pdf_reader_page.dart';
import 'features/text_to_pdf/presentation/pages/text_to_pdf_page.dart';
import 'features/merge_pdf/presentation/pages/merge_pdf_page.dart';
import 'features/scan_to_pdf/presentation/pages/scan_to_pdf_page.dart';
import 'features/pdf_editor/presentation/pages/page_editor_page.dart';
import 'features/tools/presentation/pages/compress_pdf_page.dart';
import 'features/tools/presentation/pages/pdf_to_image_page.dart';
import 'features/tools/presentation/pages/password_protect_page.dart';
import 'features/tools/presentation/pages/zip_to_pdf_page.dart';
import 'features/tools/presentation/pages/split_pdf_page.dart';
import 'features/annotations/presentation/pages/annotation_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/presentation/pages/settings_page.dart';

void main() {
  // Initialize default flavor config if not already set
  try {
    FlavorConfig.instance;
  } catch (e) {
    FlavorConfig(
      flavor: Flavor.production,
      name: 'PROD',
      appName: 'Free PDF Maker',
      packageId: 'com.freepdfmaker',
      enableLogging: false,
    );
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(LoadSettings()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: FlavorConfig.instance.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            // Start with splash screen
            home: const SplashPage(),
            // Define routes
            routes: {
              '/splash': (context) => const SplashPage(),
              '/onboarding': (context) => const OnboardingPage(),
              '/home': (context) => const HomePage(),
              '/image-to-pdf': (context) => const ImageToPdfPage(),
              '/text-to-pdf': (context) => const TextToPdfPage(),
              '/merge-pdfs': (context) => const MergePdfPage(),
              '/scan-to-pdf': (context) => const ScanToPdfPage(),
              '/pdf-reader': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                return PdfReaderPage(initialPath: args as String?);
              },
              '/page-editor': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as String;
                return PageEditorPage(pdfPath: args);
              },
              '/compress-pdf': (context) => const CompressPdfPage(),
              '/pdf-to-image': (context) => const PdfToImagePage(),
              '/password-protect': (context) => const PasswordProtectPage(),
              '/zip-to-pdf': (context) => const ZipToPdfPage(),
              '/split-pdf': (context) => const SplitPdfPage(),
              '/annotate-pdf': (context) => const AnnotationPage(),
              '/settings': (context) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
