# Progress

> Ajan her görevde günceller. Biten maddeler `done.md`'ye taşınır.
> Son güncelleme: 2026-10-24

## Şu An Üzerinde Çalışılan
| Görev | Branch | Durum | Not |
|---|---|---|---|
| Henüz başlanmadı | - | - | İlk görev: T-01 (iskelet) |

## Sıradaki Görevler (öncelik sırasıyla)
Sorumlu: **T** = Tuba, **A** = Arkadaş. Ajan sadece sıradaki `[ ]` görevi yapar.

### Faz 0 — İskelet
1. [ ] **T-01 (T)** Monorepo iskeleti: `app/` (Flutter), `server/` (Dart), `docs/`, `skills/`; Clean Architecture klasörleri; `.gitignore` (`.env`, `storage/`)
2. [ ] **T-02 (T)** İstemci cihaz içi veri kurulumu: Hive (taslak + önbellek kutuları), `flutter_secure_storage` (token) — karar bekliyor, aşağıya bak
3. [ ] **T-03 (T)** Temel domain entity'leri ve modeller: `Property`(Ev), `Lease`(Sözleşme), `Receipt`(Dekont), `Notice`/`AuditLog`(Log/Bildirim), `User`, `InventoryItem`, `Message`, `StoredFile` (+ JSON dönüşümleri, birim test)

### Faz 1 — Sunucu temeli
4. [ ] **T-04 (T)** `server/` shelf iskeleti, config (.env), hata middleware'i, `GET /saglik`, docker-compose ile PostgreSQL
5. [ ] **T-05 (T)** Migration'lar: `docs/veritabani.md`'deki tüm tablolar + `forbid_mutation` trigger'ları + yetki REVOKE
6. [ ] **T-06 (T)** `TimestampService` (tek zaman otoritesi) + SHA-256 yardımcıları + birim test
7. [ ] **T-07 (T)** Hash zinciri servisi: `audit_logs` ekleme (head kilidi) + `loglar/dogrula` mantığı + test (bozulmuş zincir yakalanıyor mu)

### Faz 2 — Kimlik doğrulama
8. [ ] **T-08 (T)** `auth/kayit`, `auth/giris`, `auth/yenile`, `auth/cikis`, `auth/ben` (JWT, parola hash, refresh token hash'li saklama, hız sınırı)
9. [ ] **T-09 (T)** Auth middleware + `evId` üyelik middleware'i (üye değilse 404) + "başkasının mesajını göremez" testleri
10. [ ] **T-10 (T)** Ev oluşturma, davet kodu, eve katılma uç noktaları

### Faz 3 — Kayıt uç noktaları
11. [ ] **T-11 (T)** Dosya servisi: `POST /dosyalar` (multipart, tür/boyut doğrulama, sunucuda SHA-256), indir, doğrula
12. [ ] **T-12 (T)** Sözleşme (sürümlü) + dekont uç noktaları
13. [ ] **T-13 (T)** Demirbaş uç noktaları (ekle, listele, düzeltme, onay/itiraz)
14. [ ] **T-14 (T)** Bildirim uç noktaları (oluştur, listele, detay, okundu, yanıt)
15. [ ] **T-15 (T)** Mesaj uç noktaları (`mesaj-gonder`, liste) + log listeleme
16. [ ] **T-16 (T)** Idempotency-Key middleware'i + uçtan uca sunucu testleri

### Faz 4 — İstemci veri katmanı ve ekranlar (Tuba)
17. [ ] **T-17 (T)** İstemci ağ katmanı (token ekleme, yenileme, hata → `Result`), repository'ler, use case'ler
18. [ ] **T-18 (T)** Kira & Ev Kaydı detay ekranı (adres, tutar, tarihler, depozito, sürüm geçmişi)
19. [ ] **T-19 (T)** Demirbaş formu (`image_picker`, çoklu fotoğraf) + demirbaş listesi + onay durumu
20. [ ] **T-20 (T)** Belgeler ekranı: sözleşme PDF'i ve dekont seçme (`file_picker`), yükleme, türüne göre listeleme; dekont formu
21. [ ] **T-21 (T)** Talep / Bildirim oluşturma ekranı + bildirim geçmişi (zaman damgası, okundu bilgisi)
22. [ ] **T-22 (T)** Ev fotoğrafları ekranı (oda bazlı çekme/yükleme)
23. [ ] **T-23 (T)** Çevrimdışı taslak akışı (Hive) — "taslak, resmi değil" etiketi

### Faz 5 — Arkadaşın tarafı (öneri, netleşecek)
24. [ ] **A-01 (A)** Tema (`core/theme`), navigasyon, ana sayfa
25. [ ] **A-02 (A)** Giriş / kayıt ekranları (`auth` API'sini kullanır)
26. [ ] **A-03 (A)** Mesajlar ekranı, zaman çizelgesi + log doğrulama ekranı

### Faz 6 — Birleştirme
27. [ ] **T-24 (T+A)** Entegrasyon, iki kullanıcıyla tam senaryo testi, hata düzeltmeleri
28. [ ] **T-25 (T)** README/ortam kurulum adımlarının güncellenmesi

## Engeller / Bekleyen Kararlar
| Konu | Kim karar verecek | Not |
|---|---|---|
| Cihaz içi veri: Hive mi yerel JSON mu | Tuba | Öneri: Hive (kutular, hızlı); T-02 öncesi kesinleşmeli |
| Sunucu çatısı: `shelf` mi `dart_frog` mu | Tuba | Öneri: `shelf` + `shelf_router` (az bağımlılık) |
| Veritabanı: PostgreSQL (öneri) mi SQLite mı | Tuba | Trigger/zincir tasarımı PostgreSQL'e göre yazıldı |
| Sunucuyu nerede çalıştıracağız (bulut/yerel) | Tuba + arkadaş | Geliştirmede docker-compose |
| Sunucu dosya depolama: disk mi S3 mü | Tuba | İlk sürüm disk |
| Ağ paketi: `dio` mu `http` mi | Tuba | |
| Parola hash: `bcrypt` mi `argon2` mi | Tuba | Paket varlığı/bakımı kontrol edilecek |
| Proje kesin adı | Tuba + arkadaş | Şimdilik "Güvenli Kira" |
| İş bölümü (Faz 5 + mesajlaşma/zaman çizelgesi kimde) | Tuba + arkadaş | Şu an öneri |
| Aynı evde kaç kiracı/ev sahibi olabilir | Tuba + arkadaş | Şimdilik 1 + 1 |
| Hukuki geçerlilik / KVKK metinleri | Hukukçu | Uygulama iddia etmez |

## Bilinen Hatalar
- (şimdilik yok)

## Notlar
- `image_picker` PDF seçemez; PDF için `file_picker`.
- Sunucu ve istemci **yalnızca Dart**. Migration'lar `.sql` (istisna).
- Resmi zaman sadece sunucuda üretilir; istemci saati `client_reported_at` olarak bilgi amaçlıdır.
- Kayıt güncellenmez/silinmez; düzeltme yeni kayıtla yapılır (`supersedes_id`).
- Arkadaşın klasörlerine (`core/theme`, `auth`, `home`, `messages`, `timeline`) dokunma.
- Şema veya API değişirse önce `docs/veritabani.md` / `docs/api.md` güncellenir.
- Bu dosyayı ve `done.md`'yi her görev sonunda güncelle.
