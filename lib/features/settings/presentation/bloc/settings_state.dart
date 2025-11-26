import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool isLoading;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.isLoading = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeMode, isLoading];
}
