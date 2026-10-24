import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../features/records/models/record_model.dart';
import '../db/record_repository.dart';
import '../integrity/hash_utils.dart';

/// Kullanıcı dosyalarını güvenli uygulama dizinine kopyalayan,
/// SHA-256 içeriğini özetleyen, hash zincirine bağlayan ve saat anomalilerini
/// tespit eden çekirdek kayıt servisi.
class RecordService {
  final RecordRepository _recordRepository;
  final Future<Directory> Function() _getAppDocDir;
  final DateTime Function() _clock;

  RecordService({
    RecordRepository? recordRepository,
    Future<Directory> Function()? getAppDocDir,
    DateTime Function()? clock,
  })  : _recordRepository = recordRepository ?? SqliteRecordRepository(),
        _getAppDocDir = getAppDocDir ?? getApplicationDocumentsDirectory,
        _clock = clock ?? DateTime.now;

  /// Dosya tabanlı delil kaydı ekler (belge, fotoğraf, video, ses, konuşma ekran görüntüsü).
  Future<RecordModel> addFileRecord({
    required String caseId,
    required String type,
    required String title,
    String? note,
    required File sourceFile,
    String? correctsRecordId,
  }) async {
    if (!await sourceFile.exists()) {
      throw FileSystemException('Kaynak dosya bulunamadı', sourceFile.path);
    }

    final appDocDir = await _getAppDocDir();
    final caseRelativeDir = p.join('records', caseId);
    final caseFullDir = Directory(p.join(appDocDir.path, caseRelativeDir));

    if (!await caseFullDir.exists()) {
      await caseFullDir.create(recursive: true);
    }

    final nowUtc = _clock().toUtc();
    final sanitizedFileName = '${nowUtc.millisecondsSinceEpoch}_${p.basename(sourceFile.path)}';
    final targetRelativePath = p.join(caseRelativeDir, sanitizedFileName);
    final targetFile = File(p.join(appDocDir.path, targetRelativePath));

    // Dosyayı güvenli uygulama dizinine kopyala (orijinal yol asla tutulmaz)
    await sourceFile.copy(targetFile.path);

    // İçeriğin SHA-256 özetini akışla bellek dostu olarak hesapla
    final contentHash = await HashUtils.sha256Stream(targetFile.openRead());

    // Zincirdeki bir önceki kaydı getir
    final lastRecord = await _recordRepository.getLast(caseId);
    final prevChainHash = lastRecord?.chainHash ?? HashUtils.genesisHash;

    // Saat anomalisi kontrolü: Kayıt zamanı önceki kayıttan eskiyse işaretle
    final isAnomaly = lastRecord != null && HashUtils.isClockAnomaly(nowUtc, lastRecord.recordedAt);

    // Yeni kaydın zincir hash'ini üret
    final chain = HashUtils.chainHash(prevChainHash, contentHash, nowUtc);

    final record = RecordModel(
      id: 'rec_${nowUtc.millisecondsSinceEpoch}',
      caseId: caseId,
      type: type,
      title: title.trim(),
      note: note?.trim(),
      filePath: targetRelativePath,
      contentHash: contentHash,
      prevChainHash: prevChainHash,
      chainHash: chain,
      recordedAt: nowUtc,
      clockAnomaly: isAnomaly,
      correctsRecordId: correctsRecordId,
    );

    return _recordRepository.insert(record);
  }

  /// Yapılandırılmış form kaydı ekler (F1-F5).
  /// Form verisi kanonik JSON olarak diske yazılır ve hash zincirine bağlanır.
  Future<RecordModel> addFormRecord({
    required String caseId,
    required String formType,
    required String title,
    String? note,
    required Map<String, dynamic> formData,
    String? correctsRecordId,
  }) async {
    final appDocDir = await _getAppDocDir();
    final caseRelativeDir = p.join('records', caseId);
    final caseFullDir = Directory(p.join(appDocDir.path, caseRelativeDir));

    if (!await caseFullDir.exists()) {
      await caseFullDir.create(recursive: true);
    }

    final nowUtc = _clock().toUtc();
    final canonicalJsonStr = HashUtils.canonicalJson(formData);
    final contentHash = HashUtils.sha256String(canonicalJsonStr);

    final formFileName = 'form_${formType.toLowerCase()}_${nowUtc.millisecondsSinceEpoch}.json';
    final targetRelativePath = p.join(caseRelativeDir, formFileName);
    final targetFile = File(p.join(appDocDir.path, targetRelativePath));

    await targetFile.writeAsString(canonicalJsonStr, encoding: utf8);

    final lastRecord = await _recordRepository.getLast(caseId);
    final prevChainHash = lastRecord?.chainHash ?? HashUtils.genesisHash;
    final isAnomaly = lastRecord != null && HashUtils.isClockAnomaly(nowUtc, lastRecord.recordedAt);

    final chain = HashUtils.chainHash(prevChainHash, contentHash, nowUtc);

    final record = RecordModel(
      id: 'rec_${nowUtc.millisecondsSinceEpoch}',
      caseId: caseId,
      type: 'form',
      title: title.trim(),
      note: note?.trim(),
      filePath: targetRelativePath,
      contentHash: contentHash,
      prevChainHash: prevChainHash,
      chainHash: chain,
      recordedAt: nowUtc,
      clockAnomaly: isAnomaly,
      formType: formType,
      correctsRecordId: correctsRecordId,
    );

    return _recordRepository.insert(record);
  }

  /// Dosyanın uygulama dizinindeki tam mutlak yolunu (absolute path) döndürür.
  Future<File?> getAbsoluteFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final appDocDir = await _getAppDocDir();
    final file = File(p.join(appDocDir.path, relativePath));
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
