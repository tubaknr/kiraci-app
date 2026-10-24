import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/services/lock_service.dart';
import 'package:saferenthouse/features/lock/controller/lock_controller.dart';
import 'package:saferenthouse/features/lock/view/lock_view.dart';
import 'package:saferenthouse/features/settings/view/settings_view.dart';

void main() {
  group('SettingsView & LockView Tests (Sümeyye - T23)', () {
    late Directory tempDir;
    late LockService lockService;
    late LockController lockController;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('lock_view_test_');
      lockService = LockService(
        getAppDocDir: () async => tempDir,
      );
      lockController = LockController(lockService);
    });

    tearDown(() async {
      lockController.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets('SettingsView renders theme, lock, backup, and disclaimer cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsView(lockController: lockController),
        ),
      );
      await tester.pump();

      expect(find.text('Ayarlar & Güvenlik'), findsOneWidget);
      expect(find.text('Görünüm Teması'), findsOneWidget);
      expect(find.text('Uygulama Kilidi & PIN'), findsOneWidget);
      expect(find.text('Düzenli Yedek Hatırlatması'), findsOneWidget);
      expect(find.text('Dürüst Sınırlar & Güvenlik Politikası'), findsOneWidget);
    });

    testWidgets('LockView prompts for PIN and triggers unlock on correct PIN',
        (WidgetTester tester) async {
      await lockController.setupLock(pin: '1234');
      bool unlockedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LockView(
            controller: lockController,
            onUnlocked: () => unlockedCalled = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('SafeRentHouse Kilitli'), findsOneWidget);
      expect(find.text('Kilidi Aç'), findsOneWidget);

      // Enter wrong pin
      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Kilidi Aç'));
      await tester.pump();

      expect(find.text('Hatalı PIN kodu girdiniz.'), findsOneWidget);
      expect(unlockedCalled, isFalse);

      // Enter correct pin
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Kilidi Aç'));
      await tester.pump();

      expect(unlockedCalled, isTrue);
    });
  });
}
