import 'package:flutter/material.dart';

/// Manages generic user interface states that apply across the application.
/// 
/// This includes theme management (light/dark mode) and global loading/error states.
class UIProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = false;
  String? _error;

  /// The current theme mode of the application.
  ThemeMode get themeMode => _themeMode;

  /// Global loading state indicator.
  bool get isLoading => _isLoading;

  /// Global error message, if any.
  String? get error => _error;

  /// Toggles between light and dark theme modes.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Explicitly sets the global loading state.
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

