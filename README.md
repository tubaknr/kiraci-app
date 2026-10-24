# Güvenli Kira – .md Dosya Seti

Kiracı ve ev sahibi arasındaki sözleşme, dekont, demirbaş, fotoğraf, mesaj ve bildirimleri **sunucu saatiyle damgalı ve değiştirilemez** şekilde kayıt altına alan, tamamı Dart/Flutter ile yazılan proje. Kodlama yapay zekaya yaptırılır; bu dosyalar ajanın yol haritasıdır.

## Kullanım (yeni projede)
1. Bu klasörün içeriğini proje köküne kopyala. `SKILL.md` dosyasını `skills/git-workflow/SKILL.md` olarak yerleştir.
2. `project.md` içindeki "bekleyen kararları" (`progress.md` → Engeller) kesinleştir.
3. Ajana ilk mesaj: "project.md ve agents.md dosyalarını oku, sonra progress.md'ye göre başla."
4. Her görev sonunda ajan `progress.md` ve `done.md` dosyalarını günceller.

## Dosyalar
| Dosya | Görev | Değişim |
|---|---|---|
| project.md | Ne yapıyoruz: amaç, mimari, güvenlik ilkeleri, ekranlar, kapsam | Nadir |
| agents.md | Nasıl çalışmalısın: kurallar, standartlar, bitti tanımı | Nadir |
| docs/veritabani.md | Tablolar, ilişkiler, değiştirilemezlik, hash zinciri | Şema değişince |
| docs/api.md | REST uç noktaları, hata biçimi, örnekler | API değişince |
| skills/git-workflow/SKILL.md | Branch, analiz, commit, push tarifi | Ara sıra |
| skills/flutter-feature/SKILL.md | Ekran/form/medya yazma tarifi | Ara sıra |
| skills/api-endpoint/SKILL.md | Sunucu uç noktası ekleme tarifi | Ara sıra |
| skills/immutable-record/SKILL.md | Append-only kayıt, zaman damgası, hash zinciri | Ara sıra |
| progress.md | Şu an neredeyiz, görev sırası, bekleyen kararlar | Her oturum |
| done.md | Neleri bitirdik | Her görev |

## Mimari Özet
`Flutter uygulaması (Hive + secure storage)` → HTTPS + JWT → `Dart sunucu (shelf)` → `PostgreSQL` + `storage/`. Resmi zaman yalnızca sunucuda üretilir; kayıtlar append-only'dir; her ev için audit log hash zinciri tutulur.

## Çalışma Bölümü
- **Tuba:** iskelet, veri modelleri, veritabanı, auth (JWT), zaman damgası servisi, immutability, API uç noktaları; ekranlar: kira & ev kaydı detayı, demirbaş formu, belge seçme/listeleme, talep/bildirim oluşturma, ev fotoğrafları.
- **Arkadaş:** tema, navigasyon, giriş/kayıt, ana sayfa; öneri olarak mesajlar ve zaman çizelgesi ekranları.
- Birbirinin klasörüne dokunulmaz; ortak dosya (`docs/api.md`, tema) değişikliği önce konuşulur.

## Geliştirme Komutları (ajan kurulumdan sonra doğrular)
```
cd server && dart pub get && dart run bin/server.dart     # sunucu
cd server && dart analyze && dart test
cd app && flutter pub get && flutter run                  # istemci
cd app && flutter analyze && flutter test
docker compose up -d                                      # geliştirme PostgreSQL'i
```
Sunucu ortam değişkenleri: `DATABASE_URL`, `JWT_SECRET`, `ACCESS_TOKEN_MINUTES`, `REFRESH_TOKEN_DAYS`, `STORAGE_PATH`, `MAX_UPLOAD_MB`, `PORT` (`server/.env`, git'e girmez).

## Not
Uygulama hukuki danışmanlık vermez; kayıtların hukuki geçerliliği bir hukukçuya danışılarak değerlendirilmelidir.
