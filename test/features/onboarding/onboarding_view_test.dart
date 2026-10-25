import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/features/onboarding/view/onboarding_view.dart';
import 'package:saferenthouse/features/onboarding/widget/onboarding_header.dart';
import 'package:saferenthouse/features/onboarding/widget/onboarding_hero_graphic.dart';
import 'package:saferenthouse/features/onboarding/widget/onboarding_mini_feature_cards.dart';
import 'package:saferenthouse/features/onboarding/widget/onboarding_principles_section.dart';

void main() {
  group('OnboardingView Widget Tests (Sümeyye - T04 - Stitch UI)', () {
    testWidgets('Renders all core Stitch UI components and principles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingView(
            onCompleted: () {},
          ),
        ),
      );

      // Header & hero checks
      expect(find.byType(OnboardingHeader), findsOneWidget);
      expect(find.text('eIDAS & HMK Uyumlu'), findsOneWidget);
      expect(find.byType(OnboardingHeroGraphic), findsOneWidget);
      expect(find.text('Müdahale Edilemez Kira Güvencesi'), findsOneWidget);
      expect(find.text('Adli Düzeyde Denetim İzi'), findsOneWidget);

      // Principles checks
      expect(find.byType(OnboardingPrinciplesSection), findsOneWidget);
      expect(find.text('100% Yerel ve Gizli Depolama'), findsOneWidget);
      expect(find.text('SHA-256 Kriptografik Özet Zinciri'), findsOneWidget);
      expect(find.text('Cihaz Saati & Konum Damgası'), findsOneWidget);
      expect(find.text('MAHKEME VE ARABULUCULUK GEÇERLİLİĞİ'), findsOneWidget);

      // Mini cards checks
      expect(find.byType(OnboardingMiniFeatureCards), findsOneWidget);
      expect(find.text('AES-256'), findsOneWidget);
      expect(find.text('Sıfır Telemetri'), findsOneWidget);
      expect(find.text('Bağımsız'), findsOneWidget);
    });

    testWidgets(
        'Initial state has disabled continue button until consent checkbox is checked',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingView(
            onCompleted: () => completed = true,
          ),
        ),
      );

      // Checkbox should initially be unchecked
      final Checkbox checkboxBefore = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkboxBefore.value, isFalse);

      // Continue button should be disabled
      final ElevatedButton continueButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Şartları Kabul Et ve Devam Et'),
      );
      expect(continueButton.onPressed, isNull);

      // Tap consent checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Checkbox is now checked
      final Checkbox checkboxAfter = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkboxAfter.value, isTrue);

      // Continue button is now enabled
      final ElevatedButton enabledButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Şartları Kabul Et ve Devam Et'),
      );
      expect(enabledButton.onPressed, isNotNull);

      // Tap continue button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Şartları Kabul Et ve Devam Et'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets(
        'Tapping policy link opens security protocol bottom sheet and accepting checks consent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingView(
            onCompleted: () {},
          ),
        ),
      );

      // Tap the policy link
      await tester.tap(find.text('Delil Güvenlik Protokolü & Gizlilik Politikasını Oku'));
      await tester.pumpAndSettle();

      // Modal content is visible
      expect(find.text('Güvenlik Protokolü & Aydınlatma'), findsOneWidget);
      expect(find.text('1. Zaman Damgası & Cihaz Saati Sınırları'), findsOneWidget);
      expect(find.text('2. Delil Niteliği ve HMK Uyum Kapsamı'), findsOneWidget);

      // Confirm from modal
      await tester.tap(find.text('Okudum, Anladım ve Kabul Ediyorum'));
      await tester.pumpAndSettle();

      // Modal closed and consent is automatically checked
      final Checkbox checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });
  });
}
