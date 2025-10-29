import 'package:flutter/material.dart';

class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFF007AFF); // Azul iOS
  static const Color secondary = Color(0xFFFF9500); // Naranja

  // Fondos
  static const Color background = Color(0xFFFFFFFF); // Blanco
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Gris claro
  static const Color cardBackground = Color(0xFFFAFAFA);

  // Textos
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Bordes
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Estados
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Sombras
  static Color shadow = Colors.black.withValues( alpha: 0.05);
  static Color shadowMedium = Colors.black.withValues( alpha: 0.1);
}
