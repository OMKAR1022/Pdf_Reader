import 'package:equatable/equatable.dart';

/// Base class for all Splash states
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state when splash screen loads
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// State when splash animation is in progress
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// State to navigate to onboarding (first time user)
class NavigateToOnboarding extends SplashState {
  const NavigateToOnboarding();
}

/// State to navigate to home (returning user)
class NavigateToHome extends SplashState {
  const NavigateToHome();
}
