import 'package:flutter/material.dart';

/// Application color palette
/// Supports both dark and light themes with excellent contrast
class AppColors {
  AppColors._();

  // ==================== DARK THEME COLORS ====================

  /// Dark theme - Primary colors
  static const Color darkPrimary = Color(0xFF3AB896); // Teal/cyan suave (no neon)
  static const Color darkPrimaryLight = Color(0xFF4DD4AC);
  static const Color darkPrimaryDark = Color(0xFF2A9D7F);

  /// Dark theme - Secondary colors
  static const Color darkSecondary = Color(0xFF6B7FDB); // Blue/purple
  static const Color darkSecondaryLight = Color(0xFF8694E3);
  static const Color darkSecondaryDark = Color(0xFF5569D3);

  /// Dark theme - Background colors
  static const Color darkBackground = Color(0xFF0B0B0F); // Casi negro
  static const Color darkSurface = Color(0xFF16161D);     // Cards
  static const Color darkSurfaceVariant = Color(0xFF1E1E28); // Inputs
  static const Color darkSurfaceContainer = Color(0xFF252531); // Containers

  /// Dark theme - Text colors (EXCELLENT CONTRAST)
  static const Color darkTextPrimary = Color(0xFFFAFAFA);   // Casi blanco
  static const Color darkTextSecondary = Color(0xFFB8B8BE); // Gris claro
  static const Color darkTextTertiary = Color(0xFF7F7F8C);  // Gris medio
  static const Color darkTextDisabled = Color(0xFF4B4B58);  // Gris oscuro

  /// Dark theme - Border colors
  static const Color darkBorder = Color(0xFF2A2A35);
  static const Color darkDivider = Color(0xFF1F1F2A);

  // ==================== LIGHT THEME COLORS ====================

  /// Light theme - Primary colors
  static const Color lightPrimary = Color(0xFF2A9D7F); // Más oscuro para light mode
  static const Color lightPrimaryLight = Color(0xFF3AB896);
  static const Color lightPrimaryDark = Color(0xFF1F7A61);

  /// Light theme - Secondary colors
  static const Color lightSecondary = Color(0xFF5569D3);
  static const Color lightSecondaryLight = Color(0xFF6B7FDB);
  static const Color lightSecondaryDark = Color(0xFF3F54CB);

  /// Light theme - Background colors
  static const Color lightBackground = Color(0xFFF8F9FA); // Gris muy claro
  static const Color lightSurface = Color(0xFFFFFFFF);     // Blanco
  static const Color lightSurfaceVariant = Color(0xFFF1F3F5); // Inputs
  static const Color lightSurfaceContainer = Color(0xFFE9ECEF); // Containers

  /// Light theme - Text colors (EXCELLENT CONTRAST)
  static const Color lightTextPrimary = Color(0xFF1A1A1F);   // Casi negro
  static const Color lightTextSecondary = Color(0xFF4B4B58); // Gris oscuro
  static const Color lightTextTertiary = Color(0xFF7F7F8C);  // Gris medio
  static const Color lightTextDisabled = Color(0xFFB8B8BE);  // Gris claro

  /// Light theme - Border colors
  static const Color lightBorder = Color(0xFFDEE2E6);
  static const Color lightDivider = Color(0xFFE9ECEF);

  // ==================== SEMANTIC COLORS (Same for both themes) ====================

  /// Success colors
  static const Color success = Color(0xFF3AB896);
  static const Color successLight = Color(0xFF4DD4AC);
  static const Color successDark = Color(0xFF2A9D7F);
  static const Color successContainer = Color(0xFF1F7A61);

  /// Error colors
  static const Color error = Color(0xFFE57373);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFC62828);

  /// Warning colors
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningLight = Color(0xFFFFCC80);
  static const Color warningDark = Color(0xFFFFA726);
  static const Color warningContainer = Color(0xFFF57C00);

  /// Info colors
  static const Color info = Color(0xFF6B7FDB);
  static const Color infoLight = Color(0xFF8694E3);
  static const Color infoDark = Color(0xFF5569D3);
  static const Color infoContainer = Color(0xFF3F54CB);

  // ==================== GRADE COLORS ====================

  static const Color gradeExcellent = Color(0xFF3AB896); // 85-100%
  static const Color gradeGood = Color(0xFF6B7FDB);      // 70-84%
  static const Color gradeAverage = Color(0xFFFFB74D);   // 60-69%
  static const Color gradePoor = Color(0xFFE57373);      // <60%
  static const Color gradeNone = Color(0xFF7F7F8C);      // No grade

  // ==================== STATUS COLORS ====================

  static const Color statusActive = Color(0xFF3AB896);
  static const Color statusInactive = Color(0xFF7F7F8C);
  static const Color statusPending = Color(0xFFFFB74D);
  static const Color statusCompleted = Color(0xFF6B7FDB);
  static const Color statusCancelled = Color(0xFFE57373);
  static const Color statusPaused = Color(0xFF9575CD);

  // ==================== SUBJECT TYPE COLORS ====================

  static const Color subjectRequired = Color(0xFF6B7FDB);
  static const Color subjectElective = Color(0xFF9575CD);
  static const Color subjectFreeElective = Color(0xFF3AB896);
  static const Color subjectComplementary = Color(0xFFFFB74D);

  // ==================== GRADIENTS ====================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3AB896), Color(0xFF2A9D7F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF6B7FDB), Color(0xFF5569D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4DD4AC), Color(0xFF3AB896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E1E28), Color(0xFF16161D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Academic gradient (Cyan to Purple) - for backward compatibility
  static const LinearGradient academicGradient = LinearGradient(
    colors: [Color(0xFF3AB896), Color(0xFF6B7FDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Premium gradient - for backward compatibility
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFE57373)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== BACKWARD COMPATIBILITY ====================

  /// Legacy color names (for backward compatibility - use dark theme colors by default)
  static const Color primary = darkPrimary;
  static const Color primaryLight = darkPrimaryLight;
  static const Color primaryDark = darkPrimaryDark;
  static const Color secondary = darkSecondary;
  static const Color secondaryLight = darkSecondaryLight;
  static const Color secondaryDark = darkSecondaryDark;
  static const Color backgroundLight = lightBackground;
  static const Color surfaceLight = lightSurface;
  static const Color surfaceVariantLight = lightSurfaceVariant;
  static const Color cardLight = lightSurface;
  static const Color backgroundDarkLegacy = darkBackground;
  static const Color surfaceDarkLegacy = darkSurface;
  static const Color surfaceVariantDarkLegacy = darkSurfaceVariant;
  static const Color cardDark = darkSurface;
  static const Color textPrimaryLight = lightTextPrimary;
  static const Color textSecondaryLight = lightTextSecondary;
  static const Color textTertiaryLight = lightTextTertiary;
  static const Color textDisabledLight = lightTextDisabled;
  static const Color textPrimaryDark = darkTextPrimary;
  static const Color textSecondaryDark = darkTextSecondary;
  static const Color textTertiaryDark = darkTextTertiary;
  static const Color textDisabledDark = darkTextDisabled;
  static const Color borderLight = lightBorder;
  static const Color borderDark = darkBorder;
  static const Color dividerLight = lightDivider;
  static const Color dividerDark = darkDivider;

  // ==================== UTILITY METHODS ====================

  /// Get theme-specific colors
  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color getSurface(bool isDark) =>
      isDark ? darkSurface : lightSurface;

  static Color getSurfaceVariant(bool isDark) =>
      isDark ? darkSurfaceVariant : lightSurfaceVariant;

  static Color getPrimary(bool isDark) =>
      isDark ? darkPrimary : lightPrimary;

  static Color getTextPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;

  static Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color getBorder(bool isDark) =>
      isDark ? darkBorder : lightBorder;

  /// Get grade color based on percentage
  static Color getGradeColor(double percentage) {
    if (percentage >= 85) return gradeExcellent;
    if (percentage >= 70) return gradeGood;
    if (percentage >= 60) return gradeAverage;
    return gradePoor;
  }

  /// Get grade color based on value and max
  static Color getGradeColorFromValue(double grade, double maxGrade) {
    final percentage = (grade / maxGrade) * 100;
    return getGradeColor(percentage);
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'ENROLLED':
        return statusActive;
      case 'COMPLETED':
      case 'PASSED':
        return statusCompleted;
      case 'PENDING':
      case 'IN_PROGRESS':
        return statusPending;
      case 'CANCELLED':
      case 'FAILED':
      case 'WITHDRAWN':
        return statusCancelled;
      case 'PAUSED':
        return statusPaused;
      default:
        return statusInactive;
    }
  }

  /// Get subject type color
  static Color getSubjectTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'REQUIRED':
        return subjectRequired;
      case 'ELECTIVE':
        return subjectElective;
      case 'FREE_ELECTIVE':
        return subjectFreeElective;
      case 'COMPLEMENTARY':
        return subjectComplementary;
      default:
        return subjectRequired;
    }
  }

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Lighten a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
