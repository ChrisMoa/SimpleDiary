import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [SettingsContainer] instance via Riverpod.
///
/// Overridden in `main()` with the loaded settings, and in tests
/// with a fresh [SettingsContainer] for isolation.
final settingsProvider = Provider<SettingsContainer>((ref) {
  // ignore: deprecated_member_use_from_same_package
  return settingsContainer;
});

/// Helper that wraps [SettingsContainer.saveSettings] for use via `ref`.
///
/// Usage: `ref.read(settingsNotifierProvider).saveSettings()`
class SettingsNotifier {
  final SettingsContainer _container;
  SettingsNotifier(this._container);

  Future<void> saveSettings() => _container.saveSettings();
}

final settingsNotifierProvider = Provider<SettingsNotifier>((ref) {
  return SettingsNotifier(ref.read(settingsProvider));
});
