import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/app_colors.dart';
import 'package:saferenthouse/core/theme/app_theme.dart';

void main() {
  group('AppTheme Tests (Sümeyye T02)', () {
    test('Light theme properties are properly configured', () {
      final ThemeData lightTheme = AppTheme.lightTheme;
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.colorScheme.primary, AppColors.primary);
      expect(lightTheme.scaffoldBackgroundColor, AppColors.lightBackground);
    });

    test('Dark theme properties are properly configured', () {
      final ThemeData darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.colorScheme.primary, AppColors.primaryLight);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);
    });

    test('themeModeNotifier and toggleTheme work as expected', () {
      AppTheme.setThemeMode(ThemeMode.light);
      expect(AppTheme.themeModeNotifier.value, ThemeMode.light);

      AppTheme.toggleTheme();
      expect(AppTheme.themeModeNotifier.value, ThemeMode.dark);

      AppTheme.toggleTheme();
      expect(AppTheme.themeModeNotifier.value, ThemeMode.light);

      AppTheme.setThemeMode(ThemeMode.system);
      expect(AppTheme.themeModeNotifier.value, ThemeMode.system);
    });
  });
}
