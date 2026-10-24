---
name: evidence-integrity
description: Kayıtların SHA-256 özeti, hash zinciri, saat anomalisi tespiti ve zincir doğrulamasını yazarken kullan.
---

# Delil Bütünlüğü (Yerel Hash Zinciri)

## Amaç
Eklenen kayıtlar sonradan değiştirilir, silinir veya araya kayıt sokulursa bunu **tespit edilebilir** kılmak.

## Ne Zaman Kullan
- Kayıt eklerken (hash + zincir)
- `verifyChain` yazarken
- Form JSON'unu hash'lerken
- ZIP `manifest.json` üretirken

## Ne Zaman Kullanma
- PIN saklama (düz SHA-256 yerine tuzlu özet kullan)

## Önemli Sınır
Backend yoktur; `recorded_at` **cihaz saatidir** ve kullanıcı tarafından değiştirilebilir. Zincir bozulmayı tespit eder, zamanın doğruluğunu **kanıtlamaz**. Arayüz ve PDF bunu belirtmelidir.

## Kavramlar
| Alan | Anlamı |
|---|---|
| `content_hash` | Dosyanın veya kanonik JSON'un SHA-256'sı (hex) |
| `recorded_at` | Kayıt anındaki cihaz saati (UTC, ISO-8601) |
| `prev_chain_hash` | Aynı dosyadaki önceki kaydın `chain_hash`'i (ilk kayıtta `GENESIS`) |
| `chain_hash` | `SHA256(prev_chain_hash \| content_hash \| recorded_at)` |
| `clock_anomaly` | `recorded_at` önceki kayıttan eskiyse `true` |

## Adımlar
1. Dosya baytlarından `content_hash` hesapla (büyük dosyada akışla)
2. Son kaydı oku; `recorded_at = DateTime.now().toUtc()`
3. `clock_anomaly = recorded_at < sonKayit.recordedAt`
4. `chain_hash` hesapla, transaction içinde ekle
5. `verifyChain(caseId)`: kayıtları sırayla gez; her `chain_hash`'i ve dosyanın güncel hash'ini yeniden hesapla; ilk uyuşmazlıkta dur ve o kaydın ID'sini döndür
6. Mühür kodu: dosyanın son `chain_hash`'i; paylaşım `share_plus` ile (bağımsız kanal = dış çapa)

## Şablon
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

String chainHash(String prev, String contentHash, DateTime recordedAtUtc) =>
    sha256Hex(utf8.encode('$prev|$contentHash|${recordedAtUtc.toIso8601String()}'));

String canonicalJson(Map<String, dynamic> m) {
  dynamic sort(dynamic v) => v is Map
      ? Map.fromEntries((v.entries.toList()..sort((a, b) => a.key.toString().compareTo(b.key.toString())))
          .map((e) => MapEntry(e.key, sort(e.value))))
      : v is List ? v.map(sort).toList() : v;
  return jsonEncode(sort(m));
}
```

## Kontrol Listesi
- [ ] Zaman UTC
- [ ] Ekleme transaction içinde
- [ ] Bozulmuş kaydı yakalayan test var (kaydı elle değiştir → `verifyChain` başarısız)
- [ ] Saat geri alma testi var (`clock_anomaly == true`)
- [ ] Kanonik JSON iç içe yapılar için özyinelemeli
- [ ] Arayüzde "zaman cihaz saatine dayanır" uyarısı var

## Sık Yapılan Hatalar
| Hata | Doğrusu |
|---|---|
| `DateTime.now()` yerel saat | `DateTime.now().toUtc()` |
| Hash'i tüm dosyayı belleğe alarak hesaplamak | Dosya akışıyla hesapla |
| "Resmî zaman damgası" demek | "Cihaz saatiyle kaydedildi, zincir doğrulandı" |
| Sadece kayıt satırını hash'lemek | Dosyanın içeriğinin hash'ini de doğrulamada yeniden hesapla |
