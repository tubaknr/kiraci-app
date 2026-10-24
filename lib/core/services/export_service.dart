import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../db/record_repository.dart';
import '../integrity/hash_utils.dart';
import 'integrity_service.dart';

class ExportService {
  final RecordRepository _recordRepository;
  final IntegrityService _integrityService;
  final Future<Directory> Function() _getAppDocDir;

  ExportService({
    RecordRepository? recordRepository,
    IntegrityService? integrityService,
    Future<Directory> Function()? getAppDocDir,
  })  : _recordRepository = recordRepository ?? SqliteRecordRepository(),
        _integrityService = integrityService ?? IntegrityService(),
        _getAppDocDir = getAppDocDir ?? getApplicationDocumentsDirectory;

  /// Dosyadaki tüm kayıtları, formları ve fiziksel dosyaları kökünde
  /// 'manifest.json' bulunan doğrulanabilir bir ZIP paketine dönüştürür.
  Future<File> createEvidenceZipPackage(String caseId) async {
    final verification = await _integrityService.verifyChain(caseId);
    final records = await _recordRepository.getByCase(caseId);
    final appDocDir = await _getAppDocDir();

    final nowUtc = DateTime.now().toUtc();

    final manifestMap = {
      'case_id': caseId,
      'disclaimer': 'SafeRentHouse delil paketi. Zaman damgası cihaz saatine dayanır, zincir bütünlüğü SHA-256 ile bağımsız olarak doğrulanabilir.',
      'exported_at': nowUtc.toIso8601String(),
      'has_clock_anomalies': verification.hasClockAnomalies,
      'is_chain_valid': verification.isValid,
      'last_chain_hash': verification.lastChainHash ?? HashUtils.genesisHash,
      'record_count': records.length,
      'records': records.map((r) {
        return {
          'chain_hash': r.chainHash,
          'clock_anomaly': r.clockAnomaly,
          'content_hash': r.contentHash,
          'file_in_zip': r.filePath != null ? 'records/${p.basename(r.filePath!)}' : null,
          'form_type': r.formType,
          'id': r.id,
          'note': r.note,
          'prev_chain_hash': r.prevChainHash,
          'recorded_at': r.recordedAt.toIso8601String(),
          'title': r.title,
          'type': r.type,
        };
      }).toList(),
      'version': '1.0',
    };

    final manifestJson = HashUtils.canonicalJson(manifestMap);
    final manifestBytes = utf8.encode(manifestJson);

    final archive = Archive();

    // 1. manifest.json dosyasını kök dizine ekle
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    // 2. Her kayda ait fiziksel dosyaları arşivin records/ klasörüne ekle
    for (final record in records) {
      if (record.filePath != null && record.filePath!.isNotEmpty) {
        final physicalFile = File(p.join(appDocDir.path, record.filePath!));
        if (await physicalFile.exists()) {
          final fileBytes = await physicalFile.readAsBytes();
          final entryName = 'records/${p.basename(record.filePath!)}';
          archive.addFile(ArchiveFile(entryName, fileBytes.length, fileBytes));
        }
      }
    }

    final zipData = ZipEncoder().encode(archive);

    final exportDir = Directory(p.join(appDocDir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final zipFile = File(
      p.join(exportDir.path, 'delil_paketi_${caseId}_${nowUtc.millisecondsSinceEpoch}.zip'),
    );
    await zipFile.writeAsBytes(zipData);

    return zipFile;
  }

  /// Karşı tarafa veya üçüncü kişilere gönderilebilecek dış çapa mühür kodu metnini üretir.
  Future<String?> generateSealCodeMessage(String caseId) async {
    final sealCode = await _integrityService.getSealCode(caseId);
    if (sealCode == null) return null;

    final nowUtc = DateTime.now().toUtc();
    return '''[SafeRentHouse Delil Mühür Kodu]
Dosya ID: $caseId
Mühür Kodu (SHA-256): $sealCode
Kayıt Zamanı (UTC): ${nowUtc.toIso8601String()}

Bu mühür kodu, dosyadaki tüm kayıt zincirinin bu andaki özetidir.
E-posta veya mesajla üçüncü kişilere gönderilerek zaman çapası (dış kanıt) olarak kullanılabilir.''';
  }
}
