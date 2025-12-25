import 'package:flutter_test/flutter_test.dart';
import 'package:university_organizer/providers/theme_provider.dart';
import 'package:university_organizer/providers/career_provider.dart';
import 'package:university_organizer/services/career_service.dart';
import 'package:university_organizer/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock SharedPreferences for all tests
  SharedPreferences.setMockInitialValues({});

  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('Initial theme mode should be system', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('Toggle theme should switch between light and dark', () async {
      // Set to light first
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);

      // Toggle to dark
      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);

      // Toggle back to light
      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);
    });

    test('isDarkMode should reflect current theme', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);

      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.isDarkMode, false);
    });
  });

  group('CareerProvider Tests', () {
    late CareerProvider careerProvider;
    late CareerService careerService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
      careerService = CareerService(apiClient);
      careerProvider = CareerProvider(careerService);
    });

    test('Initial state should be empty', () {
      expect(careerProvider.careers, isEmpty);
      expect(careerProvider.isLoading, false);
      expect(careerProvider.error, null);
      expect(careerProvider.hasCareers, false);
    });

    test('Should have correct initial getters', () {
      expect(careerProvider.activeCareers, isEmpty);
      expect(careerProvider.completedCareers, isEmpty);
      expect(careerProvider.activeCareersCount, 0);
      expect(careerProvider.selectedCareer, null);
    });

    test('Clear error should reset error state', () {
      careerProvider.clearError();
      expect(careerProvider.error, null);
    });
  });

  group('Integration Tests', () {
    test('ThemeProvider should persist theme changes', () async {
      // Reset mock to empty state
      SharedPreferences.setMockInitialValues({});

      final provider = ThemeProvider();
      await provider.initialize();

      // Change theme
      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);

      // Get the current SharedPreferences instance to verify data is saved
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      expect(savedTheme, 'ThemeMode.dark');

      // Create new instance and initialize (simulating app restart)
      // The mock SharedPreferences will maintain the saved value
      final provider2 = ThemeProvider();
      await provider2.initialize();

      // Should load the saved theme
      expect(provider2.themeMode, ThemeMode.dark);
    });
  });
}
