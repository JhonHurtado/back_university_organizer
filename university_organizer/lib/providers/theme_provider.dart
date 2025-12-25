import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // When using system theme, check actual brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Initialize theme from stored preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedTheme = prefs.getString(_themeKey);

      if (storedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == storedTheme,
          orElse: () => ThemeMode.system,
        );
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing theme: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    // Si está en dark o system con dark, cambia a light
    // Si está en light o system con light, cambia a dark
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
