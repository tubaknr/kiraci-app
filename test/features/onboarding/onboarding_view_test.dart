import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/features/onboarding/view/onboarding_view.dart';

void main() {
  group('OnboardingView Widget Tests (Sümeyye - T04)', () {
    testWidgets('Initial state has disabled continue button until consent is checked',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingView(
            onCompleted: () => completed = true,
          ),
        ),
      );

      // Verify slides content
      expect(find.text('Çevrimdışı & Yerel Depolama'), findsOneWidget);
      expect(find.text('KVKK aydınlatma metnini, cihaz saati sınırlamalarını ve kullanım koşullarını okudum, anladım.'), findsOneWidget);

      // Button should be disabled initially
      final ElevatedButton startButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Uygulamaya Başla'),
      );
      expect(startButton.onPressed, isNull);

      // Tap consent checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Button should now be enabled
      final ElevatedButton enabledButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Uygulamaya Başla'),
      );
      expect(enabledButton.onPressed, isNotNull);

      // Tap start button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Uygulamaya Başla'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('Tapping Oku opens KVKK bottom sheet with legal disclaimer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingView(
            onCompleted: () {},
          ),
        ),
      );

      await tester.tap(find.text('Oku'));
      await tester.pumpAndSettle();

      expect(find.text('Aydınlatma & Dürüst Sınırlar'), findsOneWidget);
      expect(find.text('1. Zaman Damgası Güvenilirliği'), findsOneWidget);
      expect(find.text('2. Delil Niteliği ve Hukuki Danışmanlık'), findsOneWidget);

      // Scroll to Anladım ve Onaylıyorum button and tap
      await tester.scrollUntilVisible(
        find.text('Anladım ve Onaylıyorum'),
        100.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Anladım ve Onaylıyorum'));
      await tester.pumpAndSettle();

      // Modal closed and consent checked
      final Checkbox checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });
  });
}
