import 'package:flutter/material.dart';

/// Application color palette
/// Based on a modern, academic-focused design system
class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================

  /// Primary Blue - Main brand color
  static const Color primary = Color.fromARGB(255, 42, 72, 138);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color.fromARGB(255, 100, 126, 209);
  static const Color primaryLighter = Color(0xFF60A5FA);
  static const Color primaryDarker = Color(0xFF1E3A8A);

  /// Secondary Purple - Accent brand color
  static const Color secondary = Color.fromARGB(255, 83, 57, 124);
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFF6D28D9);
  static const Color secondaryLighter = Color(0xFFA78BFA);
  static const Color secondaryDarker = Color(0xFF5B21B6);

  // ==================== SEMANTIC COLORS ====================

  /// Success - Green tones
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  /// Error - Red tones
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  /// Warning - Amber/Orange tones
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  /// Info - Blue tones
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ==================== GRADE COLORS ====================

  /// Grade color scale
  static const Color gradeExcellent = Color(0xFF10B981); // 85-100%
  static const Color gradeGood = Color(0xFF3B82F6);      // 70-84%
  static const Color gradeAverage = Color(0xFFF59E0B);   // 60-69%
  static const Color gradePoor = Color(0xFFEF4444);      // <60%
  static const Color gradeNone = Color(0xFF9CA3AF);      // No grade

  // ==================== STATUS COLORS ====================

  static const Color statusActive = Color(0xFF10B981);
  static const Color statusInactive = Color(0xFF6B7280);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusCompleted = Color(0xFF3B82F6);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusPaused = Color(0xFF8B5CF6);

  // ==================== SUBJECT TYPE COLORS ====================

  static const Color subjectRequired = Color(0xFF2563EB);
  static const Color subjectElective = Color(0xFF7C3AED);
  static const Color subjectFreeElective = Color(0xFF10B981);
  static const Color subjectComplementary = Color(0xFFF59E0B);

  // ==================== BACKGROUND COLORS ====================

  // Light theme backgrounds
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Dark theme backgrounds
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  static const Color cardDark = Color(0xFF1F2937);

  // ==================== TEXT COLORS ====================

  // Light theme text
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color textDisabledLight = Color(0xFFD1D5DB);

  // Dark theme text
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color textDisabledDark = Color(0xFF4B5563);

  // ==================== BORDER COLORS ====================

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);

  // ==================== OVERLAY COLORS ====================

  static const Color overlayLight = Color(0x1F000000);
  static const Color overlayDark = Color(0x3FFFFFFF);
  static const Color scrimLight = Color(0x99000000);
  static const Color scrimDark = Color(0x99000000);

  // ==================== GRADIENTS ====================

  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [successLight, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Premium gradient
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Academic gradient (for hero sections)
  static const LinearGradient academicGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== SHADOW COLORS ====================

  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x3F000000);

  // ==================== UTILITY METHODS ====================

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
