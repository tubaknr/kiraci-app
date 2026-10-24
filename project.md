# Güvenli Kira (çalışma adı)

> Bu dosya projenin "anayasası"dır. Ajan her oturumda ilk bunu okur.
> Değişiklik nadirdir; kapsam değişirse önce burası güncellenir.
> Ayrıntılı kaynaklar: `docs/veritabani.md` (tablolar, ilişkiler, değiştirilemezlik) ve `docs/api.md` (uç noktalar).

## 1. Amaç
Kiracı ve ev sahibi arasında yaşanabilecek her türlü soruna karşı sözleşmeleri, ödeme dekontlarını, ev ve demirbaş fotoğraflarını, mesajları ve resmi nitelikli bildirimleri **sunucu saatiyle damgalayıp değiştirilemez şekilde** kayıt altına alan bir mobil uygulama ve sunucu. Amaç, olası bir hukuki süreçte iki tarafın da hakkını koruyan, güvenilir bir kayıt ortamı sağlamaktır.

> Hukuki not: Uygulama hukuki danışmanlık vermez. Kayıtların mahkemede delil olarak değeri ayrıca bir hukukçu tarafından değerlendirilmelidir. Arayüzde "hukuken geçerlidir" gibi kesin ifadeler KULLANILMAZ; bunun yerine "kayıt altına alındı" denir. Bu uyarı ilk açılışta ve "Hakkında" ekranında gösterilir.

## 2. Hedef Kitle
- **Kiracılar:** eve girişte durumu, aylık ödemelerini ve taleplerini belgelemek isteyenler
- **Ev sahipleri:** demirbaş, depozito, ödeme ve tadilat süreçlerini kayıt altına almak isteyenler
- Her ev (kayıt) iki taraflıdır: bir ev sahibi + bir kiracı. Bir kullanıcı birden fazla evde farklı rollerde olabilir.

## 3. Teknoloji
Kural: **kodun tamamı Dart/Flutter**. İstemci Flutter, sunucu da Dart. (Veritabanı şeması `.sql` migration dosyalarıyla tanımlanır; bu istisnadır.)

| Katman | Seçim |
|---|---|
| İstemci | Flutter / Dart, Clean Architecture |
| Durum yönetimi | Provider |
| Cihaz içi veri | Hive (önbellek + gönderilmemiş taslaklar). Alternatif: yerel JSON — karar `progress.md`'de |
| Token saklama (istemci) | `flutter_secure_storage` (Hive'a token yazılmaz) |
| Ağ | `dio` (ya da `http`) — ajan paketi eklemeden önce sorar |
| Fotoğraf | `image_picker` (kamera/galeri). NOT: PDF seçemez |
| PDF / belge seçme | `file_picker` |
| Sunucu | Dart, `shelf` + `shelf_router` |
| Veritabanı | PostgreSQL (`postgres` paketi), geliştirmede docker-compose |
| Kimlik doğrulama | JWT (kısa ömürlü access + yenileme token'ı), şifre hash'i için `bcrypt` veya `argon2` |
| Dosya depolama | Sunucu diskinde `storage/` (ev bazlı klasör); ileride S3 uyumlu depolama |
| Bütünlük | SHA-256 (`crypto` paketi) |
| Hedef platform | Android, iOS (sunucu: Linux/Docker) |

## 4. Özellikler
| # | Özellik | Öncelik | Açıklama | Sorumlu |
|---|---|---|---|---|
| 1 | Proje iskeleti | Yüksek | Monorepo, Clean Architecture klasörleri, cihaz içi veri kurulumu | Tuba |
| 2 | Temel veri modelleri | Yüksek | Ev, Sözleşme, Dekont, Log/Bildirim (+ Kullanıcı, Demirbaş, Mesaj, Dosya) | Tuba |
| 3 | Veritabanı tasarımı | Yüksek | Tablolar, ilişkiler, değiştirilemez loglar (`docs/veritabani.md`) | Tuba |
| 4 | Kimlik doğrulama (Auth) | Yüksek | Kayıt/giriş, JWT, yenileme, evlere üyelik; kimse başkasının evini/mesajını göremez | Tuba |
| 5 | Zaman damgası servisi | Yüksek | Her kayıt sunucu saatiyle damgalanır; istemci saati resmi sayılmaz | Tuba |
| 6 | Değiştirilemezlik (immutability) | Yüksek | Append-only tablolar, DB trigger'ları, hash zinciri, dosya SHA-256 | Tuba |
| 7 | API uç noktaları | Yüksek | `/mesaj-gonder`, `/delil-yukle` gibi tüm servisler (`docs/api.md`) | Tuba |
| 8 | Kira & Ev Kaydı detay ekranı | Yüksek | Adres, tutar, tarihler, depozito | Tuba |
| 9 | Demirbaş formu + listesi | Yüksek | Fotoğraflı ("kombi sağlam", "parke çizik") kayıt, karşı tarafın onayı | Tuba |
| 10 | Belge yükleme + listeleme | Yüksek | Sözleşme PDF'i ve ödeme dekontu seçme, türüne göre liste | Tuba |
| 11 | Talep / Bildirim oluşturma | Yüksek | "Kira ödendi", "Tadilat talebi" vb. zaman damgalı resmi ileti, okundu kaydı | Tuba |
| 12 | Ev fotoğrafları | Orta | Oda bazlı çekme/yükleme, her fotoğrafa sunucu damgası + SHA-256 | Tuba |
| 13 | Giriş/kayıt ekranları, ana sayfa, navigasyon, tema | Yüksek | Genel arayüz kabuğu (frontend) | Arkadaş |
| 14 | Mesajlaşma ekranı | Orta | `mesaj-gonder` servisini kullanır | Arkadaş (öneri) |
| 15 | Olay zaman çizelgesi + log doğrulama ekranı | Orta | Logları sıralı gösterir, zincir doğrulamasını tetikler | Arkadaş (öneri) |
| 16 | Dışa aktarma (PDF özet raporu) | Düşük | Hukuki süreçte kullanılacak özet — ilk sürümde YOK | — |

> Görev dağılımı önerisi bu tablodadır; arkadaşla netleştirilince burası güncellenir.

## 5. Mimari

```
[Flutter uygulaması] --HTTPS + JWT--> [Dart sunucu (shelf)] --> [PostgreSQL]
   Hive (taslak/önbellek)                  |--> storage/ (dosyalar)
   secure storage (token)                  |--> TimestampService (tek zaman otoritesi)
```

### 5.1 Clean Architecture (istemci ve sunucu için aynı fikir)
Katmanlar ve bağımlılık yönü: **presentation → domain ← data**. `domain` hiçbir şeye (Flutter, HTTP, Hive, SQL) bağımlı olmaz.

| Katman | İçerik | Kural |
|---|---|---|
| domain | entity'ler, repository arayüzleri, use case'ler | Saf Dart; paket bağımlılığı yok (`equatable` hariç) |
| data | model (JSON/DB dönüşümü), datasource (remote/local), repository gerçeklemeleri | Domain arayüzlerini uygular |
| presentation | ekran, widget, Provider (ChangeNotifier) | Sadece use case çağırır, repository'ye/Hive'a doğrudan erişmez |

Hata yönetimi: use case'ler `Result<T>` (başarı/hata) döner; ham exception arayüze çıkmaz.

### 5.2 Zaman otoritesi
Resmi zaman **yalnızca sunucuda** `TimestampService.now()` ile (UTC) üretilir. İstemcinin gönderdiği saat, `client_reported_at` olarak sadece bilgi için saklanır ve hiçbir yerde resmi sayılmaz. İleride harici güvenilir zaman damgası (RFC 3161 TSA) eklenebilir.

## 6. Güvenlik ve Değiştirilemezlik İlkeleri
1. **Sunucu saati tek otorite.** Kayıt, `server_time` ile damgalanır; istemci saati değiştirilse bile kayıt zamanı değişmez.
2. **Append-only.** `files`, `notices`, `messages`, `receipts`, `inventory_items`, `leases` (sürümlü), `audit_logs` tablolarında `UPDATE` ve `DELETE` yasaktır; veritabanı trigger'ı ile engellenir. Düzeltme = yeni kayıt (`supersedes_id` ile eskisine bağlanır).
3. **Hash zinciri.** Her `audit_logs` satırı bir önceki satırın hash'ini içerir (`prev_hash` → `entry_hash`); zincir ev bazlıdır. Araya girilen/silinen kayıt zinciri bozar ve `GET /evler/{evId}/loglar/dogrula` ile tespit edilir.
4. **Dosya bütünlüğü.** Yüklenen her dosyanın SHA-256 özeti **sunucuda** hesaplanır ve kaydedilir; indirmede/doğrulamada tekrar hesaplanıp karşılaştırılır.
5. **Yetki = üyelik.** Her istek JWT'den kullanıcıyı çıkarır; erişilen `evId` için `property_members` kaydı yoksa `403` (kaynağın varlığı da sızdırılmaz → `404`). Mesajlar, dosyalar, loglar yalnızca o evin iki üyesine açıktır.
6. **Token.** Access token kısa ömürlü (ör. 15 dk), yenileme token'ı DB'de **hash'lenmiş** saklanır, çıkışta iptal edilir. JWT sırrı ortam değişkenindedir.
7. **Parola.** Düz metin saklanmaz; `bcrypt`/`argon2` ile hash'lenir. Giriş denemelerine hız sınırı uygulanır.
8. **Girdi doğrulama.** Dosya türü (mime + uzantı), boyut sınırı (ör. 15 MB), alan uzunlukları sunucuda doğrulanır; istemci doğrulaması yeterli sayılmaz.
9. **Sır yönetimi.** `.env`, anahtarlar, `storage/` içeriği git'e girmez. Loglara token, parola, kişisel veri yazılmaz.
10. **Kişisel veri (KVKK).** Yalnızca gerekli veri toplanır; kullanıcı kendi verisini dışa aktarma/silme talebi sürecini ileride tanımlayacağız (hukuki silme yasağı ile çelişen noktalar için hukukçuya danışılır).
11. **İdempotentlik.** Yazma isteklerinde `Idempotency-Key` başlığı desteklenir; ağ kopmasında aynı kayıt iki kez oluşmaz.
12. **Çevrimdışı.** İstemcide oluşturulan içerik "taslak"tır; sunucuya ulaşana kadar resmi değildir ve arayüzde bu açıkça belirtilir.

## 7. Sayfalar / Ekranlar
| Ekran | Dosya (app/lib/features/...) | Ne gösterir | Sorumlu |
|---|---|---|---|
| Kira & Ev Kaydı Detay | lease/presentation/screens/lease_detail_screen.dart | Adres, kira tutarı, başlangıç/bitiş, depozito, sürüm geçmişi | Tuba |
| Demirbaş Formu | inventory/presentation/screens/inventory_form_screen.dart | Oda, kalem, durum, not, fotoğraf (çoklu) | Tuba |
| Demirbaş Listesi | inventory/presentation/screens/inventory_list_screen.dart | Kalemler, fotoğraflar, karşı taraf onay durumu | Tuba |
| Belgeler | documents/presentation/screens/documents_screen.dart | Sözleşme PDF / dekont seçme + türüne göre liste | Tuba |
| Dekont Ekle | documents/presentation/screens/receipt_form_screen.dart | Dönem, tutar, dosya | Tuba |
| Talep / Bildirim Oluştur | notices/presentation/screens/create_notice_screen.dart | Tür ("Kira ödendi", "Tadilat talebi"...), açıklama, ek | Tuba |
| Bildirim Geçmişi / Detay | notices/presentation/screens/notice_list_screen.dart | Zaman damgalı liste, okundu bilgisi | Tuba |
| Ev Fotoğrafları | photos/presentation/screens/house_photos_screen.dart | Oda bazlı çekme/yükleme | Tuba |
| Giriş / Kayıt | auth/presentation/... | Form ekranları | Arkadaş |
| Ana Sayfa + Navigasyon | home/presentation/... | Ev listesi, kısayollar | Arkadaş |
| Mesajlar | messages/presentation/... | Ev bazlı mesajlaşma | Arkadaş (öneri) |
| Zaman Çizelgesi | timeline/presentation/... | Log akışı + doğrulama | Arkadaş (öneri) |

## 8. Tasarım
- Tema, renk, yazı tipi ve ortak widget'lar **arkadaşın** sorumluluğundadır (`app/lib/core/theme`). Tuba'nın ekranları yalnızca bu temayı kullanır, kendi stilini eklemez.
- Genel his: sade, güven veren, resmi ama sıcak.
- Her kritik ekranda "Kaydedildi — {sunucu tarihi/saati}" bilgisi görünür; yükleme ve hata durumları (loading/empty/error) her listede tasarlanır.
- Metinler Türkçe; tarih biçimi `gg.AA.yyyy SS:dd`; para birimi ₺ (veritabanında kuruş cinsinden tam sayı).

## 9. Kapsam Dışı (YAPMA)
- Dart/Flutter dışında bir dilde sunucu veya istemci yazma
- Gerçek e-imza, noter, mahkeme (UYAP) entegrasyonu
- "Hukuken geçerlidir/delildir" gibi kesin ifadeler
- Kayıt güncelleme veya silme (düzeltme yeni kayıtla yapılır)
- İstemci saatini resmi zaman olarak kullanma
- Kullanıcıya sormadan paket ekleme / sürüm yükseltme
- Arkadaşın klasörlerindeki (core/theme, auth ekranları, home, messages, timeline) dosyaları değiştirme
- Sesli/görüntülü arama, WhatsApp içe aktarma (ilk sürümde yok)

## 10. Başarı Kriterleri
- [ ] İskelet kuruldu; `flutter analyze` ve `dart analyze` hatasız
- [ ] Kayıt/giriş çalışıyor; başka kullanıcının evi/mesajı/dosyası `404/403` dönüyor (test var)
- [ ] Her yazma işlemi sunucu zamanıyla damgalanıyor; `UPDATE/DELETE` denemeleri DB tarafından reddediliyor (test var)
- [ ] Hash zinciri doğrulama uç noktası bozulmuş kaydı yakalıyor (test var)
- [ ] Kira detay, demirbaş formu, belge listesi ve bildirim oluşturma ekranları sunucuyla uçtan uca çalışıyor
- [ ] Dosya yüklemede SHA-256 sunucuda hesaplanıp doğrulanabiliyor
- [ ] Arkadaşın ekranlarıyla birleşip iki kullanıcıyla (kiracı + ev sahibi) tam senaryo çalışıyor

## 11. Klasör Yapısı (monorepo)
```
guvenli_kira/
├── project.md
├── agents.md
├── progress.md
├── done.md
├── README.md
├── docs/
│   ├── veritabani.md
│   └── api.md
├── skills/
│   ├── git-workflow/SKILL.md
│   ├── flutter-feature/SKILL.md
│   ├── api-endpoint/SKILL.md
│   └── immutable-record/SKILL.md
├── app/                         # Flutter istemci
│   └── lib/
│       ├── core/                # tema(arkadaş), hata, ağ, di, yardımcılar
│       └── features/
│           ├── auth/ lease/ inventory/ documents/ notices/ photos/ messages/ timeline/ home/
│               ├── domain/{entities,repositories,usecases}
│               ├── data/{models,datasources,repositories}
│               └── presentation/{screens,widgets,providers}
└── server/                      # Dart sunucu
    ├── bin/server.dart
    ├── migrations/              # .sql dosyaları (sıralı)
    ├── lib/
    │   ├── core/                # config, hata, timestamp_service, hash yardımcıları
    │   ├── features/<ozellik>/{domain,data,presentation(handlers)}
    │   └── middleware/          # auth, hata, rate-limit, idempotency
    ├── storage/                 # yüklenen dosyalar (git'e GİRMEZ)
    └── test/
```

## 12. Ortam Değişkenleri (`server/.env`, git'e girmez; örnek: `.env.example`)
`DATABASE_URL`, `JWT_SECRET`, `ACCESS_TOKEN_MINUTES`, `REFRESH_TOKEN_DAYS`, `STORAGE_PATH`, `MAX_UPLOAD_MB`, `PORT`
