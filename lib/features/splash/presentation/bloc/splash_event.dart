import 'package:equatable/equatable.dart';

/// Base class for all Splash events
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the splash screen
class SplashStarted extends SplashEvent {
  const SplashStarted();
}
