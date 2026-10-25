import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/features/onboarding/view/landlord_login_view.dart';
import 'package:saferenthouse/features/onboarding/view/landlord_register_view.dart';
import 'package:saferenthouse/features/onboarding/view/tenant_login_view.dart';
import 'package:saferenthouse/features/onboarding/view/tenant_register_view.dart';
import 'package:saferenthouse/features/onboarding/view/welcome_role_view.dart';

void main() {
  group('WelcomeRoleView & Auth Views Tests (Sümeyye)', () {
    testWidgets('WelcomeRoleView displays logo, title, and two role buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeRoleView(onAuthenticated: (role, name) {}),
        ),
      );
      await tester.pump();

      expect(find.text('SafeRentHouse'), findsWidgets);
      expect(find.text('Kriptografik Güvenlikli Çevrimdışı Kira Kasası'), findsOneWidget);
      expect(find.text('Kiracı Girişi'), findsOneWidget);
      expect(find.text('Kiraya Veren Girişi'), findsOneWidget);
      expect(find.text('Aydınlatma & KVKK Metnini İncele'), findsOneWidget);
    });

    testWidgets('TenantLoginView renders inputs and switches to register', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TenantLoginView(onAuthenticated: (role, name) {}),
        ),
      );
      await tester.pump();

      expect(find.text('Kiracı Portalı'), findsOneWidget);
      expect(find.text('Kiracı Modu'), findsOneWidget);
      expect(find.text('Kiracı Girişi Yap'), findsOneWidget);

      // Validate empty submit
      await tester.tap(find.text('Kiracı Girişi Yap'));
      await tester.pump();
      expect(find.text('Lütfen iletişim bilginizi girin'), findsOneWidget);

      // Tap switch to register
      await tester.tap(find.text('Hesap Açın'));
      await tester.pumpAndSettle();
      expect(find.text('Kiracı Hesabı Aç'), findsOneWidget);
      expect(find.text('Yeni Kiracı Profili'), findsOneWidget);
    });

    testWidgets('LandlordLoginView renders inputs and switches to register', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandlordLoginView(onAuthenticated: (role, name) {}),
        ),
      );
      await tester.pump();

      expect(find.text('Kiraya Veren Portalı'), findsOneWidget);
      expect(find.text('Kiraya Veren Modu'), findsOneWidget);
      expect(find.text('Kiraya Veren Girişi Yap'), findsOneWidget);

      // Tap switch to register
      await tester.tap(find.text('Hesap Açın'));
      await tester.pumpAndSettle();
      expect(find.text('Kiraya Veren Hesabı Aç'), findsOneWidget);
      expect(find.text('Mülk Sahibi Profili'), findsOneWidget);
    });

    testWidgets('TenantRegisterView validates PIN match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TenantRegisterView(onAuthenticated: (role, name) {}),
        ),
      );
      await tester.pump();

      // Enter name, email, mismatched PINs
      await tester.enterText(find.byType(TextFormField).at(0), 'Ali Veli');
      await tester.enterText(find.byType(TextFormField).at(1), 'ali@test.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234');
      await tester.enterText(find.byType(TextFormField).at(4), '9999');

      final submitBtn = find.text('Kiracı Hesabını Başlat');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('PIN kodları birbiriyle eşleşmiyor.'), findsOneWidget);
    });

    testWidgets('LandlordRegisterView renders all inputs and can switch back to login', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandlordRegisterView(onAuthenticated: (role, name) {}),
        ),
      );
      await tester.pump();

      expect(find.text('Ev Sahibi Hesabını Başlat'), findsOneWidget);
      expect(find.text('Zaten bir ev sahibi hesabınız var mı?'), findsOneWidget);

      final loginLink = find.text('Giriş Yapın');
      await tester.ensureVisible(loginLink);
      await tester.tap(loginLink);
      await tester.pumpAndSettle();
      expect(find.text('Kiraya Veren Portalı'), findsOneWidget);
    });

    testWidgets('TenantLoginView calls onAuthenticated and pops to root', (WidgetTester tester) async {
      bool authenticated = false;
      String authRole = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => TenantLoginView(
                        onAuthenticated: (role, name) {
                          authenticated = true;
                          authRole = role;
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Ana Ekran'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Ana Ekran'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'ornek@posta.com');
      await tester.enterText(find.byType(TextFormField).at(1), '1234');
      await tester.tap(find.text('Kiracı Girişi Yap'));
      await tester.pumpAndSettle();

      expect(authenticated, isTrue);
      expect(authRole, 'tenant');
      expect(find.text('Ana Ekran'), findsOneWidget);
    });
  });
}
