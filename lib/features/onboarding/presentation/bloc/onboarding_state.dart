import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {
  final int pageIndex;

  const OnboardingInitial({this.pageIndex = 0});

  @override
  List<Object> get props => [pageIndex];
}

class OnboardingNavigateToHome extends OnboardingState {
  const OnboardingNavigateToHome();
}
