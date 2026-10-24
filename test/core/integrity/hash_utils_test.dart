import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/integrity/hash_utils.dart';

void main() {
  group('HashUtils - SHA-256 Tests', () {
    test('Bilinen SHA-256 hash degeri dogru hesaplanmalidir', () {
      // 'test' metninin bilinen SHA-256 ozeti
      const input = 'test';
      const expected = '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08';

      final hash = HashUtils.sha256String(input);
      expect(hash, expected);
    });

    test('sha256Stream akis uzerinden ayni ozeti uretmelidir', () async {
      const input = 'Buyuk dosya akis testi';
      final expected = HashUtils.sha256String(input);

      final stream = Stream<List<int>>.value(utf8.encode(input));
      final streamHash = await HashUtils.sha256Stream(stream);

      expect(streamHash, expected);
    });
  });

  group('HashUtils - Kanonik JSON Tests', () {
    test('Farkli anahtar siralarina sahip mapler ayni kanonik ciktigi ve hash uretmelidir', () {
      final map1 = {
        'b': 2,
        'a': 1,
        'c': {
          'z': 'son',
          'm': 'orta',
        },
      };

      final map2 = {
        'c': {
          'm': 'orta',
          'z': 'son',
        },
        'a': 1,
        'b': 2,
      };

      final json1 = HashUtils.canonicalJson(map1);
      final json2 = HashUtils.canonicalJson(map2);

      expect(json1, json2);
      expect(json1, '{"a":1,"b":2,"c":{"m":"orta","z":"son"}}');

      final hash1 = HashUtils.canonicalJsonHash(map1);
      final hash2 = HashUtils.canonicalJsonHash(map2);
      expect(hash1, hash2);
    });

    test('Liste iceren karmasik maplerde kanonik sira korunmalidir', () {
      final map = {
        'items': [
          {'name': 'oda 1', 'id': 1},
          {'name': 'oda 2', 'id': 2},
        ],
        'title': 'Teslim Tutonagi',
      };

      final jsonStr = HashUtils.canonicalJson(map);
      expect(
        jsonStr,
        '{"items":[{"id":1,"name":"oda 1"},{"id":2,"name":"oda 2"}],"title":"Teslim Tutonagi"}',
      );
    });
  });

  group('HashUtils - Hash Zinciri ve Anomali Tests', () {
    test('Ilk kayit icin GENESIS zinciri olusturulmalidir', () {
      final recordedAt = DateTime.utc(2026, 1, 1, 10, 0, 0);
      const contentHash = 'content_hash_1';

      final chain1 = HashUtils.chainHash(
        HashUtils.genesisHash,
        contentHash,
        recordedAt,
      );

      expect(chain1.length, 64); // SHA-256 64 karakter hex
    });

    test('Ikinci kayit birincinin zincirine baglanmalidir', () {
      final t1 = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final t2 = DateTime.utc(2026, 1, 1, 11, 0, 0);

      final chain1 = HashUtils.chainHash(HashUtils.genesisHash, 'hash_1', t1);
      final chain2 = HashUtils.chainHash(chain1, 'hash_2', t2);

      expect(chain2, isNot(chain1));

      // Eger aradaki kayit degistirilirse zincir bozulur (tampon testi)
      final corruptedChain1 = HashUtils.chainHash(HashUtils.genesisHash, 'hash_tampered', t1);
      final recomputedChain2 = HashUtils.chainHash(corruptedChain1, 'hash_2', t2);

      expect(recomputedChain2, isNot(chain2));
    });

    test('Saat geriye alindiginda clock_anomaly true olmalidir', () {
      final t1 = DateTime.utc(2026, 1, 2, 10, 0, 0);
      final t2 = DateTime.utc(2026, 1, 2, 9, 30, 0); // Saat 30 dk geriye alinmis
      final t3 = DateTime.utc(2026, 1, 2, 11, 0, 0); // Normal ileri zaman

      expect(HashUtils.isClockAnomaly(t2, t1), isTrue);
      expect(HashUtils.isClockAnomaly(t3, t1), isFalse);
    });
  });
}
