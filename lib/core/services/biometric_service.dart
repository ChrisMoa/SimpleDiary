// ignore_for_file: public_member_api_docs
import 'dart:convert';

import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Status of biometric availability on the device
enum BiometricStatus {
  available,
  noHardware,
  notEnrolled,
  unsupportedPlatform,
}

/// Service for handling biometric authentication and secure credential storage
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// App-level encryptor for defense-in-depth credential encryption.
  /// Adds an encryption layer on top of flutter_secure_storage's OS-level encryption.
  static AesEncryptor? _encryptor;
  static AesEncryptor get _credentialEncryptor {
    _encryptor ??= AesEncryptor(
      encryptionKey: base64.encode(
        utf8.encode('day_tracker_biometric_credential_k!'),
      ),
    );
    return _encryptor!;
  }

  /// Check if biometric authentication is available on this device
  Future<bool> isAvailable() async {
    if (!_isSupportedPlatform()) return false;

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException catch (e) {
      LogWrapper.logger.e('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get detailed availability status
  Future<BiometricStatus> getAvailabilityStatus() async {
    if (!_isSupportedPlatform()) return BiometricStatus.unsupportedPlatform;

    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) return BiometricStatus.noHardware;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return BiometricStatus.notEnrolled;

      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) return BiometricStatus.notEnrolled;

      return BiometricStatus.available;
    } on PlatformException catch (e) {
      LogWrapper.logger.e('Error checking biometric status: $e');
      return BiometricStatus.noHardware;
    }
  }

  /// Get list of available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!_isSupportedPlatform()) return [];

    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      LogWrapper.logger.e('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Trigger biometric authentication prompt
  Future<bool> authenticate(String localizedReason) async {
    if (!_isSupportedPlatform()) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      LogWrapper.logger.e('Biometric authentication error: $e');
      return false;
    }
  }

  /// Store user credentials securely for auto-login after biometric success.
  /// Password is encrypted with app-level AES before storing in secure storage.
  Future<void> storeCredentials(String username, String password) async {
    try {
      final encrypted = _credentialEncryptor.encryptStringAsBase64(password);
      await _secureStorage.write(
        key: _credentialKey(username),
        value: encrypted,
      );
      LogWrapper.logger.i('Stored encrypted biometric credentials for $username');
    } catch (e) {
      LogWrapper.logger.e('Error storing biometric credentials: $e');
      rethrow;
    }
  }

  /// Retrieve stored credentials after biometric authentication success.
  /// Decrypts the app-level AES encryption layer.
  /// Handles backward compatibility with legacy plaintext credentials.
  Future<String?> getStoredPassword(String username) async {
    try {
      final stored = await _secureStorage.read(key: _credentialKey(username));
      if (stored == null) return null;
      try {
        return _credentialEncryptor.decryptStringFromBase64(stored);
      } catch (_) {
        // Backward compatibility: stored value is plaintext (pre-encryption)
        // Re-store it encrypted for next time
        LogWrapper.logger.i('Migrating legacy plaintext biometric credential for $username');
        await storeCredentials(username, stored);
        return stored;
      }
    } catch (e) {
      LogWrapper.logger.e('Error reading biometric credentials: $e');
      return null;
    }
  }

  /// Clear stored credentials (on logout or biometric disable)
  Future<void> clearCredentials(String username) async {
    try {
      await _secureStorage.delete(key: _credentialKey(username));
      LogWrapper.logger.i('Cleared biometric credentials for $username');
    } catch (e) {
      LogWrapper.logger.e('Error clearing biometric credentials: $e');
    }
  }

  /// Check if credentials are stored for a user
  Future<bool> hasStoredCredentials(String username) async {
    try {
      final password = await _secureStorage.read(key: _credentialKey(username));
      return password != null;
    } catch (e) {
      return false;
    }
  }

  String _credentialKey(String username) => 'biometric_pwd_$username';

  bool _isSupportedPlatform() {
    return activePlatform.platform == ActivePlatform.android ||
        activePlatform.platform == ActivePlatform.ios;
  }
}
