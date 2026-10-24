---
name: flutter-feature-scaffold
description: Yeni bir özellik/ekran modülü açarken controller/models/view/widget klasör yapısını, ValueNotifier state'ini ve birim test iskeletini üretir.
---

# Flutter Feature Scaffold

## Amaç
Her yeni ekran/özellik, `agents.md` kurallarına (ValueNotifier, const, tema dosyaları, 40 satır sınırı) uyan aynı iskeletle başlasın.

## Ne Zaman Kullan
- `lib/features/` altında yeni modül açılırken (cases, records, forms, export…)
- Yeni ekran + controller + model üçlüsü gerektiğinde

## Ne Zaman Kullanma
- Küçük tema/renk düzeltmesi, tek satırlık hata onarımı
- Veritabanı/hash kodu (bunun için `local-data-layer`, `evidence-integrity`)

## Temel Kurallar
1. Tek dosyada toplama yok: `controller/`, `models/`, `view/`, `widget/` ayrı.
2. State: `ValueNotifier` + `ValueListenableBuilder`. Sayfa düzeyinde ağır `setState` yasak.
3. Statik widget'larda `const` zorunlu.
4. Renk/`TextStyle` widget içinde yazılmaz; `Theme.of(context)` ve `AppColors`.
5. 40 satırı geçen `build` → özel widget'a böl.
6. UI veritabanına doğrudan erişmez; controller repository'yi kullanır.

## Adımlar
1. Klasörleri aç:
```text
lib/features/<feature>/
    controller/<feature>_controller.dart
    models/<feature>_model.dart
    view/<feature>_view.dart
    widget/<feature>_card.dart
```
2. Model: immutable, `const` constructor, `copyWith`, `toMap`, `fromMap`.
3. Controller: `ValueNotifier`'lar + repository çağrıları + `dispose()` (Tuba).
4. Widget'lar: `StatelessWidget`, `const` (Sümeyye).
5. View: `ValueListenableBuilder` ile bağla.
6. Controller için birim testi yaz (sahte repository ile).
7. `flutter analyze` + `flutter test`.

## Şablon: Controller
```dart
import 'package:flutter/foundation.dart';

enum ViewStatus { idle, loading, success, error }

class CaseListController {
  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<List<CaseModel>> items = ValueNotifier(const []);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  final CaseRepository _repo;
  CaseListController(this._repo);

  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      items.value = await _repo.getAll();
      status.value = ViewStatus.success;
    } catch (_) {
      errorMessage.value = 'Dosyalar yüklenemedi.';
      status.value = ViewStatus.error;
    }
  }

  void dispose() {
    status.dispose();
    items.dispose();
    errorMessage.dispose();
  }
}
```

## Şablon: View
```dart
class CaseListView extends StatelessWidget {
  final CaseListController controller;
  const CaseListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dosyalarım')),
      body: ValueListenableBuilder<ViewStatus>(
        valueListenable: controller.status,
        builder: (context, status, _) {
          switch (status) {
            case ViewStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ViewStatus.error:
              return Center(child: Text(controller.errorMessage.value ?? ''));
            default:
              return CaseListBody(controller: controller);
          }
        },
      ),
    );
  }
}
```

## Şablon: Birim Testi
```dart
void main() {
  test('load başarılıysa success olur', () async {
    final c = CaseListController(FakeCaseRepository());
    await c.load();
    expect(c.status.value, ViewStatus.success);
    c.dispose();
  });
}
```

## Kontrol Listesi
- [ ] 4 klasör açıldı
- [ ] `dispose()` yazıldı ve üst widget'ta çağrılıyor
- [ ] Statik widget'lar `const`
- [ ] Renk/stil temadan geliyor
- [ ] Hiçbir `build` 40 satırı geçmiyor
- [ ] Controller testi var
- [ ] `flutter analyze` 0 uyarı, `flutter test` geçti

## Sık Yapılan Hatalar
| Hata | Doğrusu |
|---|---|
| `setState` ile tüm sayfayı yenilemek | `ValueListenableBuilder` ile yalnızca ilgili parçayı dinle |
| `dispose()` unutmak | Controller'ı oluşturan widget `dispose`'ta temizler |
| Widget içinde `Color(0xFF...)` | `AppColors` / `Theme.of(context)` |
| UI içinde SQL veya hash | Controller → repository/servis |
