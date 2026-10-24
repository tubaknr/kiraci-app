import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/services/export_service.dart';

class ExportController {
  final ExportService _exportService;

  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<File?> createdZipFile = ValueNotifier(null);
  final ValueNotifier<String?> sealCodeMessage = ValueNotifier(null);

  ExportController(this._exportService);

  Future<File?> exportZip(String caseId) async {
    status.value = ViewStatus.loading;
    errorMessage.value = null;

    try {
      final zip = await _exportService.createEvidenceZipPackage(caseId);
      createdZipFile.value = zip;
      status.value = ViewStatus.success;
      return zip;
    } catch (_) {
      errorMessage.value = 'ZIP delil paketi oluşturulurken bir hata oluştu.';
      status.value = ViewStatus.error;
      return null;
    }
  }

  Future<String?> generateSealCode(String caseId) async {
    status.value = ViewStatus.loading;
    errorMessage.value = null;

    try {
      final message = await _exportService.generateSealCodeMessage(caseId);
      sealCodeMessage.value = message;
      status.value = ViewStatus.success;
      return message;
    } catch (_) {
      errorMessage.value = 'Mühür kodu oluşturulamadı.';
      status.value = ViewStatus.error;
      return null;
    }
  }

  void dispose() {
    status.dispose();
    errorMessage.dispose();
    createdZipFile.dispose();
    sealCodeMessage.dispose();
  }
}
