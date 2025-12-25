import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Application theme configuration
/// Supports both dark and light themes with excellent readability
class AppTheme {
  AppTheme._();

  // ==================== DARK THEME ====================

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        primaryColor: AppColors.darkPrimary,
        secondaryColor: AppColors.darkSecondary,
        backgroundColor: AppColors.darkBackground,
        surfaceColor: AppColors.darkSurface,
        surfaceVariantColor: AppColors.darkSurfaceVariant,
        textPrimaryColor: AppColors.darkTextPrimary,
        textSecondaryColor: AppColors.darkTextSecondary,
        textTertiaryColor: AppColors.darkTextTertiary,
        borderColor: AppColors.darkBorder,
        dividerColor: AppColors.darkDivider,
      );

  // ==================== LIGHT THEME ====================

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        primaryColor: AppColors.lightPrimary,
        secondaryColor: AppColors.lightSecondary,
        backgroundColor: AppColors.lightBackground,
        surfaceColor: AppColors.lightSurface,
        surfaceVariantColor: AppColors.lightSurfaceVariant,
        textPrimaryColor: AppColors.lightTextPrimary,
        textSecondaryColor: AppColors.lightTextSecondary,
        textTertiaryColor: AppColors.lightTextTertiary,
        borderColor: AppColors.lightBorder,
        dividerColor: AppColors.lightDivider,
      );

  // ==================== THEME BUILDER ====================

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color surfaceVariantColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color textTertiaryColor,
    required Color borderColor,
    required Color dividerColor,
  }) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isDark ? AppColors.darkBackground : Colors.white,
        primaryContainer: isDark ? AppColors.darkPrimaryDark : AppColors.lightPrimaryLight,
        onPrimaryContainer: textPrimaryColor,
        secondary: secondaryColor,
        onSecondary: isDark ? AppColors.darkBackground : Colors.white,
        secondaryContainer: isDark ? AppColors.darkSecondaryDark : AppColors.lightSecondaryLight,
        onSecondaryContainer: textPrimaryColor,
        tertiary: AppColors.success,
        onTertiary: isDark ? AppColors.darkBackground : Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
        surfaceContainerHighest: surfaceVariantColor,
        outline: borderColor,
        outlineVariant: dividerColor,
        shadow: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.2),
        scrim: Colors.black.withValues(alpha: 0.7),
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
        actionsIconTheme: IconThemeData(color: textPrimaryColor),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Navigation Bar (Bottom Nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryColor.withValues(alpha: 0.15),
        elevation: 0,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor, size: 24);
          }
          return IconThemeData(color: textSecondaryColor, size: 24);
        }),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1),
        ),
        labelStyle: TextStyle(color: textSecondaryColor, fontSize: 16),
        floatingLabelStyle: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: textTertiaryColor, fontSize: 16),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariantColor,
        selectedColor: primaryColor.withValues(alpha: 0.15),
        deleteIconColor: textSecondaryColor,
        labelStyle: TextStyle(color: textPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: textSecondaryColor,
          fontSize: 16,
          height: 1.5,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariantColor,
        contentTextStyle: TextStyle(color: textPrimaryColor, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceVariantColor,
        circularTrackColor: surfaceVariantColor,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: textSecondaryColor,
        textColor: textPrimaryColor,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: textSecondaryColor,
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return textSecondaryColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.5);
          }
          return surfaceVariantColor;
        }),
      ),

      // Text Theme
      textTheme: TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimaryColor,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
          height: 1.2,
          letterSpacing: -0.5,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.3,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondaryColor,
          height: 1.4,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiaryColor,
          height: 1.5,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondaryColor,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textTertiaryColor,
          height: 1.4,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: textSecondaryColor,
        size: 24,
      ),
    );
  }
}
