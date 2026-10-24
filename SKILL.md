---
name: role-switch-dev
description: Tek cihazda Kiracı Modu / Ev Sahibi Modu geçişini (test amaçlı rol değiştirme) yazarken kullan. Yalnızca geliştirme sürümünde çalışır; üretimde bulunmaz.
---

# Rol Değiştirme (Kiracı Modu / Ev Sahibi Modu) — Yalnızca Geliştirme

## İlke
Rol kullanıcıya değil **eve** aittir (`property_members.role`). "Mod değiştirmek" = iki gerçek test hesabı arasında oturum değiştirmektir. Sunucu tarafında hiçbir yetki gevşetilmez, özel uç nokta yazılmaz.

## Etkinleştirme
- `const devTools = bool.fromEnvironment('DEV_TOOLS');` ve `kDebugMode` **ikisi birden** doğruysa devreye girer.
- Tüm test modu kodu `app/lib/core/dev_tools/` altındadır; dışarıdan yalnızca `if (devToolsEnabled)` kapısı üzerinden çağrılır, böylece release build'de derlemeye girmez.

## Adımlar
1. `DevSessionStore`: `flutter_secure_storage` içinde `dev_session_tenant` ve `dev_session_landlord` anahtarlarında access/refresh token çiftlerini tutar. Başka yere token yazılmaz, loglanmaz.
2. `DevRoleController` (`ChangeNotifier`): `activeMode` (`tenant` | `landlord`), `switchTo(mode)`:
   - aktif oturumu kaydet → hedef oturumu yükle (yoksa seed hesabıyla giriş yap)
   - ağ katmanındaki token'ı değiştir
   - ilgili Provider'ları ve Hive önbelleğini sıfırla, açık evi yeniden yükle
3. `RoleSwitcherOverlay`: `MaterialApp.builder` içinde tüm ekranların üstüne ince şerit koyar. Metin: "TEST MODU — Kiracı Modu" (turkuaz) / "TEST MODU — Ev Sahibi Modu" (lacivert). Şeritteki düğme geçişi tetikler. Şerit klavye ve güvenli alanla çakışmaz.
4. Mock desteği: sunucu yoksa `MockAuthRepository` iki sahte kullanıcıyla aynı arayüzü sağlar.
5. Uygulama rolü açık evin `role` alanından okur (`PropertyRole` yardımcısı); modun kendisi rolü belirlemez, hangi hesabın aktif olduğunu belirler.

## Test Verisi
- `server/tool/seed_dev.dart`: yalnızca `APP_ENV=development`; iki hesap + örnek ev + üyelikler oluşturur. E-posta ve parola `.env`'den (`DEV_SEED_*`), repoda yazılı değil.

## Yasaklar
- Sunucuda "test" bayrağı, rol atlatan veya parolasız giriş veren uç nokta
- Test hesabı bilgilerini koda gömmek veya commit etmek
- Release build'de şeridin/anahtarların görünmesi
- Test modunu kullanıcıya ayar olarak sunmak

## Kontrol Listesi
- [ ] `flutter run` (DEV_TOOLS yok) → şerit görünmüyor
- [ ] `flutter run --dart-define=DEV_TOOLS=true` → şerit var, geçiş çalışıyor
- [ ] Geçişten sonra önceki rolün verisi ekranda kalmıyor
- [ ] Kiracı olarak gönderilen bildirim, ev sahibi modunda görünüyor ve okundu/onay verilebiliyor
- [ ] Release build'de `dev_tools` kodu/anahtarı yok (build çıktısı veya test ile doğrulandı)
- [ ] `flutter analyze` 0 uyarı
