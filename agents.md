# agents.md — Ajan Çalışma Kuralları (SafeRentHouse)

Bu dosya, projede kod yazan yapay zeka ajanları (AntiGravity vb.) ve geliştiriciler için **bağlayıcı** kılavuzdur. Sıra: `project.md` → bu dosya → `progress.md`.

## 1. Oturum Başlangıcı
1. `project.md` → kapsam, sahiplik, kapsam dışı liste
2. `progress.md` → aktif görev ve sıradaki iş
3. İlgili skill'i `skills/` altından seç ve oku
4. Hangi kişi için çalışıldığını anla (Tuba / Sümeyye). Başkasının alanında doğrudan değişiklik yapma.

## 2. Sahiplik ve Sınırlar
| Alan | Sahip | Başkası değiştirmek isterse |
|---|---|---|
| `lib/core/db`, `core/integrity`, `core/services` | Tuba | PR + onay |
| Tüm `features/*/controller/` ve `features/*/models/` | Tuba | PR + onay |
| `features/forms/view` F1–F2 | Tuba | PR + onay |
| `lib/core/theme`, `core/constants` | Sümeyye | PR + onay |
| `features/*/view/` ve `widget/` (F1–F2 hariç) | Sümeyye | PR + onay |
| `project.md`, `agents.md` | İkisi birlikte | Değişiklik öncesi haber ver |

**Sözleşme kuralı:** UI, yalnızca controller'ın açtığı `ValueNotifier`'ları dinler ve metotlarını çağırır. Veritabanına veya hash koduna UI'dan doğrudan erişilmez. Controller arayüzü değişecekse önce Tuba'ya haber ver.

## 3. Kırmızı Çizgiler
1. **State:** `ValueNotifier` + `ValueListenableBuilder`. Sayfa düzeyinde ağır `setState` yasak. Yalnızca yerel UI durumu (animasyon, odak) için `StatefulWidget`.
2. **UI ve performans:**
   - Statik tüm widget'larda `const` zorunlu.
   - Renk ve metin stilleri yalnızca `core/constants/app_colors.dart` ve `core/theme/app_theme.dart` içinde.
   - 40 satırı geçen `build` metotları özel widget'lara bölünür.
3. **Paketler:** `project.md` Bölüm 4 dışında paket eklenmez; onay iste.
4. **Mimari:** Her özellik kendi klasöründe: `controller/`, `models/`, `view/`, `widget/`. Tek dosyada toplama yasak.
5. **Append-only:** Kayıt tablosu için `update`/`delete` metodu yazma. Düzeltme = yeni kayıt.
6. **Gizlilik:** Kullanıcı dosyaları yalnızca uygulama dizininde tutulur. Hiçbir veri ağa gönderilmez (uygulamada ağ isteği yoktur).
7. **Hukuki dil:** "Mahkemede geçerli", "kesin delil" gibi ifadeler yazma. Kullan: "doğrulanabilir kayıt", "zincir doğrulandı".
8. **Dürüst arayüz:** Kayıt zamanının cihaz saatine dayandığı kullanıcıya gösterilir; "resmî zaman damgası" deme.

## 4. Doğrulama Komutları
Kod değişikliğinden sonra **mutlaka** çalıştır:

```bash
flutter analyze      # 0 uyarı, 0 hata şart
flutter test
flutter run
```

## 5. Ajanın Çıktı Standartları
- **Dil:** Türkçe, net ve doğrudan.
- **Değişiklik sunumu:** Büyük dosyada az satır değiştiyse tüm dosyayı basma; hedef satırları ve diff'i göster.
- **Dosya yolları:** Bahsedilen/üretilen her dosya için projeye göre yol ver.
- **Doğrulama:** Kod yazdıktan sonra "Şimdi `flutter analyze` ile kontrol edebilirsin." de.
- **Emin değilsen sor:** Kapsam dışı görünen bir şeyi kendi kararınla ekleme.

## 6. Görev Bitirme Akışı
1. Analiz + test geçti mi?
2. `skills/git-workflow` ile commit/push
3. `skills/progress-update` ile `progress.md` ve `done.md` güncelle
4. Kullanıcıya özet: ne yapıldı, hangi dosyalar, sıradaki görev
