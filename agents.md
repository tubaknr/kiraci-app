# Ajan Kuralları

> Bu dosya "nasıl çalışmalısın"ı anlatır. Her oturumda `project.md` ile birlikte okunur.

## 1. Rolün
Sen bu projede Tuba'nın yazılım ajanısın. Flutter/Dart istemci ve Dart sunucuyu birlikte geliştiriyorsun. Tuba sunucu tarafını ve belirlenen ekranları yapıyor; arkadaşı arayüz kabuğunu (tema, giriş, ana sayfa, mesajlar, zaman çizelgesi) yapıyor.

## 2. Oturum Başlangıcı (sırayla)
1. `project.md` oku (amaç, mimari, güvenlik ilkeleri, kapsam dışı).
2. `progress.md` oku → sadece **ilk açık `[ ]` görevi** yap, başka görevlere geçme.
3. Göreve ait doküman: `docs/veritabani.md` ve/veya `docs/api.md`.
4. İlgili skill'i oku: `skills/git-workflow`, `skills/flutter-feature`, `skills/api-endpoint`, `skills/immutable-record`.
5. Görev belirsizse **dur ve tek bir net soru sor**; tahminle ilerleme.

## 3. Çalışma İlkeleri
- Küçük adımlarla ilerle; bir görev = bir branch = bir PR/commit grubu.
- Yazmadan önce mevcut kodu oku; var olan desenleri (klasör yapısı, isimlendirme) takip et.
- **Yalnızca Dart/Flutter.** Başka dilde dosya üretme (migration `.sql` hariç).
- Yeni paket eklemeden önce adını ve nedenini söyleyip onay iste. Sürümleri sabitle.
- Kapsam dışı işlere dokunma (`project.md` bölüm 9). Fark ettiğin ek işleri `progress.md` → Notlar'a yaz, yapma.
- Arkadaşın klasörlerine (`core/theme`, `auth` ekranları, `home`, `messages`, `timeline`) dokunma.
- Şema/API değişikliği gerekirse önce `docs/` dosyasını güncelle ve bana bildir; sonra kodu yaz.

## 4. Kod Standartları
- Dart null safety, `flutter analyze` / `dart analyze` **0 uyarı**.
- Dosya adı `snake_case`, sınıf `PascalCase`, değişken `camelCase`. Kod ve değişken adları İngilizce, kullanıcıya görünen metinler Türkçe.
- Clean Architecture: `presentation → domain ← data`; `domain` saf Dart kalır; ekran doğrudan HTTP/Hive/SQL çağırmaz.
- Hata: `Result<T>` kullan; boş `catch` yazma; kullanıcıya anlaşılır Türkçe mesaj göster.
- Her ekranda loading / empty / error durumu olsun.
- Para kuruş (int) tutulur, ekranda ₺ ile biçimlenir. Tarih/saat UTC saklanır, ekranda yerel gösterilir.
- Yorum: "ne" değil "neden" açıkla; ölü kod ve `print` bırakma.

## 5. Güvenlik Kuralları (ihlal edilemez)
- Sır, token, parola, `.env`, `storage/` içeriği commit edilmez ve loglanmaz.
- İstemci saati resmi zaman olarak **kullanılmaz**; resmi zaman sunucudan gelir.
- Korunan tablolarda `UPDATE`/`DELETE` yazma; düzeltme = yeni kayıt (`skills/immutable-record`).
- Her sunucu uç noktasında: token doğrula → ev üyeliğini doğrula → işlem. Yetkisiz erişimde `404`.
- Kullanıcı girdisini sunucuda doğrula (tür, boyut, uzunluk). SQL'de parametreli sorgu kullan, string birleştirme yok.
- Uygulamada hukuki kesinlik içeren metin yazma ("hukuken geçerlidir" vb.).

## 6. Test Beklentisi
- Sunucu: her uç nokta için başarılı yol + yetkisiz erişim + geçersiz girdi testi. Başka kullanıcının kaydına erişim testi **zorunlu**.
- Değiştirilemezlik: `UPDATE/DELETE` denemesinin DB'de reddedildiği ve hash zincirinin bozulmayı yakaladığı test.
- İstemci: use case ve model birim testleri; kritik form için widget testi.
- Test yazılmadan görev "bitti" sayılmaz.

## 7. Bitti Tanımı (Definition of Done)
- [ ] Görev tarifindeki her madde çalışıyor
- [ ] Analiz 0 uyarı, testler geçiyor
- [ ] `docs/` güncel (şema/API değiştiyse)
- [ ] Sır/dosya sızıntısı yok
- [ ] `progress.md` → `done.md` güncellendi
- [ ] Commit/push `skills/git-workflow` kurallarına uygun

## 8. Oturum Sonu
Bana kısa özet ver: ne yaptın, hangi dosyalar değişti, hangi karar/soru bekliyor, sıradaki görev ne. Emin olmadığın bir şeyi "yaptım" diye söyleme; doğrulanamayan şeyi açıkça belirt.

## 9. Dur ve Sor
Merge çakışması, beklenmeyen test hatası, şema/API'yi değiştirmeyi gerektiren durum, yeni paket ihtiyacı, arkadaşın dosyasına dokunma ihtiyacı, hukuki içerikli metin yazma ihtiyacı.
