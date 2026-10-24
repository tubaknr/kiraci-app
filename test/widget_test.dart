import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Uygulama baslangic widget testi', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeRentHouseApp());
    await tester.pump();
    expect(find.text('Dosyalarım'), findsWidgets);
  });
}
