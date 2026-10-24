import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/services/record_service.dart';
import '../models/record_model.dart';

class RecordAddController {
  final RecordService _recordService;

  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<RecordModel?> createdRecord = ValueNotifier(null);

  RecordAddController(this._recordService);

  Future<bool> addFileRecord({
    required String caseId,
    required String type,
    required String title,
    String? note,
    required File file,
    String? correctsRecordId,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      errorMessage.value = 'Kayıt başlığı boş bırakılamaz.';
      status.value = ViewStatus.error;
      return false;
    }

    if (!await file.exists()) {
      errorMessage.value = 'Seçilen dosya bulunamadı.';
      status.value = ViewStatus.error;
      return false;
    }

    status.value = ViewStatus.loading;
    errorMessage.value = null;

    try {
      final record = await _recordService.addFileRecord(
        caseId: caseId,
        type: type,
        title: trimmedTitle,
        note: note,
        sourceFile: file,
        correctsRecordId: correctsRecordId,
      );

      createdRecord.value = record;
      status.value = ViewStatus.success;
      return true;
    } catch (_) {
      errorMessage.value = 'Kayıt eklenirken bir hata oluştu.';
      status.value = ViewStatus.error;
      return false;
    }
  }

  void dispose() {
    status.dispose();
    errorMessage.dispose();
    createdRecord.dispose();
  }
}
