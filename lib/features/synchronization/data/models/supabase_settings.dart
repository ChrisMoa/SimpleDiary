import 'dart:convert';

import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';

class SupabaseSettings {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String email;
  final String password;
  final bool autoSyncEnabled;
  final int autoSyncDebounceSeconds;
  final String? lastAutoSyncTimestamp;

  SupabaseSettings({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.email,
    required this.password,
    this.autoSyncEnabled = false,
    this.autoSyncDebounceSeconds = 30,
    this.lastAutoSyncTimestamp,
  });

  /// Whether Supabase connection credentials are fully configured.
  /// Requires HTTPS URL for security.
  bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseUrl.startsWith('https://') &&
      supabaseAnonKey.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty;

  /// Get the last auto-sync as DateTime, or null if never synced
  DateTime? get lastAutoSyncDateTime {
    if (lastAutoSyncTimestamp == null) return null;
    return DateTime.tryParse(lastAutoSyncTimestamp!);
  }

  /// App-level obfuscation key for encrypting credentials at rest.
  /// Protects against casual file system access and cloud backup exposure.
  static AesEncryptor? _encryptor;
  static AesEncryptor get _credentialEncryptor {
    _encryptor ??= AesEncryptor(
      encryptionKey: base64.encode(
        utf8.encode('day_tracker_supabase_credential_key!'),
      ),
    );
    return _encryptor!;
  }

  static String _encryptField(String value) {
    if (value.isEmpty) return '';
    try {
      return _credentialEncryptor.encryptStringAsBase64(value);
    } catch (e) {
      LogWrapper.logger.e('Failed to encrypt Supabase credential field: $e');
      return value;
    }
  }

  static String _decryptField(String value) {
    if (value.isEmpty) return '';
    try {
      return _credentialEncryptor.decryptStringFromBase64(value);
    } catch (_) {
      // Backward compatibility: return plaintext value if decryption fails
      // (e.g., migrating from unencrypted settings)
      return value;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'supabase_url': supabaseUrl,
      'supabase_anon_key': supabaseAnonKey,
      'email': _encryptField(email),
      'password': _encryptField(password),
      'auto_sync_enabled': autoSyncEnabled,
      'auto_sync_debounce_seconds': autoSyncDebounceSeconds,
      'last_auto_sync_timestamp': lastAutoSyncTimestamp,
      'credentials_encrypted': true,
    };
  }

  factory SupabaseSettings.fromMap(Map<String, dynamic> map) {
    final isEncrypted = map['credentials_encrypted'] as bool? ?? false;
    final rawEmail = map['email'] ?? '';
    final rawPassword = map['password'] ?? '';

    return SupabaseSettings(
      supabaseUrl: map['supabase_url'] ?? '',
      supabaseAnonKey: map['supabase_anon_key'] ?? '',
      email: isEncrypted ? _decryptField(rawEmail) : rawEmail,
      password: isEncrypted ? _decryptField(rawPassword) : rawPassword,
      autoSyncEnabled: map['auto_sync_enabled'] as bool? ?? false,
      autoSyncDebounceSeconds: map['auto_sync_debounce_seconds'] as int? ?? 30,
      lastAutoSyncTimestamp: map['last_auto_sync_timestamp'] as String?,
    );
  }

  factory SupabaseSettings.empty() {
    return SupabaseSettings(
      supabaseUrl: '',
      supabaseAnonKey: '',
      email: '',
      password: '',
    );
  }

  SupabaseSettings copyWith({
    String? supabaseUrl,
    String? supabaseAnonKey,
    String? email,
    String? password,
    bool? autoSyncEnabled,
    int? autoSyncDebounceSeconds,
    String? lastAutoSyncTimestamp,
  }) {
    return SupabaseSettings(
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      email: email ?? this.email,
      password: password ?? this.password,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      autoSyncDebounceSeconds:
          autoSyncDebounceSeconds ?? this.autoSyncDebounceSeconds,
      lastAutoSyncTimestamp:
          lastAutoSyncTimestamp ?? this.lastAutoSyncTimestamp,
    );
  }
}
