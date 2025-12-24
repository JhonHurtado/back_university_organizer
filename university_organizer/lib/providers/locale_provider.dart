import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app locale (language)
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('en', '');
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  /// Get current language code
  String get languageCode => _locale.languageCode;

  /// Get current language name
  String get languageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  /// Initialize locale from stored preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLocale = prefs.getString(_localeKey);

      if (storedLocale != null) {
        _locale = Locale(storedLocale, '');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing locale: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set locale and persist to storage
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Toggle between English and Spanish
  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'en'
        ? const Locale('es', '')
        : const Locale('en', '');
    await setLocale(newLocale);
  }

  /// Set locale by language code
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode, ''));
  }
}
