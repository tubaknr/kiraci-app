import 'package:flutter/foundation.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/services/record_service.dart';
import '../../records/models/record_model.dart';
import '../models/f2_handover_data.dart';

class F2HandoverController {
  final RecordService _recordService;

  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<Map<String, String>> fieldErrors = ValueNotifier(const {});
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<RecordModel?> createdRecord = ValueNotifier(null);

  F2HandoverController(this._recordService);

  Future<bool> submit({
    required String caseId,
    required F2HandoverData data,
    String? note,
    String? correctsRecordId,
  }) async {
    final errors = F2HandoverData.validate(data);
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
      final formTitle = data.handoverType == 'entry'
          ? 'F2 Teslim Alma Tespit Formu'
          : 'F2 Tahliye Teslim Formu';

      final record = await _recordService.addFormRecord(
        caseId: caseId,
        formType: 'F2',
        title: formTitle,
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
