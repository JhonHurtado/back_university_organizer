import 'package:flutter/material.dart';

/// Paleta de colores profesional para la aplicación
/// Tonos sutiles y elegantes sin colores neón
class AppColors {
  AppColors._();

  // Colores de fondo
  static const Color background = Color(0xFF0A0E27); // Azul oscuro profundo
  static const Color card = Color(0xFF16213E); // Azul marino oscuro
  static const Color popover = Color(0xFF16213E);

  // Colores de texto
  static const Color foreground = Color(0xFFF5F5F5); // Blanco suave
  static const Color cardForeground = Color(0xFFF5F5F5);
  static const Color popoverForeground = Color(0xFFF5F5F5);

  // Colores primarios (Azul profesional)
  static const Color primary = Color(0xFF4A7C96); // Azul acero suave
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // Colores secundarios
  static const Color secondary = Color(0xFF1F2937); // Gris azulado oscuro
  static const Color secondaryForeground = Color(0xFFE5E7EB);

  // Colores apagados
  static const Color muted = Color(0xFF374151); // Gris medio
  static const Color mutedForeground = Color(0xFF9CA3AF); // Gris claro

  // Colores de acento
  static const Color accent = Color(0xFF5B8BA8); // Azul acento suave
  static const Color accentForeground = Color(0xFFFFFFFF);

  // Colores de estado
  static const Color destructive = Color(0xFFDC2626); // Rojo profesional
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF059669); // Verde esmeralda profesional
  static const Color warning = Color(0xFFD97706); // Ámbar profesional
  static const Color info = Color(0xFF3B82F6); // Azul información

  // Bordes y campos de entrada
  static const Color border = Color(0xFF374151); // Gris oscuro
  static const Color input = Color(0xFF1F2937);
  static const Color ring = Color(0xFF4A7C96);

  // Colores para gráficos (tonos profesionales)
  static const Color chart1 = Color(0xFF4A7C96); // Azul acero
  static const Color chart2 = Color(0xFF7C3AED); // Púrpura profesional
  static const Color chart3 = Color(0xFFD97706); // Ámbar
  static const Color chart4 = Color(0xFF059669); // Verde
  static const Color chart5 = Color(0xFFDC2626); // Rojo

  // Colores de sidebar
  static const Color sidebar = Color(0xFF16213E);
  static const Color sidebarForeground = Color(0xFFF5F5F5);
  static const Color sidebarPrimary = Color(0xFF4A7C96);
  static const Color sidebarPrimaryForeground = Color(0xFFFFFFFF);
  static const Color sidebarAccent = Color(0xFF1F2937);
  static const Color sidebarAccentForeground = Color(0xFFF5F5F5);
  static const Color sidebarBorder = Color(0xFF374151);
  static const Color sidebarRing = Color(0xFF4A7C96);

  // Gradientes sutiles
  static const List<Color> primaryGradient = [
    Color(0xFF4A7C96),
    Color(0xFF5B8BA8),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF5B8BA8),
    Color(0xFF7C3AED),
  ];
}
