// ignore_for_file: public_member_api_docs
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/services/biometric_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiometricLockPage extends ConsumerStatefulWidget {
  const BiometricLockPage({super.key});

  @override
  ConsumerState<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends ConsumerState<BiometricLockPage> {
  final BiometricService _biometricService = BiometricService();
  String? _errorMessage;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometric();
    });
  }

  Future<void> _triggerBiometric() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final l10n = AppLocalizations.of(context);
      final success = await _biometricService.authenticate(
        l10n.biometricUnlockPrompt,
      );

      if (!mounted) return;

      if (success) {
        await _loginWithStoredCredentials();
      } else {
        setState(() {
          _errorMessage = l10n.biometricTestFailed;
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      LogWrapper.logger.e('Biometric authentication error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _loginWithStoredCredentials() async {
    final userData = ref.read(userDataProvider);
    final password = await _biometricService.getStoredPassword(userData.username);

    if (!mounted) return;

    if (password != null) {
      final success = ref
          .read(userDataProvider.notifier)
          .login(userData.username, password);

      if (!success && mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _errorMessage = l10n.biometricEnrollFailed;
          _isAuthenticating = false;
        });
      }
    } else {
      // No stored credentials — fall back to password
      _switchToPassword();
    }
  }

  void _switchToPassword() {
    // Setting biometric to disabled forces MainPage to show PasswordAuthenticationPage
    settingsContainer.activeUserSettings.biometricSettings.isEnabled = false;
    ref.read(userDataProvider.notifier).lockSession();
    // Re-enable for next login
    settingsContainer.activeUserSettings.biometricSettings.isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome text
                Text(
                  l10n.welcomeBack,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userData.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.biometricTapToUnlock,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 40),

                // Biometric button
                Card(
                  elevation: 2,
                  color: theme.colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Fingerprint icon button
                        IconButton(
                          onPressed: _isAuthenticating ? null : _triggerBiometric,
                          icon: Icon(
                            Icons.fingerprint,
                            size: 64,
                            color: _isAuthenticating
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Error message
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Retry button
                        if (!_isAuthenticating && _errorMessage != null)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _triggerBiometric,
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.biometricRetry),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                        if (_isAuthenticating)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Use password instead
                TextButton.icon(
                  onPressed: _switchToPassword,
                  icon: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    l10n.usePasswordInstead,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),

                // Switch user
                TextButton.icon(
                  onPressed: () {
                    ref.read(userDataProvider.notifier).logout();
                  },
                  icon: Icon(
                    Icons.swap_horiz,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    l10n.switchUser,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
