# SafeRentHouse

> Bu dosya projenin "anayasası"dır. Ajan her oturumda ilk bunu okur, sonra `agents.md`, `progress.md`.
> Kapsam değişirse önce burası güncellenir ve iki geliştirici de haberdar edilir.

## 1. Amaç
SafeRentHouse; kiracı ile ev sahibi arasında yaşanabilecek uyuşmazlıklara karşı **belgeleri, yazışma kanıtlarını ve delilleri** tarihli ve sıralı biçimde kaydeden, kayıtlar sonradan değiştirilirse bunu **tespit edebilen** bir mobil uygulamadır. Uygulama **backend'siz** çalışır: tüm veri kullanıcının cihazında tutulur. Hukuki süreçte kullanılabilecek **PDF raporu ve doğrulanabilir delil paketi (ZIP)** üretir. Hukuki tavsiye vermez; kayıt ve belge düzenleme aracıdır.

## 2. Hedef Kitle
- Kiracılar (depozito, tadilat, arıza, tahliye, kira artışı anlaşmazlıkları)
- Ev sahipleri (hasar, ödeme gecikmesi, tahliye tespiti)

Her kullanıcı kendi cihazında kendi dosyalarını tutar. Karşı tarafla paylaşım, dışa aktarılan PDF/ZIP ile yapılır (uygulama içi ortak dosya yoktur).

## 3. Ekip ve İş Bölümü
| Kişi | Rol | Sorumluluk alanı |
|---|---|---|
| **Tuba** | Veri + Mantık + Formlar | `core/db`, `core/integrity`, `core/services`, tüm `controller/` ve `models/` klasörleri, F1–F5 form mantığı, F1–F2 ekranları, ZIP delil paketi, uygulama kilidi mantığı |
| **Sümeyye** | Frontend / UI | `core/theme`, `core/constants`, navigasyon, tüm ekranların `view/` ve `widget/` katmanı (F1–F2 hariç), F3–F5 form ekranları, PDF dışa aktarma, yerel bildirim |

Ortak: `project.md`, `agents.md`, çaprazlama code review, test ve README.

## 4. Teknoloji
Yalnızca **Flutter + Dart**. Backend yoktur.

| Katman | Seçim |
|---|---|
| Framework | Flutter / Dart, Material 3 |
| Durum yönetimi | `ValueNotifier` + `ValueListenableBuilder` (harici state paketi YOK) |
| Yerel veri | `sqflite` + `path` + `path_provider` |
| Dosya/Medya | `image_picker`, `file_picker` |
| Hash | `crypto` (SHA-256) |
| PDF | `pdf` + `printing` |
| ZIP | `archive` |
| Paylaşma | `share_plus` |
| Bildirim | `flutter_local_notifications` |
| Uygulama kilidi | `local_auth` |
| Tarih/saat | `intl` |
| Hedef platform | Android + iOS | web. 

## 5. Kayıt Bütünlüğü Tasarımı (Yerel)
1. **Append-only repository:** Uygulama kodunda `UPDATE` / `DELETE` kayıt metodu yoktur. Yalnızca `insert` ve `select`.
2. **SHA-256 özeti:** Her dosya uygulamanın kendi dizinine kopyalanır ve baytlarından hash'lenir.
3. **Zincir:** `chain_hash = SHA256(önceki_chain_hash | content_hash | kayıt_zamanı)`. Bir kayıt değiştirilir veya silinirse doğrulama zinciri o noktada kırılır.
4. **Saat anomalisi tespiti:** Yeni kaydın zamanı bir önceki kaydın zamanından eskiyse kayıt `clock_anomaly` ile işaretlenir ve raporda gösterilir.
5. **Dış çapa (mühür kodu):** Kullanıcı, dosyanın son `chain_hash` değerini e-posta/mesajla kendine veya karşı tarafa gönderebilir. Zaman damgası bu bağımsız kanaldan gelir.
6. **Dışa aktarma doğrulaması:** ZIP paketindeki `manifest.json` her dosyanın hash'ini ve zinciri içerir; üçüncü kişi hash'leri yeniden hesaplayarak kontrol edebilir.

## 6. Özellikler ve Sahiplik
Puan: S=1, M=2, L=3.

| # | Özellik | Öncelik | Mantık (Tuba) | Ekran (Sümeyye) | Açıklama |
|---|---|---|---|---|---|
| 1 | Onboarding + KVKK/uyarı metni | Yüksek | – | M | İlk açılışta kullanım sınırları ve rıza |
| 2 | Dosya (case) oluşturma | Yüksek | M | M | Adres, taraflar, sözleşme tarihleri |
| 3 | Kayıt ekleme: belge/foto/video/ses | Yüksek | L | M | Kopyala → hash → zincire ekle |
| 4 | Konuşma kanıtı (ekran görüntüsü + not) | Yüksek | (3'ü kullanır) | S | WhatsApp vb. ekran görüntüsü + açıklama |
| 5 | **Formlar F1–F5** (Bölüm 7) | Yüksek | L+M+S | F1–F2: Tuba, F3–F5: M+S | Yapılandırılmış form → JSON → kayıt |
| 6 | Zaman çizelgesi | Yüksek | – | M | Dosyadaki tüm kayıtlar kronolojik |
| 7 | Kayıt detayı + zincir doğrulama | Orta | S | S | "Zincir sağlam / kırık" rozeti |
| 8 | PDF rapor | Orta | – | L | Zaman çizelgesi + hash tablosu |
| 9 | ZIP delil paketi + mühür kodu paylaşımı | Orta | M | – | Dosyalar + `manifest.json`, `share_plus` |
| 10 | Tema, ayarlar | Orta | – | M | Açık/koyu tema |
| 11 | Uygulama kilidi (PIN/biyometrik) | Orta | S | S | `local_auth` |
| 12 | Hatırlatıcı bildirim | Düşük | – | S | Kira tarihi vb., yerel bildirim |

Toplam puanlar `progress.md`'de takip edilir (planlanan: Tuba 25, Sümeyye 23).

## 7. Formlar
| Form | Amaç | Ana alanlar |
|---|---|---|
| F1 Sözleşme Bilgi Formu | Kira şartlarını sabitlemek | Taraflar, adres, kira bedeli, depozito, başlangıç/bitiş, artış oranı |
| F2 Teslim / Tahliye Tespit Formu | Evin durumunu belgelemek | Oda oda durum, sayaç değerleri, anahtar sayısı, foto bağlantıları |
| F3 Arıza / Sorun Bildirim Formu | Sorunu tarihli kaydetmek | Sorun türü, açıklama, aciliyet, foto |
| F4 Ödeme Bildirim Formu | Kira/depozito ödemesini kayda geçirmek | Tutar, dönem, yöntem, dekont dosyası |
| F5 Olay Notu Formu | Serbest olay/konuşma özeti | Tarih-saat, kişiler, özet, ek dosyalar |

**İş bölümü:** Model, doğrulama ve controller (F1–F5) Tuba'dadır. Ekranlar: F1–F2 Tuba, F3–F5 Sümeyye. Sümeyye'nin ekranları Tuba'nın controller arayüzüne bağlanır.

**Kural:** Gönderilen form kanonik (sıralı anahtar) JSON olarak hash'lenir ve kayıt olarak eklenir. Form düzenlenemez; düzeltme için yeni form + `corrects_record_id` kullanılır.

# SafeRentHouse: Görev Dağılımı

Proje: Kiracı ve ev sahibi arasındaki uyuşmazlıklar için belge, yazışma kanıtı ve delil kaydı tutan, kayıtlar değiştirilirse bunu tespit eden mobil uygulama.
Teknoloji: Yalnızca Flutter + Dart. Backend yok, veri cihazda (SQLite).
Takvim: 26.10.2026 – 29.11.2026 (5 hafta, varsayımsal)
Puan: S=1, M=2, L=3

## 1. Kim Ne Yapacak (Özet)
| | Tuba | Sümeyye |
|---|---|---|
| Rol | Veri + mantık + formlar | Arayüz (frontend) |
| Sorumlu klasörler | `core/db`, `core/integrity`, `core/services`, tüm `controller/` ve `models/` | `core/theme`, `core/constants`, `view/` ve `widget/` (F1–F2 hariç) |
| Ana işler | SQLite, hash zinciri, kayıt servisi, form mantığı (F1–F5), F1–F2 ekranları, ZIP paketi, kilit mantığı | Tema, navigasyon, tüm ekranlar, F3–F5 form ekranları, PDF rapor, bildirim, ayarlar |
| Toplam puan | **25** | **23** |

Ortak işler: test temizliği (T24), README ve demo (T25), code review (çaprazlama).

## 2. Tuba'nın Görevleri
| ID | Görev | Puan | Hedef |
|---|---|---|---|
| T01 | Flutter projesi, klasör yapısı, paketler, `analysis_options.yaml` | 1 | 
| T03 | SQLite şeması + `app_database.dart` + append-only repository | 2 | 
| T05 | `hash_utils.dart` (SHA-256, zincir, kanonik JSON) + birim testleri | 2 | 
| T06 | Dosya (case) modeli + repository + controller | 2 | 
| T08 | Kayıt ekleme servisi: dosyayı uygulama dizinine kopyala, hash, zincir, saat anomalisi tespiti | 3 | 
| T13 | Zincir doğrulama servisi (`verifyChain`) + test | 1 | 
| T11 | Form altyapısı (alan modeli, doğrulama, submit) + F1 Sözleşme Formu (mantık + ekran) | 3 | 
| T15 | F2 Teslim/Tahliye Formu (mantık + ekran) | 3 | 
| T17 | F3 Arıza + F4 Ödeme formları: model, doğrulama, controller | 2 | 
| T19 | ZIP delil paketi (`manifest.json`) + mühür kodu paylaşımı | 2 | 
| T20 | F5 Olay Notu formu: model, doğrulama, controller | 1 | 
| T22 | Uygulama kilidi mantığı (PIN özeti + `local_auth`) | 1 | 
| | **Toplam** | **23** | |

## 3. Sümeyye'nin Görevleri
| ID | Görev | Puan | Hedef |
|---|---|---|---|
| T02 | `main.dart`, tema (`app_colors`, `app_theme`, `ValueNotifier<ThemeMode>`) | 2 | 
| T04 | Navigasyon + onboarding + KVKK/uyarı ekranı | 2 | 
| T07 | Dosyalarım + Dosya Oluştur ekranları | 2 | 
| T09 | Kayıt Ekle ekranı (tür seç, kamera/dosya seçici) | 2 | 
| T10 | Zaman çizelgesi ekranı | 2 | 
| T12 | Kayıt Detayı + zincir doğrulama rozeti | 1 | 
| T14 | Konuşma kanıtı ekranı (ekran görüntüsü + not) | 1 | 
| T16 | PDF rapor (zaman çizelgesi + hash tablosu + saat uyarısı) | 3 | 
| T18 | F3 + F4 form ekranları + Form Listesi | 2 | 
| T21 | F5 form ekranı + hatırlatıcı bildirim | 2 | 
| T23 | Ayarlar + kilit ekranı + yedek hatırlatma | 2 | 
| | **Toplam** | **21** | |

## 4. Ortak Görevler
| ID | Görev | Tuba | Sümeyye | Hedef |
|---|---|---|---|---|
| T24 | Uçtan uca test, `flutter analyze` / `flutter test` temizliği | 1 | 1 | 
| T25 | README + demo senaryosu | 1 | 1 |

## 7. Uygulama Özellikleri (Kapsam)
1. Onboarding + KVKK/uyarı metni
2. Dosya (case) oluşturma: adres, taraflar, sözleşme tarihleri
3. Kayıt ekleme: belge, foto, video, ses
4. Konuşma kanıtı: ekran görüntüsü + not
5. Formlar: F1 Sözleşme, F2 Teslim/Tahliye, F3 Arıza, F4 Ödeme, F5 Olay Notu
6. Zaman çizelgesi
7. Kayıt detayı + zincir doğrulama
8. PDF rapor
9. ZIP delil paketi + mühür kodu paylaşımı
10. Tema ve ayarlar
11. Uygulama kilidi
12. Hatırlatıcı bildirim

## 8. Kapsam Dışı
Backend, hesap/giriş, karşı tarafla ortak dosya, hukuki tavsiye, gizli kayıt, e-imza, blockchain, kayıt silme/düzenleme, web/masaüstü.

## 9. Ortak Kurallar
- State: `ValueNotifier` + `ValueListenableBuilder`; sayfa düzeyinde ağır `setState` yok
- Statik widget'larda `const`; renk ve stil yalnızca tema dosyalarında; 40 satırı geçen `build` bölünür
- Onaysız yeni paket eklenmez
- Kayıtlar yalnızca eklenir; `update` ve `delete` yazılmaz
- Her görev sonrası `flutter analyze` (0 uyarı) ve `flutter test`
- Her görev ayrı branch (`kisi/T-no-aciklama`), PR'ı diğer kişi inceler
- Görev bitince `progress.md` ve `done.md` güncellenir
- Arayüzde "mahkemede geçerli" yazılmaz; "doğrulanabilir kayıt" kullanılır

## 10. Bilinen Sınır
Zaman damgası cihaz saatidir ve değiştirilebilir. Zincir değişikliği tespit eder, zamanın doğruluğunu kanıtlamaz. Azaltma: saat anomalisi tespiti + mühür kodunu e-postayla dışarı gönderme + ZIP doğrulaması.

## 8. Sayfalar / Ekranlar
| Ekran | Dosya | Sahip |
|---|---|---|
| Onboarding / KVKK | `lib/features/onboarding/view/onboarding_view.dart` | Sümeyye |
| Dosyalarım | `lib/features/cases/view/cases_view.dart` | Sümeyye |
| Dosya Oluştur | `lib/features/cases/view/case_create_view.dart` | Sümeyye |
| Zaman Çizelgesi | `lib/features/records/view/timeline_view.dart` | Sümeyye |
| Kayıt Ekle | `lib/features/records/view/record_add_view.dart` | Sümeyye |
| Kayıt Detayı | `lib/features/records/view/record_detail_view.dart` | Sümeyye |
| Form Listesi | `lib/features/forms/view/forms_menu_view.dart` | Sümeyye |
| F1, F2 ekranları | `lib/features/forms/view/f1_*_view.dart`, `f2_*_view.dart` | Tuba |
| F3, F4, F5 ekranları | `lib/features/forms/view/f3_*` … `f5_*_view.dart` | Sümeyye |
| Dışa Aktar (PDF / ZIP) | `lib/features/export/view/export_view.dart` | Sümeyye |
| Ayarlar + Kilit | `lib/features/settings/view/settings_view.dart`, `lock/view/lock_view.dart` | Sümeyye |

## 10. Kapsam Dışı (YAPMA)
- Backend, sunucu, bulut, hesap/giriş sistemi
- Uygulama içi karşı tarafla ortak dosya veya davet
- Hukuki tavsiye ve "mahkemede geçerlidir" iddiası
- Gizli/rızasız ses veya görüntü kaydı
- Sohbet uygulaması içeriğini otomatik çekme
- E-imza, blockchain, ödeme
- Kayıt silme veya düzenleme
- Web ve masaüstü arayüzü (ilk sürümde)

## 11. Riskler ve Dürüst Sınırlar
| Konu | Not |
|---|---|
| **Zaman güvenilirliği** | Backend olmadığı için zaman damgası **cihaz saatidir** ve kullanıcı tarafından değiştirilebilir. Hash zinciri ve saat anomalisi tespiti bunu *görünür* kılar ama *önlemez*. Dış çapa (mühür kodunu e-postayla göndermek) bu zayıflığı azaltır. Arayüz bunu açıkça belirtmelidir. |
| **Delil geçerliliği** | Delilin kabulü mahkemenin takdirindedir. Metinlerde "doğrulanabilir kayıt" ifadesi kullanılır. Bir hukukçuya gösterilmesi önerilir. |
| **Veri kaybı** | Veri yalnızca cihazdadır. Cihaz kaybı/silinmesi = veri kaybı. ZIP dışa aktarma aynı zamanda yedektir; kullanıcıya düzenli yedek hatırlatılır. |
| **Cihaz güvenliği** | Root/jailbreak'li cihazda veritabanı elle değiştirilebilir; zincir bunu doğrulamada yakalar. Uygulama kilidi ve dosyaların uygulama dizininde tutulması temel korumadır. |
| **KVKK** | Kimlik, adres, foto kişisel veridir. Veri cihazda kalır, dışarı yalnızca kullanıcı paylaşırsa çıkar; yine de aydınlatma metni gerekir. |
| **Ses/konuşma** | Karşı tarafın bilgisi olmadan kaydedilen konuşmalar hukuki risk taşır; uygulama içinde uyarı gösterilir. |

## 12. Başarı Kriterleri
- [ ] Dosya oluştur → kayıt ekle → zaman çizelgesinde gör akışı çalışıyor
- [ ] Belge/foto/ses/form kayıtları hash ve zincirle ekleniyor
- [ ] Kayıt elle değiştirilince zincir doğrulama bozulmayı yakalıyor (test ile kanıtlı)
- [ ] Saat geri alınınca `clock_anomaly` işaretleniyor
- [ ] F1–F5 formları doğrulama ile çalışıyor
- [ ] PDF rapor ve ZIP delil paketi üretilip paylaşılabiliyor
- [ ] Açık/koyu tema, uygulama kilidi çalışıyor
- [ ] `flutter analyze` 0 uyarı / 0 hata, `flutter test` geçiyor
- [ ] İş yükü: iki kişinin tamamlanan puanı birbirine yakın (`done.md`)

## 13. Klasör Yapısı
```
saferenthouse/
├── project.md
├── agents.md
├── progress.md
├── done.md
├── skills/
│   ├── git-workflow/SKILL.md
│   ├── flutter-feature-scaffold/SKILL.md
│   ├── form-screen/SKILL.md
│   ├── local-data-layer/SKILL.md
│   ├── evidence-integrity/SKILL.md
│   └── progress-update/SKILL.md
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/app_colors.dart
│   │   ├── theme/app_theme.dart
│   │   ├── db/app_database.dart
│   │   ├── integrity/hash_utils.dart
│   │   └── services/            # dosya kopyalama, zip, kilit
│   └── features/
│       ├── onboarding/ cases/ records/ forms/ export/ settings/ lock/
│       └── (her feature: controller/ models/ view/ widget/)
└── test/
```
