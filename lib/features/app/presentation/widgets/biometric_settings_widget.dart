// ignore_for_file: public_member_api_docs
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/biometric_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/domain/providers/biometric_provider.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Widget for managing biometric authentication settings
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
    final settings =
        settingsContainer.activeUserSettings.biometricSettings;
    _biometricEnabled = settings.isEnabled;
    _requireOnResume = settings.requireOnResume;
    _lockTimeoutMinutes = settings.lockTimeoutMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final biometricAvailable = ref.watch(biometricAvailableProvider);

    return AppCard.elevated(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.fingerprint,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  AppSpacing.horizontalXs,
                  Text(
                    l10n.biometricSettings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalMd,

              Text(
                l10n.biometricSettingsDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              AppSpacing.verticalXl,

              biometricAvailable.when(
                data: (isAvailable) {
                  if (!isAvailable) {
                    return _buildNotAvailableMessage(theme, l10n);
                  }
                  return _buildBiometricControls(theme, isSmallScreen, l10n);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => _buildNotAvailableMessage(theme, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotAvailableMessage(ThemeData theme, AppLocalizations l10n) {
    return _buildSettingContainer(
      theme,
      true,
      l10n.enableBiometric,
      l10n.biometricNotAvailable,
      Switch(
        value: false,
        onChanged: null,
      ),
    );
  }

  Widget _buildBiometricControls(
      ThemeData theme, bool isSmallScreen, AppLocalizations l10n) {
    return Column(
      children: [
        // Enable/Disable toggle
        _buildSettingContainer(
          theme,
          isSmallScreen,
          l10n.enableBiometric,
          l10n.enableBiometricDescription,
          Switch(
            value: _biometricEnabled,
            onChanged: _onBiometricToggled,
          ),
        ),

        if (_biometricEnabled) ...[
          SizedBox(height: isSmallScreen ? 16 : 20),

          // Biometric type display
          FutureBuilder<List<BiometricType>>(
            future: _biometricService.getAvailableBiometrics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final types = snapshot.data!;
              final typeNames = types.map((t) {
                switch (t) {
                  case BiometricType.fingerprint:
                    return 'Fingerprint';
                  case BiometricType.face:
                    return 'Face ID';
                  case BiometricType.iris:
                    return 'Iris';
                  default:
                    return t.name;
                }
              }).join(', ');

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.colorScheme.primary,
                      ),
                      AppSpacing.horizontalSm,
                      Text(
                        typeNames,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Lock on resume
          _buildSettingContainer(
            theme,
            isSmallScreen,
            l10n.biometricLockOnResume,
            l10n.biometricLockOnResumeDescription,
            Switch(
              value: _requireOnResume,
              onChanged: (value) {
                setState(() {
                  _requireOnResume = value;
                  settingsContainer.activeUserSettings.biometricSettings
                      .requireOnResume = value;
                });
                settingsContainer.saveSettings();
              },
            ),
          ),

          if (_requireOnResume) ...[
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Lock timeout
            _buildSettingContainer(
              theme,
              isSmallScreen,
              l10n.biometricLockTimeout,
              l10n.biometricLockTimeoutDescription,
              DropdownButton<int>(
                value: _lockTimeoutMinutes,
                dropdownColor: theme.colorScheme.surfaceContainer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                items: [
                  DropdownMenuItem(
                      value: 0, child: Text(l10n.biometricImmediately)),
                  DropdownMenuItem(
                      value: 1, child: Text(l10n.biometricMinutes(1))),
                  DropdownMenuItem(
                      value: 5, child: Text(l10n.biometricMinutes(5))),
                  DropdownMenuItem(
                      value: 15, child: Text(l10n.biometricMinutes(15))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _lockTimeoutMinutes = value;
                      settingsContainer.activeUserSettings.biometricSettings
                          .lockTimeoutMinutes = value;
                    });
                    settingsContainer.saveSettings();
                  }
                },
              ),
            ),
          ],

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Test biometric button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testBiometric,
              icon: const Icon(Icons.fingerprint),
              label: Text(l10n.biometricTestButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusSm,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingContainer(
    ThemeData theme,
    bool isSmallScreen,
    String title,
    String description,
    Widget control,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: .2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalXs,
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .7),
            ),
          ),
          AppSpacing.verticalMd,
          control,
        ],
      ),
    );
  }

  Future<void> _onBiometricToggled(bool value) async {
    final l10n = AppLocalizations.of(context);

    if (value) {
      // Verify biometric works before enabling
      final success = await _biometricService.authenticate(
        l10n.biometricUnlockPrompt,
      );

      if (!success) {
        if (mounted) {
          AppSnackBar.error(context, message: l10n.biometricEnrollFailed);
        }
        return;
      }

      // Store credentials for auto-login
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
      // Clear stored credentials
      final userData = ref.read(userDataProvider);
      await _biometricService.clearCredentials(userData.username);
    }

    setState(() {
      _biometricEnabled = value;
      settingsContainer.activeUserSettings.biometricSettings.isEnabled = value;
    });
    await settingsContainer.saveSettings();
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
