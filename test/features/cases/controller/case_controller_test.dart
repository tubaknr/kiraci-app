import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/db/case_repository.dart';
import 'package:saferenthouse/features/cases/controller/case_create_controller.dart';
import 'package:saferenthouse/features/cases/controller/case_list_controller.dart';
import 'package:saferenthouse/features/cases/models/case_model.dart';

class FakeCaseRepository implements CaseRepository {
  final List<CaseModel> storage = [];
  bool shouldThrow = false;

  @override
  Future<CaseModel> insert(CaseModel caseModel) async {
    if (shouldThrow) throw Exception('Simulated DB error');
    storage.add(caseModel);
    return caseModel;
  }

  @override
  Future<List<CaseModel>> getAll() async {
    if (shouldThrow) throw Exception('Simulated DB error');
    return List.unmodifiable(storage.reversed);
  }

  @override
  Future<CaseModel?> getById(String id) async {
    if (shouldThrow) throw Exception('Simulated DB error');
    try {
      return storage.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  late FakeCaseRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeCaseRepository();
  });

  group('CaseListController Tests', () {
    test('loadCases basarili calistiginda status success olmali ve listeyi getirmeli', () async {
      fakeRepo.storage.add(
        CaseModel(
          id: 'c1',
          title: 'Daire 1',
          address: 'Adres 1',
          myRole: 'tenant',
          otherPartyName: 'Ev Sahibi 1',
          leaseStart: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );

      final controller = CaseListController(fakeRepo);
      expect(controller.status.value, ViewStatus.idle);

      await controller.loadCases();

      expect(controller.status.value, ViewStatus.success);
      expect(controller.cases.value.length, 1);
      expect(controller.cases.value.first.title, 'Daire 1');
      expect(controller.errorMessage.value, isNull);

      controller.dispose();
    });

    test('Hata olustugunda status error olmali ve hata mesaji set edilmeli', () async {
      fakeRepo.shouldThrow = true;
      final controller = CaseListController(fakeRepo);

      await controller.loadCases();

      expect(controller.status.value, ViewStatus.error);
      expect(controller.errorMessage.value, isNotNull);
      expect(controller.cases.value, isEmpty);

      controller.dispose();
    });
  });

  group('CaseCreateController Tests', () {
    test('Gecerli verilerle createCase basarili olmali', () async {
      final controller = CaseCreateController(fakeRepo);

      final success = await controller.createCase(
        title: 'Yeni Dosya',
        address: 'Ornek Sokak No:5',
        myRole: 'tenant',
        otherPartyName: 'Ali Veli',
        leaseStart: DateTime.utc(2026, 1, 1),
      );

      expect(success, isTrue);
      expect(controller.status.value, ViewStatus.success);
      expect(controller.createdCase.value, isNotNull);
      expect(controller.createdCase.value!.title, 'Yeni Dosya');
      expect(fakeRepo.storage.length, 1);

      controller.dispose();
    });

    test('Bos baslik ile createCase dogrulama hatasi vermeli', () async {
      final controller = CaseCreateController(fakeRepo);

      final success = await controller.createCase(
        title: '   ',
        address: 'Ornek Sokak No:5',
        myRole: 'tenant',
        otherPartyName: 'Ali Veli',
        leaseStart: DateTime.utc(2026, 1, 1),
      );

      expect(success, isFalse);
      expect(controller.status.value, ViewStatus.error);
      expect(controller.errorMessage.value, 'Dosya başlığı boş bırakılamaz.');
      expect(fakeRepo.storage, isEmpty);

      controller.dispose();
    });

    test('Gecersiz bitis tarihi durumunda hata vermeli', () async {
      final controller = CaseCreateController(fakeRepo);

      final success = await controller.createCase(
        title: 'Kira Dosyasi',
        address: 'Adres',
        myRole: 'tenant',
        otherPartyName: 'Ev Sahibi',
        leaseStart: DateTime.utc(2026, 5, 1),
        leaseEnd: DateTime.utc(2026, 4, 1), // Baslangictan once
      );

      expect(success, isFalse);
      expect(controller.status.value, ViewStatus.error);
      expect(
        controller.errorMessage.value,
        'Sözleşme bitiş tarihi başlangıç tarihinden önce olamaz.',
      );

      controller.dispose();
    });
  });
}
