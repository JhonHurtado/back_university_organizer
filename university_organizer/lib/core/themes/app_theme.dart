import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      surfaceContainerHighest: AppColors.muted,
      outline: AppColors.border,
    ),

    // Text theme
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppDimensions.fontXxl,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: AppDimensions.fontXl,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: AppDimensions.fontLg,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: AppDimensions.fontLg,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        titleLarge: TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        titleMedium: TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.normal,
          color: AppColors.foreground,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.fontSm,
          fontWeight: FontWeight.normal,
          color: AppColors.foreground,
        ),
        bodySmall: TextStyle(
          fontSize: AppDimensions.fontXs,
          fontWeight: FontWeight.normal,
          color: AppColors.mutedForeground,
        ),
        labelLarge: TextStyle(
          fontSize: AppDimensions.fontSm,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.foreground),
      titleTextStyle: TextStyle(
        fontSize: AppDimensions.fontLg,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
        textStyle: const TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.foreground,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.input,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: const BorderSide(color: AppColors.ring, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: const BorderSide(color: AppColors.destructive),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: const BorderSide(color: AppColors.destructive, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingMd,
      ),
      hintStyle: const TextStyle(color: AppColors.mutedForeground),
      labelStyle: const TextStyle(color: AppColors.foreground),
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: AppColors.foreground,
      size: AppDimensions.iconMd,
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.mutedForeground,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
