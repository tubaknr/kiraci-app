---
name: form-screen
description: F1–F5 formlarından birini (model, doğrulama, controller, ekran) üretirken veya düzenlerken kullan.
---

# Form Ekranı (F1–F5)

## Amaç
Yapılandırılmış formu doğrulayıp kanonik JSON'a çevirmek ve değiştirilemez kayıt olarak eklemek.

## Ne Zaman Kullan
- F1 Sözleşme, F2 Teslim/Tahliye, F3 Arıza, F4 Ödeme, F5 Olay Notu formlarını yazarken
- Form alanı eklerken/değiştirirken

## Ne Zaman Kullanma
- Serbest dosya ekleme (o `records` özelliğidir)

## Sahiplik
Model, doğrulama, controller: **Tuba**. Ekran: F1–F2 Tuba, F3–F5 Sümeyye. Ekranı yazan kişi controller arayüzünü değiştirmez; ihtiyaç varsa Tuba'ya iletir.

## Adımlar
1. Model: `features/forms/models/<form>_data.dart` (immutable, `copyWith`, `toMap`, `fromMap`)
2. Doğrulayıcı: saf Dart, `Map<String, String> validate()` (alan → hata)
3. Controller: alanlar için `ValueNotifier`, gönderim için `ValueNotifier<ViewStatus>`
4. `submit()`:
   a. Doğrula; hata varsa dur
   b. `canonicalJson(toMap())` ile sıralı JSON üret
   c. `RecordService.addFormRecord(...)` çağır (hash + zincir orada yapılır)
5. Ekran: `StatelessWidget`, alanlar ayrı widget'lar, 40 satır kuralı
6. Düzeltme için mevcut kaydı değiştirme; yeni form + `corrects_record_id`
7. Test: doğrulayıcı ve kanonik JSON için birim testi

## Şablon: Doğrulayıcı
```dart
Map<String, String> validatePayment(PaymentFormData d) {
  final errors = <String, String>{};
  if (d.amount <= 0) errors['amount'] = 'Tutar 0’dan büyük olmalı';
  if (d.period.isEmpty) errors['period'] = 'Dönem seçin';
  return errors;
}
```

## Kontrol Listesi
- [ ] Zorunlu alanlar doğrulanıyor, hata mesajları Türkçe
- [ ] Gönderilen form düzenlenemiyor
- [ ] Kanonik JSON ve hash testi var
- [ ] Ekranda sabit renk/stil yok
- [ ] Metinlerde hukuki iddia yok

## Sık Yapılan Hatalar
| Hata | Doğrusu |
|---|---|
| Gönderilmiş formu güncellemek | Yeni form + `corrects_record_id` |
| JSON'u sırasız hash'lemek | Anahtarları sırala, sonra hash'le |
| Doğrulamayı yalnızca ekranda yapmak | Doğrulama controller'da; ekran sadece gösterir |
