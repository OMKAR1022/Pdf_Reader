import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/onboarding_page_model.dart';
import '../bloc/bloc.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;

  final List<OnboardingPageModel> _pages = [
    const OnboardingPageModel(
      title: 'Create PDFs',
      description: 'Convert images and text to professional PDF documents instantly.',
      icon: Icons.picture_as_pdf_rounded,
      color: Color(0xFF2196F3), // Blue
    ),
    const OnboardingPageModel(
      title: 'Scan Documents',
      description: 'Use your camera to scan physical documents with auto-edge detection.',
      icon: Icons.document_scanner_rounded,
      color: Color(0xFFFF9800), // Orange
    ),
    const OnboardingPageModel(
      title: 'Edit & Annotate',
      description: 'Merge, split, sign, and add notes to your PDF files easily.',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF4CAF50), // Green
    ),
    const OnboardingPageModel(
      title: 'Secure & Share',
      description: 'Protect your files with passwords and share them securely.',
      icon: Icons.security_rounded,
      color: Color(0xFF9C27B0), // Purple
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingNavigateToHome) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      context.read<OnboardingBloc>().add(const OnboardingCompleted());
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    context.read<OnboardingBloc>().add(OnboardingPageChanged(index));
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Bottom Controls
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  int currentIndex = 0;
                  if (state is OnboardingInitial) {
                    currentIndex = state.pageIndex;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots Indicator
                        Row(
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 8),
                              height: 8,
                              width: currentIndex == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: currentIndex == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // Next/Get Started Button
                        ElevatedButton(
                          onPressed: () {
                            if (currentIndex < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              context.read<OnboardingBloc>().add(const OnboardingCompleted());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                currentIndex == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                              ),
                              if (currentIndex != _pages.length - 1) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageModel page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
