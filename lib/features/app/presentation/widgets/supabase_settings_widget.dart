import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/synchronization/domain/providers/supabase_provider.dart';
import 'package:day_tracker/features/synchronization/data/repositories/supabase_api.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseSettingsWidget extends ConsumerStatefulWidget {
  const SupabaseSettingsWidget({super.key});

  @override
  ConsumerState<SupabaseSettingsWidget> createState() => _SupabaseSettingsWidgetState();
}

class _SupabaseSettingsWidgetState extends ConsumerState<SupabaseSettingsWidget> {
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _anonKeyVisible = false;

  @override
  void initState() {
    super.initState();
    // Load existing settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = settingsContainer.activeUserSettings.supabaseSettings;
      _urlController.text = settings.supabaseUrl;
      _anonKeyController.text = settings.supabaseAnonKey;
      _emailController.text = settings.email;
      _passwordController.text = settings.password;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

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
                    Icons.cloud,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  AppSpacing.horizontalXs,
                  Text(
                    l10n.supabaseSettings,
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
                l10n.supabaseDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              AppSpacing.verticalXl,

              // Settings Form
              _buildTextField(
                controller: _urlController,
                label: l10n.supabaseUrl,
                hint: 'https://your-project.supabase.co',
                icon: Icons.link,
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updateUrl(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(supabaseUrl: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              _buildTextField(
                controller: _anonKeyController,
                label: l10n.anonKey,
                hint: 'Your Supabase anon key',
                icon: Icons.key,
                isPassword: !_anonKeyVisible,
                toggleVisibility: () {
                  setState(() {
                    _anonKeyVisible = !_anonKeyVisible;
                  });
                },
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updateAnonKey(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(supabaseAnonKey: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              _buildTextField(
                controller: _emailController,
                label: l10n.email,
                hint: 'your.email@example.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updateEmail(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(email: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              _buildTextField(
                controller: _passwordController,
                label: l10n.password,
                hint: 'Your Supabase password',
                icon: Icons.lock,
                isPassword: !_passwordVisible,
                toggleVisibility: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                onChanged: (value) {
                  ref.read(supabaseSettingsProvider.notifier).updatePassword(value);
                  settingsContainer.activeUserSettings.supabaseSettings = settingsContainer.activeUserSettings.supabaseSettings.copyWith(password: value);
                },
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: isSmallScreen ? 16 : 24),

              // Test Connection Button
              _buildTestConnectionButton(theme, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestConnectionButton(ThemeData theme, bool isSmallScreen) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 48 : 52,
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusMd,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha:0.8),
          ],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: _testConnection,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
        ),
        icon: Icon(
          Icons.cloud_circle_outlined,
          size: isSmallScreen ? 20 : 24,
          color: theme.colorScheme.onPrimary,
        ),
        label: Text(
          l10n.testConnection,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    final settings = ref.read(supabaseSettingsProvider);

    // Validate that all fields are filled
    if (settings.supabaseUrl.isEmpty ||
        settings.supabaseAnonKey.isEmpty ||
        settings.email.isEmpty ||
        settings.password.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackBar.error(context, message: l10n.pleaseEnterAllFields);
      }
      return;
    }

    try {
      // Show loading indicator
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackBar.info(context, message: l10n.testingConnection, duration: const Duration(seconds: 1));
      }

      final supabaseApi = SupabaseApi(tablePrefix: kDebugMode ? 'test_' : '');

      // Initialize
      await supabaseApi.initialize(settings.supabaseUrl, settings.supabaseAnonKey);

      // Test authentication
      final success = await supabaseApi.signInWithEmailPassword(settings.email, settings.password);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (success) {
          AppSnackBar.success(context, message: l10n.connectionSuccessful);
        } else {
          AppSnackBar.error(context, message: l10n.connectionFailedAuth);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackBar.error(context, message: l10n.connectionFailed(e.toString()));
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return AppTextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      label: label,
      hint: hint,
      prefixIcon: Icon(icon, size: isSmallScreen ? 20 : 24),
      suffixIcon: toggleVisibility != null
          ? IconButton(
              icon: Icon(
                isPassword ? Icons.visibility : Icons.visibility_off,
                size: isSmallScreen ? 20 : 24,
              ),
              onPressed: toggleVisibility,
            )
          : null,
    );
  }
}
