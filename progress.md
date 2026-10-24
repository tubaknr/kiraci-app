# Progress

> Ajan her görevde günceller. Biten maddeler `done.md`'ye taşınır.
> Son güncelleme: 2026-10-24
> Kural: Bir göreve başlamadan önce "Şu An Üzerinde Çalışılan" tablosuna görevi (ve kimin üstlendiğini) yaz. İki kişi aynı anda çalışabilir; aynı görev/dosyada çakışma olmasın diye bu tablo kontrol edilir.

## Görev Sahipleri (netleşenler)
| Kişi | Görevler |
|---|---|
| **Tuba** | S-01…S-19 (iskelet, sunucu, auth, uç noktalar, seed), A-01, A-05…A-14. Ayrıca Sümeyye projeye dahil olana kadar A-02, A-03, A-04, A-15 için iş görecek temel mock ekranlar/bileşenler |
| **Sümeyye** | Projeye başladığında: Frontende dair her şey onun görevi (A-02 Tema/Widget nihai tasarımı, A-03 Splash, A-04 Giriş/Kayıt, A-15 Rol değiştirme ve tüm ekranların nihai UI/UX'i) |

## Şu An Üzerinde Çalışılan
| Görev | Sahip | Branch | Durum | Not |
|---|---|---|---|---|
| Henüz başlanmadı | - | - | - | İlk görev: S-01 (iskelet) |

## Sıradaki Görevler (öncelik sırasıyla)
Ön ek: **S** = sunucu/genel, **A** = Flutter uygulaması. Ajan yalnızca sıradaki `[ ]` görevi yapar (bağımsız ve farklı kişilerin üstlendiği görevler paralel ilerleyebilir).

### Faz 0 — İskelet
1. [ ] **S-01** Monorepo iskeleti: `app/` (Flutter), `server/` (Dart), `docs/`, `skills/`; Clean Architecture klasörleri; `.gitignore` (`.env`, `storage/`); `.env.example`
2. [ ] **S-02** İstemci cihaz içi veri kurulumu: Hive (taslak + önbellek kutuları), `flutter_secure_storage` (token) — Hive kararlaştırıldı
3. [ ] **S-03** Temel domain entity'leri ve modeller: `Property`(Ev), `Lease`(Sözleşme), `Receipt`(Dekont), `Notice`/`AuditLog`(Log/Bildirim), `User`, `InventoryItem`, `Message`, `StoredFile` (+ JSON dönüşümleri, birim test)

### Faz 1 — Sunucu temeli
4. [ ] **S-04** `server/` shelf iskeleti, config (.env), hata middleware'i, `GET /saglik`, docker-compose ile PostgreSQL
5. [ ] **S-05** Migration'lar: `docs/veritabani.md`'deki tüm tablolar + `forbid_mutation` trigger'ları + yetki REVOKE
6. [ ] **S-06** `TimestampService` (tek zaman otoritesi) + SHA-256 yardımcıları + birim test
7. [ ] **S-07** Hash zinciri servisi: `audit_logs` ekleme (head kilidi) + `loglar/dogrula` mantığı + test (bozulmuş zincir yakalanıyor mu)

### Faz 2 — Kimlik doğrulama (sunucu)
8. [ ] **S-08** `auth/kayit`, `auth/giris`, `auth/yenile`, `auth/cikis`, `auth/ben` (JWT, parola hash, refresh token hash'li saklama, hız sınırı)
9. [ ] **S-09** Auth middleware + `evId` üyelik middleware'i (üye değilse 404) + "başkasının mesajını göremez" testleri
10. [ ] **S-10** Ev oluşturma, davet kodu, eve katılma uç noktaları
11. [ ] **S-19** Geliştirme seed'i `server/tool/seed_dev.dart`: iki test hesabı (kiracı, ev sahibi) + örnek ev + üyelikler; yalnızca `APP_ENV=development`, parolalar `.env`'den

### Faz 3 — Kayıt uç noktaları (sunucu)
12. [ ] **S-11** Dosya servisi: `POST /dosyalar` (multipart, tür/boyut doğrulama, sunucuda SHA-256), indir, doğrula
13. [ ] **S-12** Sözleşme (sürümlü) + dekont uç noktaları
14. [ ] **S-13** Demirbaş uç noktaları (ekle, listele, düzeltme, onay/itiraz)
15. [ ] **S-14** Bildirim uç noktaları (oluştur, listele, detay, okundu, yanıt)
16. [ ] **S-15** Mesaj uç noktaları (`mesaj-gonder`, liste) + log listeleme
17. [ ] **S-16** Idempotency-Key middleware'i + uçtan uca sunucu testleri

### Faz 4 — Uygulama temeli (Flutter)
18. [ ] **A-01** İstemci ağ katmanı: `dio` entegrasyonu, token ekleme/yenileme, hata → `Result`, repository ve use case iskeletleri
19. [ ] **A-02 (Geçici: Tuba / Nihai: Sümeyye)** Tema ve ortak widget'lar (`core/theme`): renkler, yazı tipi, buton, kart, durum etiketi, boş/hata/yükleniyor bileşenleri
20. [ ] **A-03 (Sümeyye / Geçici mock: Tuba)** Açılış (Splash) ekranı tasarımı + oturum kontrolü/yönlendirme + ilk açılış hukuki uyarısı (bir kez, Hive'a onay) — `project.md` §7.1
21. [ ] **A-04 (Sümeyye / Geçici mock: Tuba)** Giriş / Kayıt ekranı tasarımı ve kodu (doğrulama, Türkçe hata metinleri, 429 mesajı, token'ı secure storage'a yazma, kayıtta rol seçimi yok) — `project.md` §7.1
22. [ ] **A-15 (Sümeyye / Geçici mock: Tuba)** Kiracı Modu / Ev Sahibi Modu rol değiştirme: iki test oturumu (secure storage), üstte "TEST MODU" şeridi, geçişte durum sıfırlama, yalnızca `kDebugMode` + `DEV_TOOLS=true`; mock repository desteği; release build'de görünmediğinin doğrulanması — `project.md` §7.2, `skills/role-switch-dev`
23. [ ] **A-05** Ana sayfa (ev listesi), ev oluştur, davet kodu üret/gir, ev özeti (merkez) ekranı

### Faz 5 — Özellik ekranları (Flutter)
24. [ ] **A-06** Kira & Ev Kaydı detay ekranı (adres, tutar, tarihler, depozito, sürüm geçmişi, yeni sürüm formu)
25. [ ] **A-07** Demirbaş formu (`image_picker`, çoklu fotoğraf) + demirbaş listesi + onay/itiraz
26. [ ] **A-08** Belgeler ekranı: sözleşme PDF'i ve dekont seçme (`file_picker`), yükleme, türüne göre listeleme; dekont formu
27. [ ] **A-09** Talep / Bildirim oluşturma ekranı + bildirim geçmişi/detay (zaman damgası, okundu, yanıt)
28. [ ] **A-10** Ev fotoğrafları ekranı (oda bazlı çekme/yükleme)
29. [ ] **A-11** Mesajlar ekranı (`mesaj-gonder`)
30. [ ] **A-12** Zaman çizelgesi + "Zinciri doğrula" ekranı
31. [ ] **A-13** Profil / ayarlar / hakkında (çıkış, hukuki metin)
32. [ ] **A-14** Çevrimdışı taslak akışı (Hive) — "taslak, resmi değil" etiketi

### Faz 6 — Birleştirme
33. [ ] **S-17** Uçtan uca test: iki kullanıcıyla tam senaryo (ev kur → davet → sözleşme → demirbaş → dekont → bildirim → mesaj → log doğrulama), hata düzeltmeleri
34. [ ] **S-18** README / ortam kurulum adımlarının ve `docs/`'un son güncellemesi

## Engeller / Bekleyen Kararlar
## Çözülen / Kesinleşen Kararlar (2026-10-24)
| Konu | Karar | Not |
|---|---|---|
| Cihaz içi veri paketi | **Hive** | Taslaklar ve önbellek için Hive kutuları kullanılacak |
| Sunucu çatısı | **Dart shelf + shelf_router** | Kesinleşti |
| Veritabanı ve ortamı | **PostgreSQL (Docker)** | Docker container üzerinde `tuba:123456@localhost:5432/shelf_db` hazır |
| Ağ paketi | **dio** | İstemci ağ iletişimi Dio ile yapılacak |
| Yönlendirme (Routing) | **go_router** | Onaylandı |
| Parola hash algoritması | **argon2** | Kesinleşti |
| Sunucu dosya depolama | **disk (`storage/`)** | İlk sürüm disk |
| İş bölümü ve Frontend yaklaşımı | **Tuba (Çekirdek + Mock Frontend), Sümeyye (Nihai Frontend)** | Sümeyye projeye başlayana kadar frontend ekranları Tuba tarafından iş görecek temel mock sayfalar olarak hazırlanacak, Sümeyye dahil olunca güncelleyecek |
| Flutter & Dart SDK | **Kurulu** | `/snap/bin/flutter` yolu ve Dart hazır |

## Engeller / Kalan Bekleyen Kararlar
| Konu | Kim karar verecek | Not |
|---|---|---|
| Tasarım: kesin renk paleti ve yazı tipi | Sümeyye + Tuba | `project.md` §8'deki değerler öneridir, Sümeyye başlayınca kesinleştirecek |
| Proje kesin adı | Tuba + Sümeyye | Şimdilik "Güvenli Kira" |
| Aynı evde kaç kiracı/ev sahibi olabilir | Tuba + Sümeyye | Şimdilik 1 + 1 |
| Rol bazlı bildirim türleri (kiracı/ev sahibi hangi türleri gönderebilir) | Tuba + Sümeyye | Öneri `project.md` §7.2'de; kesinleşirse sunucuda da doğrulanır |
| Logo / uygulama simgesi ve slogan | Sümeyye + Tuba | Geçici: kalkan + ev ikonu, "Kayıt altında, güvende." |
| Test modu şeridi renkleri ve konumu | Sümeyye | Öneri: kiracı turkuaz, ev sahibi lacivert, ekranın üstünde ince şerit |
| Hukuki geçerlilik / KVKK metinleri | Hukukçu | Uygulama iddia etmez |

## Bilinen Hatalar
- (şimdilik yok)

## Notlar
- `image_picker` PDF seçemez; PDF için `file_picker`.
- Sunucu ve istemci **yalnızca Dart**. Migration'lar `.sql` (istisna).
- Resmi zaman sadece sunucuda üretilir; istemci saati `client_reported_at` olarak bilgi amaçlıdır.
- Kayıt güncellenmez/silinmez; düzeltme yeni kayıtla yapılır (`supersedes_id`).
- Şema veya API değişirse önce `docs/veritabani.md` / `docs/api.md` güncellenir.
- Uygulama ekranları sunucu uç noktaları hazır olmadan yazılırsa `docs/api.md`'deki sözleşmeye uygun sahte (mock) veri kaynağıyla geliştirilir; gerçek bağlantı sonra yapılır.
- Rol değiştirme (A-15) **yalnızca geliştirme sürümündedir**; sunucuda özel bir uç nokta yoktur. İki gerçek test hesabı arasında oturum değiştirir (S-19 seed'i veya mock).
- A-03/A-04/A-15 için tema (A-02) gerekir; tema henüz yoksa geçici `AppTheme` ile başla, sonra token'lara taşı.
- Bu dosyayı ve `done.md`'yi her görev sonunda güncelle.
