import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../integrity/hash_utils.dart';

@immutable
class LockConfig {
  final bool isEnabled;
  final String? pinSalt;
  final String? pinHash;
  final bool biometricsEnabled;

  const LockConfig({
    this.isEnabled = false,
    this.pinSalt,
    this.pinHash,
    this.biometricsEnabled = false,
  });

  bool get hasPin => pinHash != null && pinSalt != null;

  Map<String, dynamic> toMap() => {
        'is_enabled': isEnabled,
        'pin_salt': pinSalt,
        'pin_hash': pinHash,
        'biometrics_enabled': biometricsEnabled,
      };

  factory LockConfig.fromMap(Map<String, dynamic> map) => LockConfig(
        isEnabled: map['is_enabled'] as bool? ?? false,
        pinSalt: map['pin_salt'] as String?,
        pinHash: map['pin_hash'] as String?,
        biometricsEnabled: map['biometrics_enabled'] as bool? ?? false,
      );
}

class LockService {
  final LocalAuthentication _localAuth;
  final Future<Directory> Function() _getAppDocDir;

  LockService({
    LocalAuthentication? localAuth,
    Future<Directory> Function()? getAppDocDir,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _getAppDocDir = getAppDocDir ?? getApplicationDocumentsDirectory;

  /// Kriptografik rastgele tuz (salt) üretir.
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return HashUtils.sha256Hex(values).substring(0, length);
  }

  /// PIN kodunu tuzlayarak (salted) SHA-256 ile özetler.
  /// Doğrudan hashlemek yerine rainbow table saldırılarına karşı tuzlama zorunludur.
  static String hashPin(String pin, String salt) {
    return HashUtils.sha256String('SALT_${salt}_PIN_$pin');
  }

  /// Girilen PIN kodunun doğruluğunu kontrol eder.
  static bool verifyPin(String inputPin, String salt, String expectedHash) {
    final computed = hashPin(inputPin, salt);
    return computed == expectedHash;
  }

  /// Kilit yapılandırma dosyasını okur.
  Future<LockConfig> loadConfig() async {
    final file = await _getConfigFile();
    if (!await file.exists()) {
      return const LockConfig();
    }

    try {
      final jsonStr = await file.readAsString();
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return LockConfig.fromMap(map);
    } catch (_) {
      return const LockConfig();
    }
  }

  /// Yeni PIN ve kilit yapılandırmasını kaydeder.
  Future<void> saveConfig(LockConfig config) async {
    final file = await _getConfigFile();
    final jsonStr = jsonEncode(config.toMap());
    await file.writeAsString(jsonStr);
  }

  /// Cihazın biyometrik donanım desteğini kontrol eder.
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Biyometrik (parmak izi / yüz tanıma) ile kimlik doğrulama yapar.
  Future<bool> authenticateWithBiometrics({
    String reason = 'SafeRentHouse delil kütüphanesine erişmek için doğrulayın',
  }) async {
    if (kIsWeb) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<File> _getConfigFile() async {
    final dir = await _getAppDocDir();
    return File(p.join(dir.path, 'lock_config.json'));
  }
}
