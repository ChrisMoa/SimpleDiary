// ignore_for_file: public_member_api_docs
import 'package:day_tracker/core/services/biometric_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether biometric hardware is available on this device
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  return await BiometricService().isAvailable();
});

/// Detailed biometric availability status
final biometricStatusProvider = FutureProvider<BiometricStatus>((ref) async {
  return await BiometricService().getAvailabilityStatus();
});

/// Whether the current user has biometric login enabled
final biometricEnabledProvider = Provider<bool>((ref) {
  return settingsContainer.activeUserSettings.biometricSettings.isEnabled;
});
