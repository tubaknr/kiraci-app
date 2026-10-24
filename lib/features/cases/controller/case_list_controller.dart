import 'package:flutter/foundation.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/db/case_repository.dart';
import '../models/case_model.dart';

class CaseListController {
  final CaseRepository _caseRepository;

  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<List<CaseModel>> cases = ValueNotifier(const []);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  CaseListController(this._caseRepository);

  Future<void> loadCases() async {
    status.value = ViewStatus.loading;
    errorMessage.value = null;
    try {
      final items = await _caseRepository.getAll();
      cases.value = items;
      status.value = ViewStatus.success;
    } catch (_) {
      errorMessage.value = 'Dosyalar yüklenirken bir hata oluştu.';
      status.value = ViewStatus.error;
    }
  }

  void dispose() {
    status.dispose();
    cases.dispose();
    errorMessage.dispose();
  }
}
