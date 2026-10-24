import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SafeRentHouseApp());
}

/// Uygulama ana widget'ı (Geçici Mock - Sümeyye T02'de güncelleyecek)
class SafeRentHouseApp extends StatelessWidget {
  const SafeRentHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRentHouse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('SafeRentHouse'),
        ),
      ),
    );
  }
}
