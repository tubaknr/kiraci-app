---
name: local-data-layer
description: SQLite şeması, append-only repository ve kullanıcı dosyalarının uygulama dizinine kopyalanması gerektiğinde kullan.
---

# Yerel Veri Katmanı

## Amaç
Backend olmadığı için tüm veriyi cihazda, tutarlı ve silinemez/düzenlenemez bir yapıda tutmak.

## Ne Zaman Kullan
- Yeni tablo veya repository eklerken
- Kullanıcı dosyası kaydederken

## Ne Zaman Kullanma
- Hash ve zincir hesabı (bunun için `evidence-integrity`)

## Şema (özet)
| Tablo | Alanlar |
|---|---|
| `cases` | id, title, address, my_role, other_party_name, lease_start, lease_end, created_at |
| `records` | id, case_id, type, title, note, file_path, content_hash, prev_chain_hash, chain_hash, recorded_at, clock_anomaly, form_type, corrects_record_id |

## Kurallar
1. `RecordRepository` yalnızca `insert`, `getByCase`, `getById` sunar. `update`/`delete` **yazılmaz**.
2. Dosyalar `getApplicationDocumentsDirectory()/records/<case_id>/` altına kopyalanır; orijinal yol saklanmaz.
3. Veritabanında dosyanın göreli yolu tutulur, mutlak yol değil (iOS yolu değişebilir).
4. Ekleme, tek transaction içinde yapılır (son kaydı oku → zinciri hesapla → ekle).
5. Şema değişirse `version` artırılır ve `onUpgrade` yazılır; veri silinmez.
6. Ağ isteği yoktur.

## Adımlar
1. `core/db/app_database.dart` → tek bir `Database` örneği (singleton)
2. Tablo oluşturma `onCreate` içinde
3. Repository sınıfı: `features/<x>/models` ile `toMap/fromMap`
4. Servis: dosya kopyala → hash (bkz. `evidence-integrity`) → transaction'da ekle
5. Test: `sqflite_common_ffi` olmadan çalışmazsa repository'yi arayüzle soyutla, sahte uygulamayla test et

## Şablon
```dart
abstract class RecordRepository {
  Future<RecordModel> insert(RecordModel r); // update / delete YOK
  Future<List<RecordModel>> getByCase(String caseId);
  Future<RecordModel?> getLast(String caseId);
}
```

## Kontrol Listesi
- [ ] `update`/`delete` metodu yok
- [ ] Ekleme transaction içinde
- [ ] Dosya uygulama dizinine kopyalandı, göreli yol saklandı
- [ ] Şema sürümü ve `onUpgrade` düşünüldü
- [ ] `flutter analyze` 0 uyarı

## Sık Yapılan Hatalar
| Hata | Doğrusu |
|---|---|
| Orijinal galeri yolunu saklamak | Dosyayı kopyala, kopyanın göreli yolunu sakla |
| Zinciri transaction dışında hesaplamak | Okuma + ekleme aynı transaction'da |
| "Düzenle" özelliği eklemek | Yeni kayıt (`corrects_record_id`) |
