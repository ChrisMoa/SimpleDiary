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
  ConsumerState<SupabaseSettingsWidget> createState() =>
      _SupabaseSettingsWidgetState();
}

class _SupabaseSettingsWidgetState
    extends ConsumerState<SupabaseSettingsWidget> {
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _anonKeyVisible = false;

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.supabaseSettings,
      icon: Icons.cloud_outlined,
      footer: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _testConnection,
            icon: const Icon(Icons.cloud_circle_outlined, size: 20),
            label: Text(l10n.testConnection),
          ),
        ),
      ),
      children: [
        // Description
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            l10n.supabaseDescription,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        // URL field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppTextField(
            controller: _urlController,
            label: l10n.supabaseUrl,
            hint: 'https://your-project.supabase.co',
            prefixIcon: const Icon(Icons.link, size: 20),
            onChanged: (value) {
              ref
                  .read(supabaseSettingsProvider.notifier)
                  .updateUrl(value);
              settingsContainer.activeUserSettings.supabaseSettings =
                  settingsContainer.activeUserSettings.supabaseSettings
                      .copyWith(supabaseUrl: value);
            },
          ),
        ),
        // Anon key field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppTextField(
            controller: _anonKeyController,
            label: l10n.anonKey,
            hint: 'Your Supabase anon key',
            obscureText: !_anonKeyVisible,
            prefixIcon: const Icon(Icons.key, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _anonKeyVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _anonKeyVisible = !_anonKeyVisible),
            ),
            onChanged: (value) {
              ref
                  .read(supabaseSettingsProvider.notifier)
                  .updateAnonKey(value);
              settingsContainer.activeUserSettings.supabaseSettings =
                  settingsContainer.activeUserSettings.supabaseSettings
                      .copyWith(supabaseAnonKey: value);
            },
          ),
        ),
        // Email field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppTextField(
            controller: _emailController,
            label: l10n.email,
            hint: 'your.email@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email, size: 20),
            onChanged: (value) {
              ref
                  .read(supabaseSettingsProvider.notifier)
                  .updateEmail(value);
              settingsContainer.activeUserSettings.supabaseSettings =
                  settingsContainer.activeUserSettings.supabaseSettings
                      .copyWith(email: value);
            },
          ),
        ),
        // Password field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppTextField(
            controller: _passwordController,
            label: l10n.password,
            hint: 'Your Supabase password',
            obscureText: !_passwordVisible,
            prefixIcon: const Icon(Icons.lock, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
            onChanged: (value) {
              ref
                  .read(supabaseSettingsProvider.notifier)
                  .updatePassword(value);
              settingsContainer.activeUserSettings.supabaseSettings =
                  settingsContainer.activeUserSettings.supabaseSettings
                      .copyWith(password: value);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _testConnection() async {
    final settings = ref.read(supabaseSettingsProvider);

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
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackBar.info(context,
            message: l10n.testingConnection,
            duration: const Duration(seconds: 1));
      }

      final supabaseApi =
          SupabaseApi(tablePrefix: kDebugMode ? 'test_' : '');

      await supabaseApi.initialize(
          settings.supabaseUrl, settings.supabaseAnonKey);

      final success = await supabaseApi.signInWithEmailPassword(
          settings.email, settings.password);

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
}
