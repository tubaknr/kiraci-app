import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Delil bütünlüğü, SHA-256 özetleri, kanonik JSON ve hash zinciri işlemleri.
class HashUtils {
  const HashUtils._();

  /// İlk kayıt için başlangıç zincir hash değeri
  static const String genesisHash = 'GENESIS';

  /// Verilen bayt dizisinin SHA-256 özetini (hex formatında küçük harf) hesaplar.
  static String sha256Hex(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Verilen metnin UTF-8 baytları üzerinden SHA-256 özetini hesaplar.
  static String sha256String(String input) {
    return sha256Hex(utf8.encode(input));
  }

  /// Büyük dosyalar için akış üzerinden bellek dostu SHA-256 hesaplama.
  static Future<String> sha256Stream(Stream<List<int>> stream) async {
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }

  /// Map yapısını özyinelemeli olarak alfabetik anahtarlara göre sıralar ve
  /// tutarlı/kanonik bir JSON metni üretir.
  /// Farklı platform veya sıralamalarda her zaman aynı hash sonucunu verir.
  static String canonicalJson(Map<String, dynamic> map) {
    dynamic sortValue(dynamic value) {
      if (value is Map) {
        final sortedKeys = value.keys.map((e) => e.toString()).toList()..sort();
        final Map<String, dynamic> sortedMap = {};
        for (final key in sortedKeys) {
          sortedMap[key] = sortValue(value[key]);
        }
        return sortedMap;
      } else if (value is List) {
        return value.map(sortValue).toList();
      }
      return value;
    }

    final sorted = sortValue(map) as Map<String, dynamic>;
    return jsonEncode(sorted);
  }

  /// Kanonik JSON metninin SHA-256 özetini döndürür.
  static String canonicalJsonHash(Map<String, dynamic> map) {
    final jsonStr = canonicalJson(map);
    return sha256String(jsonStr);
  }

  /// Zincir hash'i üretir: SHA256(prev_chain_hash | content_hash | recorded_at_utc_iso)
  static String chainHash(
    String prevChainHash,
    String contentHash,
    DateTime recordedAtUtc,
  ) {
    final payload = '$prevChainHash|$contentHash|${recordedAtUtc.toUtc().toIso8601String()}';
    return sha256String(payload);
  }

  /// Saat anomalisi kontrolü: Yeni kaydın zamanı önceki kaydın zamanından eskiyse anomali vardır.
  static bool isClockAnomaly(DateTime currentUtc, DateTime previousUtc) {
    return currentUtc.toUtc().isBefore(previousUtc.toUtc());
  }
}
