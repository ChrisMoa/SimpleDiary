import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/biometric_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/domain/providers/biometric_provider.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiometricSettingsWidget extends ConsumerStatefulWidget {
  const BiometricSettingsWidget({super.key});

  @override
  ConsumerState<BiometricSettingsWidget> createState() =>
      _BiometricSettingsWidgetState();
}

class _BiometricSettingsWidgetState
    extends ConsumerState<BiometricSettingsWidget> {
  final BiometricService _biometricService = BiometricService();
  late bool _biometricEnabled;
  late bool _requireOnResume;
  late int _lockTimeoutMinutes;

  @override
  void initState() {
    super.initState();
    final settings = settingsContainer.activeUserSettings.biometricSettings;
    _biometricEnabled = settings.isEnabled;
    _requireOnResume = settings.requireOnResume;
    _lockTimeoutMinutes = settings.lockTimeoutMinutes;
  }

  void _autoSave() => settingsContainer.saveSettings().ignore();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final biometricAvailable = ref.watch(biometricAvailableProvider);

    return biometricAvailable.when(
      loading: () => SettingsSection(
        title: l10n.biometricSettings,
        icon: Icons.fingerprint,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerPlaceholder(
                height: 56, borderRadius: AppRadius.borderRadiusMd),
          ),
        ],
      ),
      error: (_, __) => SettingsSection(
        title: l10n.biometricSettings,
        icon: Icons.fingerprint,
        children: [
          SettingsTile(
            icon: Icons.fingerprint,
            title: l10n.enableBiometric,
            subtitle: l10n.biometricNotAvailable,
            trailing: Switch(value: false, onChanged: null),
            enabled: false,
          ),
        ],
      ),
      data: (isAvailable) {
        if (!isAvailable) {
          return SettingsSection(
            title: l10n.biometricSettings,
            icon: Icons.fingerprint,
            children: [
              SettingsTile(
                icon: Icons.fingerprint,
                title: l10n.enableBiometric,
                subtitle: l10n.biometricNotAvailable,
                trailing: Switch(value: false, onChanged: null),
                enabled: false,
              ),
            ],
          );
        }

        return SettingsSection(
          title: l10n.biometricSettings,
          icon: Icons.fingerprint,
          footer: _biometricEnabled
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: _testBiometric,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fingerprint, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.biometricTestButton),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
          children: [
            SettingsTile(
              icon: Icons.fingerprint,
              title: l10n.enableBiometric,
              subtitle: l10n.enableBiometricDescription,
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: _onBiometricToggled,
              ),
            ),
            if (_biometricEnabled) ...[
              SettingsTile(
                icon: Icons.lock_clock,
                title: l10n.biometricLockOnResume,
                subtitle: l10n.biometricLockOnResumeDescription,
                trailing: Switch(
                  value: _requireOnResume,
                  onChanged: (value) {
                    setState(() {
                      _requireOnResume = value;
                      settingsContainer.activeUserSettings.biometricSettings
                          .requireOnResume = value;
                    });
                    _autoSave();
                  },
                ),
              ),
              if (_requireOnResume)
                SettingsExpandedTile(
                  icon: Icons.timer_outlined,
                  title: l10n.biometricLockTimeout,
                  subtitle: l10n.biometricLockTimeoutDescription,
                  control: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.4),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: DropdownButton<int>(
                      value: _lockTimeoutMinutes,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      dropdownColor: theme.colorScheme.surfaceContainer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 0,
                            child: Text(l10n.biometricImmediately)),
                        DropdownMenuItem(
                            value: 1,
                            child: Text(l10n.biometricMinutes(1))),
                        DropdownMenuItem(
                            value: 5,
                            child: Text(l10n.biometricMinutes(5))),
                        DropdownMenuItem(
                            value: 15,
                            child: Text(l10n.biometricMinutes(15))),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _lockTimeoutMinutes = value;
                            settingsContainer
                                .activeUserSettings.biometricSettings
                                .lockTimeoutMinutes = value;
                          });
                          _autoSave();
                        }
                      },
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _onBiometricToggled(bool value) async {
    final l10n = AppLocalizations.of(context);

    if (value) {
      final success = await _biometricService.authenticate(
        l10n.biometricUnlockPrompt,
      );

      if (!success) {
        if (mounted) {
          AppSnackBar.error(context, message: l10n.biometricEnrollFailed);
        }
        return;
      }

      final userData = ref.read(userDataProvider);
      if (userData.clearPassword.isNotEmpty) {
        await _biometricService.storeCredentials(
          userData.username,
          userData.clearPassword,
        );
      } else {
        LogWrapper.logger
            .e('Cannot store biometric credentials: no clear password');
        if (mounted) {
          AppSnackBar.error(context, message: l10n.biometricEnrollFailed);
        }
        return;
      }

      if (mounted) {
        AppSnackBar.success(context, message: l10n.biometricEnrollSuccess);
      }
    } else {
      final userData = ref.read(userDataProvider);
      await _biometricService.clearCredentials(userData.username);
    }

    setState(() {
      _biometricEnabled = value;
      settingsContainer.activeUserSettings.biometricSettings.isEnabled = value;
    });
    _autoSave();
  }

  Future<void> _testBiometric() async {
    final l10n = AppLocalizations.of(context);
    final success = await _biometricService.authenticate(
      l10n.biometricUnlockPrompt,
    );

    if (!mounted) return;

    if (success) {
      AppSnackBar.success(context, message: l10n.biometricTestSuccess);
    } else {
      AppSnackBar.error(context, message: l10n.biometricTestFailed);
    }
  }
}
