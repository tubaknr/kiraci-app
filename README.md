# SafeRentHouse — Güvenli Kira & Delil Kayıt Uygulaması

Kiracı ile ev sahibi arasında yaşanabilecek uyuşmazlıklara karşı **belgeleri, yazışma kanıtlarını ve delilleri** tarihli ve sıralı biçimde kaydeden, kayıtlar sonradan değiştirilirse bunu **tespit edebilen** mobil uygulamadır.

> **Önemli İlke:** Uygulama tamamen **backend'siz** çalışır. Tüm veriler kullanıcının cihazında (yerel SQLite) saklanır; ağa hiçbir veri gönderilmez. Hukuki tavsiye vermez; bağımsız olarak doğrulanabilir delil ve kayıt düzenleme aracıdır.

---

## 🏛️ Temel Mimari ve Delil Bütünlüğü

1. **Append-Only Veri Tabanı:** Kod tabanında `UPDATE` ve `DELETE` metotları bulunmaz; yalnızca `INSERT` ve `SELECT`. Düzeltmeler yeni bir kayıt (`corrects_record_id`) ile eklenir.
2. **SHA-256 İçerik Özeti:** Eklenen her belge veya medya uygulamanın güvenli yerel dizinine (`records/<case_id>/`) kopyalanır ve akış (stream) üzerinden SHA-256 özeti hesaplanır. Orijinal galeri yolu asla tutulmaz.
3. **Kanonik JSON Formları:** Yapılandırılmış formlar (F1–F5), anahtarları özyinelemeli sıralanarak kanonik JSON formatına getirilir ve hash'lenir.
4. **Kriptografik Hash Zinciri:**
   $$\text{chain\_hash} = \text{SHA256}(\text{prev\_chain\_hash} \mid \text{content\_hash} \mid \text{recorded\_at\_utc})$$
   İlk kayıtta `GENESIS` kullanılır. Bir kayıt veya dosya sonradan değiştirilirse doğrulama zinciri o noktada kırılır (`verifyChain`).
5. **Saat Anomalisi Tespiti (`clock_anomaly`):** Cihaz saati geriye alınarak geriye dönük delil oluşturulmaya çalışılırsa sistem bunu tespit edip kaydı anomali olarak işaretler.
6. **Mühür Kodu (Dış Çapa):** Dosyanın son `chain_hash` değeri üçüncü kişilere veya e-postaya bağımsız zaman kanıtı olarak gönderilebilir.
7. **Doğrulanabilir ZIP Delil Paketi:** Kök dizininde [`manifest.json`](file:///home/tuba/Documents/GitHub/kiraci-app/lib/core/services/export_service.dart) bulunan ZIP paketiyle bağımsız bilirkişi denetimi yapılabilir.

---

## 👥 Ekip ve İş Bölümü

| Geliştirici | Sorumluluk Alanı | Tamamlanan Puan |
|---|---|---|
| **Tuba** | **Veri + Mantık + Formlar:** SQLite şeması, hash zinciri, kayıt servisi, zincir doğrulama, F1–F5 form mantığı ve controller'ları, F1–F2 ekranları, ZIP delil paketi, tuzlu PIN kilit mantığı. | **24 Puan** |
| **Sümeyye** | **Arayüz (UI) + Çıktı:** Tema, navigasyon, onboarding/KVKK, zaman çizelgesi ekranı, kayıt detay ekranı, F3–F5 form ekranları, PDF raporu, yerel bildirimler. | *(Geliştirme Aşamasında)* |

---

## 📁 Proje Klasör Yapısı

```text
lib/
├── main.dart                               # Ana uygulama ve mock gezinti
├── core/
│   ├── constants/                          # app_colors, view_status
│   ├── theme/                              # Material 3 açık/koyu tema
│   ├── db/                                 # app_database, case_repository, record_repository
│   ├── integrity/                          # hash_utils (SHA-256, kanonik JSON, zincir)
│   └── services/                           # record_service, integrity_service, export_service, lock_service
└── features/
    ├── onboarding/                         # Onboarding & KVKK ekranı
    ├── cases/                              # Dosya modelleri, controller ve ekranları
    ├── records/                            # Delil modelleri, kayıt ekleme ve zaman çizelgesi
    ├── forms/                              # F1-F5 form modelleri, doğrulayıcılar ve ekranlar
    ├── export/                             # ZIP paketi ve dışa aktarma controller'ı
    └── lock/                               # Tuzlu PIN ve biyometrik kilit controller'ı
```

---

## 🚀 Çalıştırma ve Test

### Geliştirici Ortamı (Terminal)
```bash
# Bağımlılıkları kontrol et
flutter pub get

# Statik kod analizi (0 hata / 0 uyarı şartı)
flutter analyze

# Birim ve widget testlerini çalıştır
flutter test

# Chrome veya bağlı cihazda başlat
flutter run -d chrome
```

---

## 🧪 Demo Senaryosu

1. **Uygulamayı Açın:** Onboarding ve KVKK aydınlatma metnini onaylayarak başlayın.
2. **Kira Dosyası Oluşturun:** "Dosyalarım" sekmesinden yeni bir dosya açın (Adres, Kiracı/Ev Sahibi rolü, karşı taraf adı).
3. **F1 Sözleşme Formunu Doldurun:** "Formlar" sekmesinden F1 Sözleşme Bilgi Formunu açıp kira şartlarını ve başlangıç tarihini girerek onaylayın.
4. **F2 Teslim Tutanağını Doldurun:** F2 formunda sayaç endekslerini (elektrik, su, doğalgaz) ve oda durumlarını girerek zincire ekleyin.
5. **Zaman Çizelgesini İnceleyin:** "Zaman Çizelgesi" sekmesine geçerek eklenen kayıtların kronolojik dizilimini ve üstteki **"Kayıt Zinciri Sağlam"** yeşil rozetini kontrol edin.
6. **ZIP Paketi ve Mühür Kodu Üretin:** Dosyayı `manifest.json` içeren ZIP arşivi olarak dışa aktarın ve son mühür kodunu bağımsız kanaldan paylaşın.
