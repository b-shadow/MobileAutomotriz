import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Application typography using Google Fonts (Inter family).
class AppTypography {
  AppTypography._();

  // ── Base Text Theme ──────────────────────────────────────

  static TextTheme get _baseTextTheme => GoogleFonts.interTextTheme();

  // ── Dark Text Theme ──────────────────────────────────────

  static TextTheme get darkTextTheme => _baseTextTheme.copyWith(
        displayLarge: _baseTextTheme.displayLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: _baseTextTheme.displayMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: _baseTextTheme.displaySmall?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: _baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: _baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: _baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: _baseTextTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: _baseTextTheme.titleMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: _baseTextTheme.titleSmall?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        bodySmall: _baseTextTheme.bodySmall?.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelLarge: _baseTextTheme.labelLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: _baseTextTheme.labelMedium?.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        labelSmall: _baseTextTheme.labelSmall?.copyWith(
          color: AppColors.darkTextTertiary,
        ),
      );

  // ── Light Text Theme ─────────────────────────────────────

  static TextTheme get lightTextTheme => _baseTextTheme.copyWith(
        displayLarge: _baseTextTheme.displayLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: _baseTextTheme.displayMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: _baseTextTheme.displaySmall?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: _baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: _baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: _baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: _baseTextTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: _baseTextTheme.titleMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: _baseTextTheme.titleSmall?.copyWith(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        bodySmall: _baseTextTheme.bodySmall?.copyWith(
          color: AppColors.lightTextTertiary,
        ),
        labelLarge: _baseTextTheme.labelLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: _baseTextTheme.labelMedium?.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        labelSmall: _baseTextTheme.labelSmall?.copyWith(
          color: AppColors.lightTextTertiary,
        ),
      );
}
