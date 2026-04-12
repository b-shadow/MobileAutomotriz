import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

/// Cubit for managing the app's theme mode (light/dark).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  /// Toggle between light and dark mode.
  void toggleTheme() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  /// Set a specific theme mode.
  void setTheme(ThemeMode mode) {
    emit(mode);
  }

  /// Whether the current theme is dark.
  bool get isDark => state == ThemeMode.dark;
}
