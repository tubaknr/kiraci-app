import 'package:flutter/foundation.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/services/lock_service.dart';

class LockController {
  final LockService _lockService;

  final ValueNotifier<ViewStatus> status = ValueNotifier(ViewStatus.idle);
  final ValueNotifier<bool> isLocked = ValueNotifier(false);
  final ValueNotifier<bool> isConfigured = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  LockConfig _currentConfig = const LockConfig();

  LockController(this._lockService);

  Future<void> checkLockState() async {
    status.value = ViewStatus.loading;
    errorMessage.value = null;

    try {
      _currentConfig = await _lockService.loadConfig();
      isConfigured.value = _currentConfig.isEnabled && _currentConfig.hasPin;
      isLocked.value = isConfigured.value;
      status.value = ViewStatus.success;
    } catch (_) {
      errorMessage.value = 'Kilit durumu yüklenemedi.';
      status.value = ViewStatus.error;
    }
  }

  Future<bool> setupLock({
    required String pin,
    bool enableBiometrics = false,
  }) async {
    final cleanPin = pin.trim();
    if (cleanPin.length < 4 || cleanPin.length > 8) {
      errorMessage.value = 'PIN kodu 4 ile 8 hane arasında olmalıdır.';
      status.value = ViewStatus.error;
      return false;
    }

    status.value = ViewStatus.loading;
    errorMessage.value = null;

    try {
      final salt = LockService.generateSalt();
      final hash = LockService.hashPin(cleanPin, salt);

      _currentConfig = LockConfig(
        isEnabled: true,
        pinSalt: salt,
        pinHash: hash,
        biometricsEnabled: enableBiometrics,
      );

      await _lockService.saveConfig(_currentConfig);
      isConfigured.value = true;
      isLocked.value = false;
      status.value = ViewStatus.success;
      return true;
    } catch (_) {
      errorMessage.value = 'Kilit ayarlanırken bir hata oluştu.';
      status.value = ViewStatus.error;
      return false;
    }
  }

  Future<bool> unlockWithPin(String inputPin) async {
    if (!_currentConfig.hasPin) {
      isLocked.value = false;
      return true;
    }

    final isValid = LockService.verifyPin(
      inputPin.trim(),
      _currentConfig.pinSalt!,
      _currentConfig.pinHash!,
    );

    if (isValid) {
      isLocked.value = false;
      errorMessage.value = null;
      status.value = ViewStatus.success;
      return true;
    } else {
      errorMessage.value = 'Hatalı PIN kodu girdiniz.';
      status.value = ViewStatus.error;
      return false;
    }
  }

  Future<bool> unlockWithBiometrics() async {
    if (!_currentConfig.biometricsEnabled) return false;

    status.value = ViewStatus.loading;
    errorMessage.value = null;

    final success = await _lockService.authenticateWithBiometrics();
    if (success) {
      isLocked.value = false;
      status.value = ViewStatus.success;
      return true;
    } else {
      errorMessage.value = 'Biyometrik doğrulama başarısız oldu.';
      status.value = ViewStatus.error;
      return false;
    }
  }

  Future<bool> disableLock(String currentPin) async {
    final unlocked = await unlockWithPin(currentPin);
    if (!unlocked) return false;

    _currentConfig = const LockConfig(isEnabled: false);
    await _lockService.saveConfig(_currentConfig);
    isConfigured.value = false;
    isLocked.value = false;
    return true;
  }

  void dispose() {
    status.dispose();
    isLocked.dispose();
    isConfigured.dispose();
    errorMessage.dispose();
  }
}
