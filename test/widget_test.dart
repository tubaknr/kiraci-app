import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/main.dart';

void main() {
  testWidgets('Uygulama baslangic widget testi', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeRentHouseApp());
    expect(find.text('SafeRentHouse'), findsOneWidget);
  });
}
