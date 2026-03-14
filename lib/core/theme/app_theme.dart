import 'package:flutter/material.dart';

/// Tide-inspired palette. No glassmorphism — frosted, muted, organic.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFA8AFA2);
  static const Color surface = Color(0xFFF5F0E4);
  static const Color accent = Color(0xFF8FA5BA);
  static const Color textPrimary = Color(0xFF242018);

  // Glass tokens
  static final Color glassFill12 = Colors.white.withValues(alpha: 0.12);
  static final Color glassFill20 = Colors.white.withValues(alpha: 0.20);
  static final Color glassFill13 = Colors.white.withValues(alpha: 0.13);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.20);

  // Overlay tokens (time-aware)
  static final Color overlayMorning = Colors.black.withValues(alpha: 0.15);
  static final Color overlayDay = Colors.black.withValues(alpha: 0.22);
  static final Color overlayEvening = Colors.black.withValues(alpha: 0.33);
  static final Color overlayNight = Colors.black.withValues(alpha: 0.45);

  static Color overlayForHour(int hour) {
    if (hour >= 22 || hour < 6) return overlayNight;
    if (hour >= 18) return overlayEvening;
    if (hour >= 11) return overlayDay;
    return overlayMorning;
  }

  // Text colors on glass
  static final Color textOnGlassPrimary = Colors.white.withValues(alpha: 0.95);
  static final Color textOnGlassMuted = Colors.white.withValues(alpha: 0.55);
  static final Color textOnGlassHint = Colors.white.withValues(alpha: 0.35);

  /// Muted text
  static Color textMuted(Color base) => base.withValues(alpha: 0.6);

  /// "An" card — time-based tints (no hard shadows, subtle elevation)
  /// Sabah soğuk beyaz, öğleden sonra nötr, akşam warm krem, gece koyu
  static Color anCardTintForHour(int hour) {
    if (hour >= 21 || hour < 7) {
      return const Color(0xFFE8E2D8);
    }
    if (hour >= 17 && hour < 21) {
      return const Color(0xFFF5EDE0);
    }
    if (hour >= 12 && hour < 17) {
      return const Color(0xFFF8F4EC);
    }
    return const Color(0xFFFBF9F4);
  }
}

/// Time-of-day greeting for "An" card
String greetingForHour(int hour) {
  if (hour >= 7 && hour < 12) return 'Günaydın.';
  if (hour >= 12 && hour < 17) return 'İyi öğleden sonralar.';
  if (hour >= 17 && hour < 21) return 'Akşam oldu.';
  return 'Gece sessizliği.';
}
