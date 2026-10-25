import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Uygulama baslangic widget testi - Karsilama ve Rol Girisi', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeRentHouseApp(initialAuthenticated: false));
    await tester.pump();
    expect(find.text('SafeRentHouse'), findsWidgets);
    expect(find.text('Kiracı Girişi'), findsOneWidget);
    expect(find.text('Kiraya Veren Girişi'), findsOneWidget);
  });

  testWidgets('Uygulama baslangic widget testi - Kimlik Dogrulanmis Ana Ekran', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeRentHouseApp(initialAuthenticated: true));
    await tester.pump();
    expect(find.text('Dosyalarım'), findsWidgets);
  });
}
