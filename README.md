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
| project.md | Ne yapıyoruz: amaç, mimari, güvenlik ilkeleri, tüm ekranlar, tasarım, kapsam | Nadir |
| agents.md | Nasıl çalışmalısın: kurallar, standartlar, bitti tanımı | Nadir |
| docs/veritabani.md | Tablolar, ilişkiler, değiştirilemezlik, hash zinciri | Şema değişince |
| docs/api.md | REST uç noktaları, hata biçimi, örnekler | API değişince |
| skills/git-workflow/SKILL.md | Branch, analiz, commit, push tarifi | Ara sıra |
| skills/flutter-feature/SKILL.md | Ekran/form/medya yazma tarifi | Ara sıra |
| skills/api-endpoint/SKILL.md | Sunucu uç noktası ekleme tarifi | Ara sıra |
| skills/immutable-record/SKILL.md | Append-only kayıt, zaman damgası, hash zinciri | Ara sıra |
| skills/role-switch-dev/SKILL.md | Test amaçlı Kiracı/Ev Sahibi Modu geçişi (yalnız geliştirme) | Ara sıra |
| progress.md | Şu an neredeyiz, görev sırası, bekleyen kararlar | Her oturum |
| done.md | Neleri bitirdik | Her görev |

## Mimari Özet
`Flutter uygulaması (Hive + secure storage)` → HTTPS + JWT → `Dart sunucu (shelf)` → `PostgreSQL` + `storage/`. Resmi zaman yalnızca sunucuda üretilir; kayıtlar append-only'dir; her ev için audit log hash zinciri tutulur.

## Çalışma Düzeni
- Proje iki parçadır: **sunucu** (`server/`) ve **Flutter uygulaması** (`app/`). Dosya seti her ikisini de kapsar.
- Görevler `progress.md`'de S (sunucu/genel) ve A (uygulama) ön ekleriyle numaralıdır; iki kişi de her alanda çalışabilir.
- **Sümeyye:** açılış (splash) ve giriş/kayıt ekranı tasarımı, Kiracı Modu / Ev Sahibi Modu rol değiştirme. **Tuba:** sunucu, iskelet, veri katmanı ve özellik ekranları. Tema (A-02) henüz atanmadı.
- Göreve başlarken `progress.md` → "Şu An Üzerinde Çalışılan" tablosuna görevi ve sahibini yaz; branch adı `feature/<id>-<ad>`.
- Ortak dosyalar (`docs/api.md`, `docs/veritabani.md`, tema) değişmeden önce konuşulur.

## Geliştirme Komutları (ajan kurulumdan sonra doğrular)
```
cd server && dart pub get && dart run bin/server.dart     # sunucu
cd server && dart analyze && dart test
cd app && flutter pub get && flutter run                  # istemci
cd app && flutter run --dart-define=DEV_TOOLS=true        # istemci + Kiracı/Ev Sahibi test modu (yalnız debug)
cd server && dart run tool/seed_dev.dart                  # test hesapları + örnek ev (APP_ENV=development)
cd app && flutter analyze && flutter test
docker compose up -d                                      # geliştirme PostgreSQL'i
```
Sunucu ortam değişkenleri: `DATABASE_URL`, `JWT_SECRET`, `ACCESS_TOKEN_MINUTES`, `REFRESH_TOKEN_DAYS`, `STORAGE_PATH`, `MAX_UPLOAD_MB`, `PORT` (`server/.env`, git'e girmez).

## Not
Uygulama hukuki danışmanlık vermez; kayıtların hukuki geçerliliği bir hukukçuya danışılarak değerlendirilmelidir.
