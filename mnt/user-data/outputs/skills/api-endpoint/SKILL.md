---
name: api-endpoint
description: Dart sunucuya (shelf) yeni REST uç noktası eklerken kullan. Auth, üyelik kontrolü, doğrulama, zaman damgası ve test adımlarını tanımlar.
---

# API Uç Noktası Ekleme

## Başlamadan
- Uç nokta `docs/api.md`'de var mı? Yoksa önce oraya ekle (yöntem, yol, yetki, gövde, yanıt) ve bana bildir.
- Tablo/alan gerekiyorsa `docs/veritabani.md` + yeni migration (`server/migrations/NNN_ad.sql`).

## Katmanlar (server/lib/features/<ozellik>/)
1. **domain**: entity, repository arayüzü, use case (iş kuralı burada).
2. **data**: SQL (parametreli sorgular), repository gerçeklemesi, model dönüşümü.
3. **presentation**: shelf handler + router. Handler yalnızca: istek ayrıştır → use case çağır → yanıt üret.

## Handler Sırası (her zaman)
1. Auth middleware: JWT doğrula → `kullaniciId`.
2. Üyelik middleware: `evId` için `property_members` kaydı yoksa **404**.
3. Girdi doğrulama (tür, uzunluk, enum, dosya mime/boyut).
4. `Idempotency-Key` varsa tekrar kontrolü.
5. Use case (tek transaction): `TimestampService.now()` → kayıt → hash → `audit_logs` (bkz. `skills/immutable-record`).
6. Yanıt: 201 + `id` + `sunucu_zamani`. Hata: `{ "hata": { "kod", "mesaj" } }`.

## Yasaklar
- SQL string birleştirme (SQL injection). Her zaman parametre.
- Yanıtta parola hash'i, token hash'i, disk yolu döndürmek.
- İstemci saatini `server_time` olarak kullanmak.
- Korunan tabloda `UPDATE/DELETE`.
- Loglara token/parola/kişisel veri yazmak.

## Test (zorunlu)
- [ ] Başarılı istek (201/200) ve yanıt alanları
- [ ] Token yok → 401
- [ ] Başka evin kullanıcısı → 404 (başka kullanıcının mesajı/dosyası görünmüyor)
- [ ] Geçersiz girdi → 400; büyük/yanlış türde dosya → 413/415
- [ ] Aynı `Idempotency-Key` ile ikinci istek çift kayıt oluşturmuyor
- [ ] `audit_logs` satırı oluştu ve `loglar/dogrula` geçerli dönüyor
