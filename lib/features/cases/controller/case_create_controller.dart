import 'package:flutter/foundation.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/db/case_repository.dart';
import '../models/case_model.dart';

class CaseCreateController {
  final CaseRepository _caseRepository;

  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<CaseModel?> createdCase = ValueNotifier(null);

  CaseCreateController(this._caseRepository);

  Future<bool> createCase({
    required String title,
    required String address,
    required String myRole,
    required String otherPartyName,
    required DateTime leaseStart,
    DateTime? leaseEnd,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedAddress = address.trim();
    final trimmedOtherParty = otherPartyName.trim();

    if (trimmedTitle.isEmpty) {
      errorMessage.value = 'Dosya başlığı boş bırakılamaz.';
      status.value = ViewStatus.error;
      return false;
    }

    if (trimmedAddress.isEmpty) {
      errorMessage.value = 'Taşınmaz adresi boş bırakılamaz.';
      status.value = ViewStatus.error;
      return false;
    }

    if (myRole != 'tenant' && myRole != 'landlord') {
      errorMessage.value = 'Geçerli bir taraf rolü seçilmelidir (kiracı veya ev sahibi).';
      status.value = ViewStatus.error;
      return false;
    }

    if (trimmedOtherParty.isEmpty) {
      errorMessage.value = 'Karşı taraf adı boş bırakılamaz.';
      status.value = ViewStatus.error;
      return false;
    }

    if (leaseEnd != null && leaseEnd.isBefore(leaseStart)) {
      errorMessage.value = 'Sözleşme bitiş tarihi başlangıç tarihinden önce olamaz.';
      status.value = ViewStatus.error;
      return false;
    }

    status.value = ViewStatus.loading;
    errorMessage.value = null;

    try {
      final nowUtc = DateTime.now().toUtc();
      final caseModel = CaseModel(
        id: 'case_${nowUtc.millisecondsSinceEpoch}',
        title: trimmedTitle,
        address: trimmedAddress,
        myRole: myRole,
        otherPartyName: trimmedOtherParty,
        leaseStart: leaseStart.toUtc(),
        leaseEnd: leaseEnd?.toUtc(),
        createdAt: nowUtc,
      );

      final inserted = await _caseRepository.insert(caseModel);
      createdCase.value = inserted;
      status.value = ViewStatus.success;
      return true;
    } catch (_) {
      errorMessage.value = 'Dosya oluşturulurken bir hata oluştu.';
      status.value = ViewStatus.error;
      return false;
    }
  }

  void dispose() {
    status.dispose();
    errorMessage.dispose();
    createdCase.dispose();
  }
}
