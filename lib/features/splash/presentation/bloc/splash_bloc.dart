import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import 'splash_event.dart';
import 'splash_state.dart';

/// BLoC for managing splash screen logic
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  /// Handle splash started event
  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Wait for splash animation duration
    await Future.delayed(const Duration(seconds: 3));

    // Check if onboarding is complete
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingComplete = prefs.getBool(
      AppConstants.onboardingCompleteKey,
    ) ?? false;

    // Navigate based on onboarding status
    if (isOnboardingComplete) {
      emit(const NavigateToHome());
    } else {
      emit(const NavigateToOnboarding());
    }
  }
}
