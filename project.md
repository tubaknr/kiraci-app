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
| Cihaz içi veri | Hive (önbellek + gönderilmemiş taslaklar) |
| Token saklama (istemci) | `flutter_secure_storage` (Hive'a token yazılmaz) |
| Ağ | `dio` |
| Yönlendirme | `go_router` |
| Biçimlendirme / yerelleştirme | `intl` (tr_TR tarih ve para biçimi) |
| Arayüz | Material 3, tek `AppTheme` (açık tema; koyu tema sonra) |
| Fotoğraf | `image_picker` (kamera/galeri). NOT: PDF seçemez |
| PDF / belge seçme | `file_picker` |
| Sunucu | Dart, `shelf` + `shelf_router` |
| Veritabanı | PostgreSQL (`postgres` paketi), geliştirmede Docker (`postgresql://tuba:123456@localhost:5432/shelf_db`) |
| Kimlik doğrulama | JWT (kısa ömürlü access + yenileme token'ı), şifre hash'i için `argon2` |
| Dosya depolama | Sunucu diskinde `storage/` (ev bazlı klasör); ileride S3 uyumlu depolama |
| Bütünlük | SHA-256 (`crypto` paketi) |
| Hedef platform | Android, iOS (sunucu: Linux/Docker) |

## 4. Özellikler
Proje **iki parçadan** oluşur: sunucu ve Flutter uygulaması. Aşağıdaki tablo tüm projeyi kapsar; görevleri kimin üstleneceği `progress.md`'de "Şu An Üzerinde Çalışılan" tablosuyla belirlenir.

| # | Özellik | Katman | Öncelik | Açıklama |
|---|---|---|---|---|
| 1 | Proje iskeleti | Genel | Yüksek | Monorepo, Clean Architecture klasörleri, cihaz içi veri kurulumu |
| 2 | Temel veri modelleri | Genel | Yüksek | Ev, Sözleşme, Dekont, Log/Bildirim (+ Kullanıcı, Demirbaş, Mesaj, Dosya) |
| 3 | Veritabanı tasarımı | Sunucu | Yüksek | Tablolar, ilişkiler, değiştirilemez loglar (`docs/veritabani.md`) |
| 4 | Kimlik doğrulama (Auth) | Sunucu + İstemci | Yüksek | Kayıt/giriş, JWT, yenileme, evlere üyelik; kimse başkasının evini/mesajını göremez |
| 5 | Zaman damgası servisi | Sunucu | Yüksek | Her kayıt sunucu saatiyle damgalanır; istemci saati resmi sayılmaz |
| 6 | Değiştirilemezlik (immutability) | Sunucu | Yüksek | Append-only tablolar, DB trigger'ları, hash zinciri, dosya SHA-256 |
| 7 | API uç noktaları | Sunucu | Yüksek | `/mesaj-gonder`, `/delil-yukle` gibi tüm servisler (`docs/api.md`) |
| 8 | İstemci ağ katmanı + çevrimdışı taslak | İstemci | Yüksek | Token ekleme/yenileme, `Result` dönüşümü, Hive taslak ve önbellek |
| 9 | Tema ve ortak widget'lar | İstemci | Yüksek | Renk, yazı tipi, buton, kart, boş/hata/yükleniyor bileşenleri |
| 10 | Açılış (Splash) ekranı tasarımı, oturum yönlendirme, ilk açılış uyarısı | İstemci | Yüksek | Ayrıntı §7.1 |
| 11 | Giriş / kayıt ekranları tasarımı ve kodu | İstemci | Yüksek | `auth` API'sini kullanır; ayrıntı §7.1 |
| 12 | Ana sayfa: ev listesi, ev oluştur, davet kodu | İstemci | Yüksek | Üyesi olunan evler, yeni ev, koda katılma |
| 13 | Kira & Ev Kaydı detay ekranı | İstemci | Yüksek | Adres, tutar, tarihler, depozito, sürüm geçmişi |
| 14 | Demirbaş formu + listesi | İstemci | Yüksek | Fotoğraflı ("kombi sağlam", "parke çizik") kayıt, karşı tarafın onayı/itirazı |
| 15 | Belge yükleme + listeleme | İstemci | Yüksek | Sözleşme PDF'i ve ödeme dekontu seçme, türüne göre liste |
| 16 | Talep / Bildirim oluşturma | İstemci | Yüksek | "Kira ödendi", "Tadilat talebi" vb. zaman damgalı resmi ileti, okundu kaydı |
| 17 | Ev fotoğrafları | İstemci | Orta | Oda bazlı çekme/yükleme, sunucu damgası + SHA-256 |
| 18 | Mesajlaşma ekranı | İstemci | Orta | `mesaj-gonder` servisini kullanır; yalnızca evin iki üyesi |
| 19 | Zaman çizelgesi + log doğrulama | İstemci | Orta | Logları sıralı gösterir, hash zinciri doğrulamasını tetikler |
| 20 | Profil / ayarlar / hakkında | İstemci | Düşük | Hesap bilgisi, çıkış, hukuki uyarı metni |
| 21 | Rol değiştirme: Kiracı Modu / Ev Sahibi Modu (test) | İstemci (+ geliştirme seed'i) | Yüksek | Tek cihazda iki tarafı test etmek için; **yalnızca geliştirme sürümünde** (bkz. §7.2) |
| 22 | Dışa aktarma (PDF özet raporu) | İstemci + Sunucu | Düşük | İlk sürümde YOK |

### Görev sahipleri (netleşenler)
| Kişi | Görev |
|---|---|
| **Tuba** | Sunucu (#3–#7), iskelet ve modeller (#1–#2), istemci ağ katmanı (#8) ve özellik ekranları (#13–#20). Ayrıca Sümeyye projeye dahil olana kadar #9 Tema/ortak widget'lar ile #10, #11 ve #21 için iş görecek temel mock sayfaların/bileşenlerin hazırlanması |
| **Sümeyye** | Projeye dahil olduğunda: #10 Açılış (Splash) ekranı nihai tasarımı · #11 Giriş / Kayıt ekranı nihai tasarımı ve UI kodu · #21 "Kiracı Modu / Ev Sahibi Modu" rol değiştirme nihai arayüzü ve genel UI/UX (Frontend'e dair her şey) |

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
K. **Test modu üretimde yok.** Rol değiştirme (Kiracı/Ev Sahibi Modu) yalnızca geliştirme sürümünde çalışır; sunucuda rol atlatan, yetki devreden gizli uç nokta veya "test" bayrağı **bulunmaz**. Yetki her zaman gerçek hesap + `property_members` üyeliğinden gelir.

## 7. Sayfalar / Ekranlar
Yollar `app/lib/features/...` altındadır.

| Ekran | Dosya | Ne gösterir |
|---|---|---|
| Açılış (Splash) + Hukuki Uyarı | home/presentation/screens/splash_screen.dart | Oturum kontrolü, ilk açılış uyarısı |
| Giriş | auth/presentation/screens/login_screen.dart | E-posta + parola |
| Kayıt | auth/presentation/screens/register_screen.dart | Ad, e-posta, parola |
| Ana Sayfa (Ev Listesi) | home/presentation/screens/home_screen.dart | Evlerim, "Yeni ev", "Davet koduyla katıl" |
| Ev Oluştur / Davet | home/presentation/screens/create_property_screen.dart | Başlık, adres, rol; davet kodu üretme/girme |
| Ev Özeti (merkez) | home/presentation/screens/property_hub_screen.dart | Sekmeler/kısayollar: Kira, Demirbaş, Belgeler, Bildirimler, Mesajlar, Zaman Çizelgesi, Fotoğraflar |
| Kira & Ev Kaydı Detay | lease/presentation/screens/lease_detail_screen.dart | Adres, kira tutarı, başlangıç/bitiş, depozito, sürüm geçmişi |
| Demirbaş Formu | inventory/presentation/screens/inventory_form_screen.dart | Oda, kalem, durum, not, fotoğraf (çoklu) |
| Demirbaş Listesi | inventory/presentation/screens/inventory_list_screen.dart | Kalemler, fotoğraflar, karşı taraf onay durumu |
| Belgeler | documents/presentation/screens/documents_screen.dart | Sözleşme PDF / dekont seçme + türüne göre liste |
| Dekont Ekle | documents/presentation/screens/receipt_form_screen.dart | Dönem, tutar, dosya |
| Talep / Bildirim Oluştur | notices/presentation/screens/create_notice_screen.dart | Tür ("Kira ödendi", "Tadilat talebi"...), açıklama, ek |
| Bildirim Geçmişi / Detay | notices/presentation/screens/notice_list_screen.dart | Zaman damgalı liste, okundu bilgisi, yanıt |
| Ev Fotoğrafları | photos/presentation/screens/house_photos_screen.dart | Oda bazlı çekme/yükleme |
| Mesajlar | messages/presentation/screens/chat_screen.dart | Ev bazlı mesajlaşma |
| Zaman Çizelgesi | timeline/presentation/screens/timeline_screen.dart | Log akışı + "Zinciri doğrula" |
| Profil / Ayarlar / Hakkında | home/presentation/screens/settings_screen.dart | Hesap, çıkış, hukuki metin |
| Test Modu Şeridi + Rol Değiştirici (yalnızca geliştirme) | core/dev_tools/role_switcher_overlay.dart | Üstte "TEST MODU — Kiracı Modu / Ev Sahibi Modu" şeridi ve geçiş düğmesi |

### 7.1 Açılış ve Giriş / Kayıt Ekranı Tasarımı
Tasarım `project.md` §8'deki token'larla yapılır (tema henüz yoksa önce A-02 görevi veya geçici `AppTheme`).

**Açılış (Splash)**
- Ortada uygulama simgesi (geçici: kalkan + ev ikonu) ve ad "Güvenli Kira"; altında slogan önerisi: "Kayıt altında, güvende."
- Arka planda oturum kontrolü: geçerli token varsa → Ana Sayfa; yoksa → Giriş. Ağ yoksa son oturum Hive önbelleğinden açılır ve "çevrimdışı" etiketi gösterilir.
- Süre en fazla ~1,5 sn; oturum kontrolü uzun sürerse ilerleme göstergesi.
- **İlk açılışta hukuki uyarı** (tam ekran/alt sayfa): "Bu uygulama hukuki danışmanlık vermez; kayıtlar sunucu saatiyle damgalanır ve değiştirilemez şekilde saklanır." + "Anladım" düğmesi. Onay bilgisi Hive'a yazılır, bir daha çıkmaz.

**Giriş**
- Alanlar: e-posta, parola (göster/gizle). Düğme: "Giriş yap" (istek sürerken pasif + yükleniyor). Bağlantılar: "Hesabın yok mu? Kayıt ol".
- Doğrulama: e-posta biçimi, parola boş olamaz. Hata metinleri Türkçe ve sade ("E-posta veya parola hatalı", "Bağlantı kurulamadı").
- Hız sınırı (429) gelirse "Çok fazla deneme yaptınız, biraz bekleyin" gösterilir.
- Başarılı girişte access/refresh token `flutter_secure_storage`'a yazılır; ekran Ana Sayfa'ya geçer.

**Kayıt**
- Alanlar: ad soyad, e-posta, parola (en az 8 karakter), parola tekrar; kullanım/gizlilik onayı kutusu.
- Rol seçimi kayıtta YOKTUR: rol evden eve değişir ve ev oluşturulurken/davet kabul edilirken belirlenir (`property_members.role`).
- Başarılı kayıttan sonra doğrudan oturum açılır.

**Ortak kurallar:** klavye açıldığında alanlar kaymasın/taşmasın, dokunma alanı ≥ 48 dp, ekran okuyucu etiketleri, yatay ekranda taşma yok.

### 7.2 Rol Değiştirme Mekanizması (Kiracı Modu / Ev Sahibi Modu)
**Amaç:** Tek cihazda iki tarafı da denemek (ör. kiracı olarak bildirim gönder → ev sahibi olarak okundu/onay ver) ve ekranları iki rolle test etmek.

**Nasıl çalışır**
1. Rol bir **kullanıcı özelliği değil**, evdeki üyeliktir (`property_members.role`). Bu yüzden "mod değiştirmek" = iki gerçek **test hesabı** arasında oturum değiştirmektir. Sunucu yetkilendirmesi hiç gevşetilmez.
2. İki test oturumu `flutter_secure_storage`'da ayrı anahtarlarla tutulur: `dev_session_tenant`, `dev_session_landlord`. Anahtar kullanımı yalnızca geliştirme sürümünde.
3. Ekranın üstünde (`MaterialApp.builder` ile her ekranın üzerinde) ince bir **Test Modu şeridi** görünür: "TEST MODU — Kiracı Modu" (turkuaz) veya "TEST MODU — Ev Sahibi Modu" (lacivert). Şeritteki düğmeye dokununca rol değişir.
4. Değişimde: aktif token'lar yer değiştirir → Provider/önbellek durumu sıfırlanır → mevcut ev yeniden yüklenir → ekran, o evdeki gerçek role göre yeniden çizilir.
5. Arayüz rolü, açık evin `role` değerinden okur (sabit kodlanmaz). Önerilen farklar: kiracıda "Kira ödendi", "Tadilat talebi", "Arıza bildirimi"; ev sahibinde "Depozito talebi", "Uyarı"; her ikisinde "Diğer", "Tahliye bildirimi". Okundu/onay düğmeleri **karşı tarafa** görünür. (Kural kesinleşince sunucuda da doğrulanır — `progress.md` → Bekleyen Kararlar.)

**Etkinleştirme (iki koşul birden):** `kDebugMode` **ve** `--dart-define=DEV_TOOLS=true`. Release build'de kod yolu derlemeye girmez; şerit, anahtarlar ve geçiş mantığı yoktur.

**Test verisi:** `server/tool/seed_dev.dart` (yalnızca `APP_ENV=development`) iki test hesabı + bir örnek ev + üyelikler oluşturur. Parolalar repoda yazılı olmaz, `.env`'den okunur. Sunucu çalışmıyorsa aynı geçiş mock repository ile iki sahte kullanıcı üzerinden çalışır.

**Yapılmayacaklar:** sunucuda rol atlatan uç nokta, parolasız giriş, token'ı loglama, test modunu kullanıcıya gösterme.

## 8. Tasarım
> Aşağıdaki değerler **öneridir**; kesinleşince burası güncellenir. Tüm renk/font/boşluk değerleri tek yerde (`app/lib/core/theme/`) tanımlanır, ekranlar sadece bu token'ları kullanır.

- **Genel his:** sade, güven veren, resmi ama sıcak. Hukuki bir kayıt aracı olduğu için gösterişsiz ve okunaklı.
- **Renkler (öneri):** birincil lacivert `#1F3A5F`, vurgu turkuaz `#2A9D8F`, arka plan `#F7F8FA`, yüzey `#FFFFFF`, metin `#1B1F24`, ikincil metin `#5B6572`, başarı `#2E7D32`, uyarı `#B26A00`, hata `#C0392B`.
- **Yazı tipi:** sistem yazı tipi veya `Inter` (paket eklenecekse onay gerekir). Başlık 20–24, gövde 14–16, yardımcı metin 12.
- **Boşluk/şekil:** 8'in katları (8/16/24), kart köşesi 12, düğme yüksekliği 48.
- **Ortak bileşenler:** birincil/ikincil düğme, metin alanı, kart, durum etiketi (taslak / kaydedildi / onaylandı / itiraz), boş durum, hata durumu, yükleniyor iskeleti, "Kaydedildi — {sunucu tarihi}" satırı.
- **Zaman damgası gösterimi:** her kritik kayıtta "Kaydedildi — 24.10.2026 09:30" görünür; taslakta "Taslak — henüz resmi kayıt değil".
- **Dil/biçim:** Türkçe metin; tarih `gg.AA.yyyy SS:dd`; para ₺ (veritabanında kuruş tam sayısı).
- **Erişilebilirlik:** yeterli kontrast, en az 48 dp dokunma alanı, ekran okuyucu etiketleri.

## 9. Kapsam Dışı (YAPMA)
- Dart/Flutter dışında bir dilde sunucu veya istemci yazma
- Gerçek e-imza, noter, mahkeme (UYAP) entegrasyonu
- "Hukuken geçerlidir/delildir" gibi kesin ifadeler
- Kayıt güncelleme veya silme (düzeltme yeni kayıtla yapılır)
- İstemci saatini resmi zaman olarak kullanma
- Kullanıcıya sormadan paket ekleme / sürüm yükseltme
- Başkasının `Şu An Üzerinde Çalışılan` listesinde duran görevin dosyalarını izinsiz değiştirme
- Sesli/görüntülü arama, WhatsApp içe aktarma (ilk sürümde yok)
- Üretim sürümünde rol değiştirme / test modu bulunması; sunucuda rol atlatan gizli uç nokta

## 10. Başarı Kriterleri
- [ ] İskelet kuruldu; `flutter analyze` ve `dart analyze` hatasız
- [ ] Kayıt/giriş çalışıyor; başka kullanıcının evi/mesajı/dosyası `404/403` dönüyor (test var)
- [ ] Her yazma işlemi sunucu zamanıyla damgalanıyor; `UPDATE/DELETE` denemeleri DB tarafından reddediliyor (test var)
- [ ] Hash zinciri doğrulama uç noktası bozulmuş kaydı yakalıyor (test var)
- [ ] Giriş/kayıt, ev listesi, kira detay, demirbaş formu, belge listesi, bildirim oluşturma, mesajlar ve zaman çizelgesi ekranları sunucuyla uçtan uca çalışıyor
- [ ] Dosya yüklemede SHA-256 sunucuda hesaplanıp doğrulanabiliyor
- [ ] Açılış, giriş ve kayıt ekranları tasarıma uygun çalışıyor; ilk açılış uyarısı bir kez çıkıyor
- [ ] Tek cihazda Kiracı Modu ↔ Ev Sahibi Modu geçişiyle "bildirim gönder → okundu → onay" akışı denenebiliyor
- [ ] Release build'de test modu şeridi/kodu yok (build ile doğrulandı)
- [ ] İki kullanıcıyla (kiracı + ev sahibi) tam senaryo çalışıyor: ev kur → davet → sözleşme → demirbaş → dekont → bildirim → mesaj → log doğrulama

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
│       ├── core/                # tema, hata, ağ, di, yardımcılar, dev_tools/ (yalnız geliştirme: rol değiştirici)
│       └── features/
│           ├── auth/ home/ lease/ inventory/ documents/ notices/ photos/ messages/ timeline/
│               ├── domain/{entities,repositories,usecases}
│               ├── data/{models,datasources,repositories}
│               └── presentation/{screens,widgets,providers}
└── server/                      # Dart sunucu
    ├── bin/server.dart
    ├── tool/seed_dev.dart       # geliştirme test hesapları + örnek ev (yalnız APP_ENV=development)
    ├── migrations/              # .sql dosyaları (sıralı)
    ├── lib/
    │   ├── core/                # config, hata, timestamp_service, hash yardımcıları
    │   ├── features/<ozellik>/{domain,data,presentation(handlers)}
    │   └── middleware/          # auth, hata, rate-limit, idempotency
    ├── storage/                 # yüklenen dosyalar (git'e GİRMEZ)
    └── test/
```

## 12. Ortam Değişkenleri (`server/.env`, git'e girmez; örnek: `.env.example`)
`DATABASE_URL`, `JWT_SECRET`, `ACCESS_TOKEN_MINUTES`, `REFRESH_TOKEN_DAYS`, `STORAGE_PATH`, `MAX_UPLOAD_MB`, `PORT`, `APP_ENV` (`development`/`production`), `DEV_SEED_TENANT_EMAIL`, `DEV_SEED_LANDLORD_EMAIL`, `DEV_SEED_PASSWORD` (yalnız geliştirme)

Uygulama tarafı: test modu için `flutter run --dart-define=DEV_TOOLS=true` (yalnız debug).
