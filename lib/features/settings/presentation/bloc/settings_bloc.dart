import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _themeKey = 'theme_mode';

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      
      ThemeMode themeMode = ThemeMode.system;
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        themeMode = ThemeMode.values[themeIndex];
      }

      emit(state.copyWith(
        themeMode: themeMode,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(themeMode: event.themeMode));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, event.themeMode.index);
    } catch (e) {
      // Handle error
    }
  }
}
