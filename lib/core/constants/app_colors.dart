import 'package:flutter/material.dart';

/// SafeRentHouse renk paleti (Sümeyye - T02)
class AppColors {
  const AppColors._();

  // Ana & Vurgulu Renkler
  static const Color primary = Color(0xFF1E3A8A); // Güven veren koyu lacivert
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF0D9488); // Bütünlük & teyit yeşili
  static const Color secondaryLight = Color(0xFF14B8A6);

  // Doğrulama & Durum Renkleri
  static const Color success = Color(0xFF10B981); // Bozulmamış delil zinciri
  static const Color warning = Color(0xFFF59E0B); // Saat anomalisi / Dikkat
  static const Color error = Color(0xFFEF4444); // Bozuk zincir / Değiştirilmiş kayıt
  static const Color info = Color(0xFF3B82F6);

  // Açık Tema Yüzey & Zemin
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextHint = Color(0xFF94A3B8);

  // Koyu Tema Yüzey & Zemin
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextHint = Color(0xFF64748B);

  // Rozet ve Kart Arka Plan Renkleri (Stitch Tasarım Sistemi)
  static const Color badgeGreenBg = Color(0xFFDCFCE7);
  static const Color badgeGreenText = Color(0xFF15803D);
  static const Color badgeBlueBg = Color(0xFFEFF6FF);
  static const Color badgeBlueText = Color(0xFF1E40AF);
  static const Color badgeAmberBg = Color(0xFFFEF3C7);
  static const Color badgeAmberText = Color(0xFFB45309);
  static const Color badgeIndigoBg = Color(0xFFEEF2FF);
  static const Color badgeIndigoText = Color(0xFF4338CA);

  // Geriye dönük uyumluluk için genel aliaslar
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color textPrimary = lightTextPrimary;

  // Tema Duyarlı Renk Yardımcıları (SOLID & Açık/Koyu Tema Uyumu)
  static Color cardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }

  static Color borderCol(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }

  static Color textMain(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  static Color textMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color badgeBg(BuildContext context, Color lightBg, Color darkBg) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBg
        : lightBg;
  }
}
