---
name: flutter-feature
description: Yeni bir Flutter özelliği/ekranı (form, liste, detay, medya yükleme) Clean Architecture ile yazarken kullan. Giriş/kayıt, ana sayfa, kira detay, demirbaş formu, belge listeleme, bildirim oluşturma, mesajlar, zaman çizelgesi ekranları için.
---

# Flutter Özellik Geliştirme

## Başlamadan
1. `project.md` bölüm 5 ve 7, `docs/api.md` ilgili uç noktalar okunur.
2. Tema ve ortak widget'lar `app/lib/core/theme` içindeki token'lardan kullanılır; ekranda sabit renk/font yazılmaz (tema yoksa önce A-02 görevi yapılır).

## Adımlar (içten dışa)
1. **domain/entities**: saf Dart sınıf (`equatable`). Para `int amountKurus`, zaman `DateTime` (UTC).
2. **domain/repositories**: soyut arayüz. **domain/usecases**: tek iş yapan sınıf, `Result<T>` döner.
3. **data/models**: `fromJson/toJson`, entity'ye dönüştürme. **data/datasources**: `remote` (API) ve `local` (Hive taslak/önbellek).
4. **data/repositories**: arayüzü uygular; hataları `Result.failure`'a çevirir.
5. **presentation/providers**: `ChangeNotifier`; durumlar `loading | data | empty | error`.
6. **presentation/screens + widgets**: sadece provider ile konuşur.
7. Testler: use case + model birim testi; form için widget testi.

## Medya ve Belge Kuralları
- Fotoğraf: `image_picker` (kamera/galeri); seçimden sonra sıkıştır, boyut sınırını (`MAX_UPLOAD_MB`) aşıyorsa uyar.
- PDF/dekont: `file_picker` (`allowedExtensions: ['pdf','jpg','jpeg','png']`). `image_picker` PDF seçemez.
- Yükleme: `POST /evler/{evId}/dosyalar` (multipart) → dönen `id` ile asıl kayıt (demirbaş/dekont/bildirim) oluşturulur. İlerleme göstergesi ve yeniden deneme olsun.
- İzin reddedilirse (kamera/galeri/dosya) anlaşılır mesaj + ayarlara yönlendirme; uygulama çökmez.

## Zaman Damgası Kuralı (arayüz)
- Kayıt gönderilince **sunucudan dönen `sunucu_zamani`** gösterilir: "Kaydedildi — 24.10.2026 09:30".
- İstemci saati yalnızca `istemci_zamani` alanında bilgi olarak gönderilir.
- Hive'daki taslak "Taslak — henüz resmi kayıt değil" etiketiyle gösterilir ve başarılı gönderimde silinir.

## Form Kontrol Listesi
- [ ] Alan doğrulama (boş, uzunluk, tutar > 0, bitiş > başlangıç)
- [ ] Çift tıklamada çift kayıt yok (buton kilitlenir + `Idempotency-Key`)
- [ ] Loading / empty / error durumları
- [ ] Türkçe metinler; "hukuken geçerli" ifadesi yok
- [ ] Erişilebilirlik: etiketler, yeterli dokunma alanı
- [ ] `flutter analyze` 0 uyarı

## Role Duyarlı Arayüz
- Kullanıcının rolü açık evin `property_members.role` değerinden okunur; `if (isTenant)` gibi koşullar tek bir `PropertyRole` yardımcısından gelir, rol sabit kodlanmaz.
- Karşı taraf eylemleri (okundu, onay/itiraz) yalnızca karşı tarafa görünür.
- Test modu açıkken rol değişince Provider durumu sıfırlanır; ekranlar bunu `didChangeDependencies`/dinleyici ile yeniden yüklemelidir.
