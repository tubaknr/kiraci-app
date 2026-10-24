import 'package:flutter/foundation.dart';

@immutable
class RecordModel {
  final String id;
  final String caseId;
  final String type; // 'document', 'photo', 'video', 'audio', 'form', 'chat_proof'
  final String title;
  final String? note;
  final String? filePath; // Uygulama dizinine göreli yol (relative path)
  final String contentHash; // Dosyanın veya kanonik JSON içeriğinin SHA-256 özeti
  final String prevChainHash; // Önceki kaydın chainHash'i veya ilk kayıtta 'GENESIS'
  final String chainHash; // SHA256(prev_chain_hash | content_hash | recorded_at)
  final DateTime recordedAt; // UTC kayıt zamanı
  final bool clockAnomaly; // Kayıt anı önceki kayıttan eskiyse true
  final String? formType; // 'F1', 'F2', 'F3', 'F4', 'F5'
  final String? correctsRecordId; // Hata düzeltme amacıyla önceki kaydı işaret eden ID

  const RecordModel({
    required this.id,
    required this.caseId,
    required this.type,
    required this.title,
    this.note,
    this.filePath,
    required this.contentHash,
    required this.prevChainHash,
    required this.chainHash,
    required this.recordedAt,
    this.clockAnomaly = false,
    this.formType,
    this.correctsRecordId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'case_id': caseId,
      'type': type,
      'title': title,
      'note': note,
      'file_path': filePath,
      'content_hash': contentHash,
      'prev_chain_hash': prevChainHash,
      'chain_hash': chainHash,
      'recorded_at': recordedAt.toUtc().toIso8601String(),
      'clock_anomaly': clockAnomaly ? 1 : 0,
      'form_type': formType,
      'corrects_record_id': correctsRecordId,
    };
  }

  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'] as String,
      caseId: map['case_id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      filePath: map['file_path'] as String?,
      contentHash: map['content_hash'] as String,
      prevChainHash: map['prev_chain_hash'] as String,
      chainHash: map['chain_hash'] as String,
      recordedAt: DateTime.parse(map['recorded_at'] as String).toUtc(),
      clockAnomaly: (map['clock_anomaly'] as int? ?? 0) == 1,
      formType: map['form_type'] as String?,
      correctsRecordId: map['corrects_record_id'] as String?,
    );
  }

  RecordModel copyWith({
    String? id,
    String? caseId,
    String? type,
    String? title,
    String? note,
    String? filePath,
    String? contentHash,
    String? prevChainHash,
    String? chainHash,
    DateTime? recordedAt,
    bool? clockAnomaly,
    String? formType,
    String? correctsRecordId,
  }) {
    return RecordModel(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      type: type ?? this.type,
      title: title ?? this.title,
      note: note ?? this.note,
      filePath: filePath ?? this.filePath,
      contentHash: contentHash ?? this.contentHash,
      prevChainHash: prevChainHash ?? this.prevChainHash,
      chainHash: chainHash ?? this.chainHash,
      recordedAt: recordedAt ?? this.recordedAt,
      clockAnomaly: clockAnomaly ?? this.clockAnomaly,
      formType: formType ?? this.formType,
      correctsRecordId: correctsRecordId ?? this.correctsRecordId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordModel &&
        other.id == id &&
        other.caseId == caseId &&
        other.type == type &&
        other.title == title &&
        other.note == note &&
        other.filePath == filePath &&
        other.contentHash == contentHash &&
        other.prevChainHash == prevChainHash &&
        other.chainHash == chainHash &&
        other.recordedAt == recordedAt &&
        other.clockAnomaly == clockAnomaly &&
        other.formType == formType &&
        other.correctsRecordId == correctsRecordId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      caseId,
      type,
      title,
      note,
      filePath,
      contentHash,
      prevChainHash,
      chainHash,
      recordedAt,
      clockAnomaly,
      formType,
      correctsRecordId,
    );
  }
}
