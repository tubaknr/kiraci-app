import 'package:flutter/foundation.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/services/record_service.dart';
import '../../records/models/record_model.dart';
import '../models/f3_defect_data.dart';

class F3DefectController {
  final RecordService _recordService;

  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<Map<String, String>> fieldErrors = ValueNotifier(const {});
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<RecordModel?> createdRecord = ValueNotifier(null);

  F3DefectController(this._recordService);

  Future<bool> submit({
    required String caseId,
    required F3DefectData data,
    String? note,
    String? correctsRecordId,
  }) async {
    final errors = F3DefectData.validate(data);
    if (errors.isNotEmpty) {
      fieldErrors.value = errors;
      errorMessage.value = 'Lütfen formdaki eksik alanları tamamlayın.';
      status.value = ViewStatus.error;
      return false;
    }

    fieldErrors.value = const {};
    errorMessage.value = null;
    status.value = ViewStatus.loading;

    try {
      final record = await _recordService.addFormRecord(
        caseId: caseId,
        formType: 'F3',
        title: 'F3 Arıza Bildirimi: ${data.title}',
        note: note,
        formData: data.toMap(),
        correctsRecordId: correctsRecordId,
      );

      createdRecord.value = record;
      status.value = ViewStatus.success;
      return true;
    } catch (_) {
      errorMessage.value = 'Form kaydedilirken bir hata oluştu.';
      status.value = ViewStatus.error;
      return false;
    }
  }

  void dispose() {
    status.dispose();
    fieldErrors.dispose();
    errorMessage.dispose();
    createdRecord.dispose();
  }
}
