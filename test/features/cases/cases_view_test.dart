import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/features/cases/controller/case_create_controller.dart';
import 'package:saferenthouse/features/cases/controller/case_list_controller.dart';
import 'package:saferenthouse/features/cases/models/case_model.dart';
import 'package:saferenthouse/features/cases/view/case_create_view.dart';
import 'package:saferenthouse/features/cases/view/cases_view.dart';

import 'controller/case_controller_test.dart';

void main() {
  group('CasesView & CaseCreateView Widget Tests (Sümeyye - T07)', () {
    late FakeCaseRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeCaseRepository();
    });

    testWidgets('CasesView shows empty state when no cases exist',
        (WidgetTester tester) async {
      final CaseListController listController = CaseListController(fakeRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: CasesView(controller: listController),
        ),
      );
      await tester.pump();

      expect(find.text('Kayıtlı Kira Dosyası Bulunamadı'), findsOneWidget);
      expect(find.text('İlk Dosyayı Oluştur'), findsOneWidget);

      listController.dispose();
    });

    testWidgets('CasesView displays case cards and handles selection',
        (WidgetTester tester) async {
      fakeRepo.storage.add(
        CaseModel(
          id: 'test_case_1',
          title: 'Kadıköy Dairesi',
          address: 'Moda Cad. No:10',
          myRole: 'tenant',
          otherPartyName: 'Ahmet Yılmaz',
          leaseStart: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );

      final CaseListController listController = CaseListController(fakeRepo);
      CaseModel? selectedCase;

      await tester.pumpWidget(
        MaterialApp(
          home: CasesView(
            controller: listController,
            onSelectCase: (CaseModel c) => selectedCase = c,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Kadıköy Dairesi'), findsOneWidget);
      expect(find.text('Kiracı'), findsOneWidget);
      expect(find.text('Karşı Taraf: Ahmet Yılmaz'), findsOneWidget);

      // Tap card
      await tester.tap(find.text('Kadıköy Dairesi'));
      await tester.pump();

      expect(selectedCase, isNotNull);
      expect(selectedCase!.id, 'test_case_1');

      listController.dispose();
    });

    testWidgets('CaseCreateView validates fields and submits properly',
        (WidgetTester tester) async {
      final CaseCreateController createController = CaseCreateController(fakeRepo);
      bool successCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CaseCreateView(
            controller: createController,
            onSuccess: () => successCalled = true,
          ),
        ),
      );

      // Tap submit with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Dosyayı Kaydet ve Başla'));
      await tester.pump();

      expect(find.text('Dosya başlığı boş bırakılamaz.'), findsOneWidget);

      // Enter valid fields
      await tester.enterText(
        find.widgetWithText(TextField, 'Dosya Başlığı *'),
        'Beşiktaş 2+1',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Taşınmaz Adresi *'),
        'Çarşı Cad. No:20',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Karşı Taraf Adı Soyadı *'),
        'Mehmet Demir',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Dosyayı Kaydet ve Başla'));
      await tester.pumpAndSettle();

      expect(fakeRepo.storage.length, 1);
      expect(fakeRepo.storage.first.title, 'Beşiktaş 2+1');
      expect(successCalled, isTrue);

      createController.dispose();
    });
  });
}
