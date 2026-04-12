import 'package:flutter/material.dart';

/// Curated, premium color palette for the application.
class AppColors {
  AppColors._();

  // ── Primary Palette ──────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF918AFF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // ── Accent ───────────────────────────────────────────────
  static const Color accent = Color(0xFF00D9FF);
  static const Color accentLight = Color(0xFF5CEBFF);
  static const Color accentDark = Color(0xFF00A8CC);

  // ── Gradient ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF9D4EDD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark Theme Surfaces ──────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252540);
  static const Color darkCard = Color(0xFF16213E);

  // ── Light Theme Surfaces ─────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F8);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ── Dark Theme Text ──────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF1F1F1);
  static const Color darkTextSecondary = Color(0xFFB0B0C0);
  static const Color darkTextTertiary = Color(0xFF6B6B80);

  // ── Light Theme Text ─────────────────────────────────────
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5A5A72);
  static const Color lightTextTertiary = Color(0xFF9090A8);

  // ── Status Colors ────────────────────────────────────────
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF448AFF);

  // ── Note Accent Colors ───────────────────────────────────
  static const List<Color> noteColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFF00D9FF), // Cyan
    Color(0xFFFF6B9D), // Pink
    Color(0xFF00C853), // Green
    Color(0xFFFFAB00), // Amber
    Color(0xFFFF5252), // Red
    Color(0xFF7C4DFF), // Deep Purple
    Color(0xFF00BFA5), // Teal
  ];

  /// Parse a hex color string (e.g. '#6C63FF') to a [Color].
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert a [Color] to a hex string.
  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}
