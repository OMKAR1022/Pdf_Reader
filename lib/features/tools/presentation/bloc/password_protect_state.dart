import 'package:equatable/equatable.dart';

abstract class PasswordProtectState extends Equatable {
  const PasswordProtectState();

  @override
  List<Object?> get props => [];
}

class PasswordProtectInitial extends PasswordProtectState {}

class PasswordProtectLoading extends PasswordProtectState {}

class PasswordProtectLoaded extends PasswordProtectState {
  final String originalPath;
  final String? protectedPath;

  const PasswordProtectLoaded({
    required this.originalPath,
    this.protectedPath,
  });

  PasswordProtectLoaded copyWith({
    String? originalPath,
    String? protectedPath,
  }) {
    return PasswordProtectLoaded(
      originalPath: originalPath ?? this.originalPath,
      protectedPath: protectedPath ?? this.protectedPath,
    );
  }

  @override
  List<Object?> get props => [originalPath, protectedPath];
}

class PasswordProtectError extends PasswordProtectState {
  final String message;

  const PasswordProtectError(this.message);

  @override
  List<Object?> get props => [message];
}
