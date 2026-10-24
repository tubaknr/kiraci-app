import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/services/lock_service.dart';
import 'package:saferenthouse/features/lock/controller/lock_controller.dart';

void main() {
  late Directory tempDir;
  late LockService lockService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lock_test_');
    lockService = LockService(
      getAppDocDir: () async => tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LockService Salted Hash Tests', () {
    test('generateSalt benzersiz ve beklenen uzunlukta tuz uretmelidir', () {
      final salt1 = LockService.generateSalt(16);
      final salt2 = LockService.generateSalt(16);

      expect(salt1.length, 16);
      expect(salt2.length, 16);
      expect(salt1, isNot(salt2));
    });

    test('hashPin ve verifyPin dogru calismalidir', () {
      const pin = '1234';
      final salt = LockService.generateSalt();
      final hash = LockService.hashPin(pin, salt);

      expect(LockService.verifyPin('1234', salt, hash), isTrue);
      expect(LockService.verifyPin('0000', salt, hash), isFalse);
      expect(LockService.verifyPin('12345', salt, hash), isFalse);
    });

    test('saveConfig ve loadConfig kilit ayarlarini dosyaya yazip okumali', () async {
      const config = LockConfig(
        isEnabled: true,
        pinSalt: 'salt_abc',
        pinHash: 'hash_xyz',
        biometricsEnabled: true,
      );

      await lockService.saveConfig(config);
      final loaded = await lockService.loadConfig();

      expect(loaded.isEnabled, isTrue);
      expect(loaded.pinSalt, 'salt_abc');
      expect(loaded.pinHash, 'hash_xyz');
      expect(loaded.biometricsEnabled, isTrue);
    });
  });

  group('LockController Tests', () {
    test('setupLock ve unlockWithPin akisi dogru calismalidir', () async {
      final controller = LockController(lockService);

      // Kisa PIN dogrulama hatasi
      final shortSuccess = await controller.setupLock(pin: '12');
      expect(shortSuccess, isFalse);
      expect(controller.status.value, ViewStatus.error);

      // Gecerli PIN kurulumu
      final success = await controller.setupLock(pin: '5678');
      expect(success, isTrue);
      expect(controller.isConfigured.value, isTrue);

      // Uygulama yeniden baslatildi ve kilitli basladi
      await controller.checkLockState();
      expect(controller.isLocked.value, isTrue);

      // Yanlis PIN ile deneme
      final wrongUnlock = await controller.unlockWithPin('0000');
      expect(wrongUnlock, isFalse);
      expect(controller.isLocked.value, isTrue);
      expect(controller.errorMessage.value, 'Hatalı PIN kodu girdiniz.');

      // Dogru PIN ile kilit acma
      final correctUnlock = await controller.unlockWithPin('5678');
      expect(correctUnlock, isTrue);
      expect(controller.isLocked.value, isFalse);

      // Kilidi devre disi birakma
      final disabled = await controller.disableLock('5678');
      expect(disabled, isTrue);
      expect(controller.isConfigured.value, isFalse);

      controller.dispose();
    });
  });
}
