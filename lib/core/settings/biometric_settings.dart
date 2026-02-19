// ignore_for_file: public_member_api_docs
import 'dart:convert';

/// Settings for biometric authentication configuration
class BiometricSettings {
  /// User has enabled biometric login
  bool isEnabled;

  /// Require biometric re-auth when app resumes from background
  bool requireOnResume;

  /// Minutes in background before requiring re-authentication (0 = always)
  int lockTimeoutMinutes;

  BiometricSettings({
    required this.isEnabled,
    required this.requireOnResume,
    required this.lockTimeoutMinutes,
  });

  /// Create default biometric settings (disabled)
  factory BiometricSettings.fromEmpty() => BiometricSettings(
        isEnabled: false,
        requireOnResume: false,
        lockTimeoutMinutes: 5,
      );

  /// Serialize to JSON
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isEnabled': isEnabled,
      'requireOnResume': requireOnResume,
      'lockTimeoutMinutes': lockTimeoutMinutes,
    };
  }

  /// Deserialize from JSON
  factory BiometricSettings.fromMap(Map<String, dynamic> map) {
    return BiometricSettings(
      isEnabled: map['isEnabled'] as bool? ?? false,
      requireOnResume: map['requireOnResume'] as bool? ?? false,
      lockTimeoutMinutes: map['lockTimeoutMinutes'] as int? ?? 5,
    );
  }

  String toJson() => json.encode(toMap());

  factory BiometricSettings.fromJson(String source) =>
      BiometricSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Create a copy with optional field updates
  BiometricSettings copyWith({
    bool? isEnabled,
    bool? requireOnResume,
    int? lockTimeoutMinutes,
  }) {
    return BiometricSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      requireOnResume: requireOnResume ?? this.requireOnResume,
      lockTimeoutMinutes: lockTimeoutMinutes ?? this.lockTimeoutMinutes,
    );
  }

  @override
  String toString() {
    return 'BiometricSettings(isEnabled: $isEnabled, requireOnResume: $requireOnResume, lockTimeoutMinutes: $lockTimeoutMinutes)';
  }
}
