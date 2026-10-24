---
name: immutable-record
description: Değiştirilemez (append-only) kayıt, sunucu zaman damgası, dosya SHA-256 ve audit_logs hash zinciri yazarken kullan. Bildirim, mesaj, dosya, dekont, demirbaş, sözleşme sürümü kayıtları için.
---

# Değiştirilemez Kayıt

## İlke
Bir kayıt oluşturulduktan sonra **güncellenmez ve silinmez**. Hata/düzeltme yeni kayıtla yapılır ve eskisine `supersedes_id` ile bağlanır. Resmi zaman yalnızca sunucudadır.

## Yeni Korunan Tablo Eklerken
1. Alanlar: `id uuid`, `property_id`, yazan kullanıcı, `server_time timestamptz`, gerekiyorsa `content_hash`.
2. Migration'da `forbid_mutation` trigger'ını bağla (BEFORE UPDATE OR DELETE) ve uygulama kullanıcısından `UPDATE, DELETE, TRUNCATE` yetkisini REVOKE et.
3. `docs/veritabani.md` §3 listesine tabloyu ekle.

## Kayıt Yazma Akışı (tek transaction)
1. Üyelik kontrolü.
2. `final now = TimestampService.now();` — **bir kez** al, tüm satırlarda aynısını kullan.
3. Kaydı ekle; `content_hash = sha256(kanonik içerik)` (alanlar sabit sırada, `|` ile birleştirilmiş, UTF-8).
4. Dosya varsa: sunucu akışı okurken SHA-256 hesapla, `files.sha256` kaydet.
5. `property_chain_heads` satırını `FOR UPDATE` ile kilitle.
6. `audit_logs` ekle: `prev_hash = head.last_hash`, `entry_hash = sha256(prev_hash|property_id|actor_id|action|entity_type|entity_id|payload_hash|server_time_iso)`.
7. Head'i ilerlet → commit. Hata → rollback (diskteki yarım dosya silinir).

## Doğrulama (`GET /evler/{evId}/loglar/dogrula`)
Logları `id` sırasıyla oku; her satırda `prev_hash` önceki `entry_hash` ile eşleşmeli ve `entry_hash` yeniden hesaplanınca aynı çıkmalı. İlk uyuşmazlıkta `{ gecerli: false, bozuk_log_id }` dön. Dosya doğrulamada diskteki dosyanın SHA-256'sı `files.sha256` ile karşılaştırılır.

## Zorunlu Testler
- [ ] `UPDATE`/`DELETE` denemesi DB hatası veriyor
- [ ] Zincir doğrulama sağlam veride `gecerli: true`
- [ ] Veritabanında bir satır elle bozulunca doğrulama bozuk satırı buluyor
- [ ] İstemci saati değiştirilse de `server_time` sunucudan geliyor
- [ ] Eşzamanlı iki yazma zinciri çatallamıyor

## Dürüst Dil
Arayüzde/dokümanda "değiştirilemez ve zaman damgalı kayıt" denir; "hukuken kesin delildir" denmez. Gelecek iyileştirme: harici güvenilir zaman damgası (RFC 3161).
