import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingInitial(pageIndex: event.pageIndex));
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompleteKey, true);
    emit(const OnboardingNavigateToHome());
  }
}
