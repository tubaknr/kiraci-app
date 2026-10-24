import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../db/record_repository.dart';
import '../integrity/hash_utils.dart';

@immutable
class ChainVerificationResult {
  final bool isValid;
  final int totalRecords;
  final String? brokenRecordId;
  final String? failureReason;
  final List<String> anomalyRecordIds;
  final String? lastChainHash;

  const ChainVerificationResult({
    required this.isValid,
    required this.totalRecords,
    this.brokenRecordId,
    this.failureReason,
    this.anomalyRecordIds = const [],
    this.lastChainHash,
  });

  factory ChainVerificationResult.valid({
    required int totalRecords,
    String? lastChainHash,
    List<String> anomalyRecordIds = const [],
  }) {
    return ChainVerificationResult(
      isValid: true,
      totalRecords: totalRecords,
      lastChainHash: lastChainHash,
      anomalyRecordIds: List.unmodifiable(anomalyRecordIds),
    );
  }

  factory ChainVerificationResult.broken({
    required String brokenRecordId,
    required String failureReason,
    required int totalRecords,
    List<String> anomalyRecordIds = const [],
  }) {
    return ChainVerificationResult(
      isValid: false,
      totalRecords: totalRecords,
      brokenRecordId: brokenRecordId,
      failureReason: failureReason,
      anomalyRecordIds: List.unmodifiable(anomalyRecordIds),
    );
  }

  bool get hasClockAnomalies => anomalyRecordIds.isNotEmpty;
}

class IntegrityService {
  final RecordRepository _recordRepository;
  final Future<Directory> Function() _getAppDocDir;

  IntegrityService({
    RecordRepository? recordRepository,
    Future<Directory> Function()? getAppDocDir,
  })  : _recordRepository = recordRepository ?? SqliteRecordRepository(),
        _getAppDocDir = getAppDocDir ?? getApplicationDocumentsDirectory;

  /// Bir dosyadaki (caseId) tüm kayıt zincirini ve diskteki dosyaları baştan sona denetler.
  /// Herhangi bir tahrifat, dosya değişikliği veya zincir kırılması varsa ilk bozuk kaydı tespit eder.
  Future<ChainVerificationResult> verifyChain(String caseId) async {
    final records = await _recordRepository.getByCase(caseId);

    if (records.isEmpty) {
      return ChainVerificationResult.valid(totalRecords: 0);
    }

    final appDocDir = await _getAppDocDir();
    String expectedPrevHash = HashUtils.genesisHash;
    final List<String> anomalyIds = [];

    for (final record in records) {
      // 1. Önceki zincir hash değerinin doğruluğunu kontrol et
      if (record.prevChainHash != expectedPrevHash) {
        return ChainVerificationResult.broken(
          brokenRecordId: record.id,
          failureReason: 'Önceki zincir hash değeri uyuşmuyor. Araya kayıt sokulmuş veya kayıt silinmiş olabilir.',
          totalRecords: records.length,
          anomalyRecordIds: anomalyIds,
        );
      }

      // 2. Diskteki dosyanın fiziksel bütünlüğünü kontrol et
      if (record.filePath != null && record.filePath!.isNotEmpty) {
        final physicalFile = File(p.join(appDocDir.path, record.filePath!));
        if (!await physicalFile.exists()) {
          return ChainVerificationResult.broken(
            brokenRecordId: record.id,
            failureReason: 'Kayıtlı delil dosyası diskte bulunamadı: ${record.filePath}',
            totalRecords: records.length,
            anomalyRecordIds: anomalyIds,
          );
        }

        final currentContentHash = await HashUtils.sha256Stream(physicalFile.openRead());
        if (currentContentHash != record.contentHash) {
          return ChainVerificationResult.broken(
            brokenRecordId: record.id,
            failureReason: 'Dosya içeriği sonradan değiştirilmiş! İçerik özeti (SHA-256) eşleşmiyor.',
            totalRecords: records.length,
            anomalyRecordIds: anomalyIds,
          );
        }
      }

      // 3. Mevcut kaydın zincir hash formülünü yeniden hesapla
      final recomputedChain = HashUtils.chainHash(
        record.prevChainHash,
        record.contentHash,
        record.recordedAt,
      );

      if (recomputedChain != record.chainHash) {
        return ChainVerificationResult.broken(
          brokenRecordId: record.id,
          failureReason: 'Kayıt zincir özet değeri geçersiz. Veritabanı satırı değiştirilmiş.',
          totalRecords: records.length,
          anomalyRecordIds: anomalyIds,
        );
      }

      // 4. Saat anomalisi kontrolü
      if (record.clockAnomaly) {
        anomalyIds.add(record.id);
      }

      expectedPrevHash = record.chainHash;
    }

    return ChainVerificationResult.valid(
      totalRecords: records.length,
      lastChainHash: records.last.chainHash,
      anomalyRecordIds: anomalyIds,
    );
  }

  /// Bir dosyanın güncel mühür kodunu (en son chain_hash) üretir.
  Future<String?> getSealCode(String caseId) async {
    final last = await _recordRepository.getLast(caseId);
    return last?.chainHash;
  }
}
