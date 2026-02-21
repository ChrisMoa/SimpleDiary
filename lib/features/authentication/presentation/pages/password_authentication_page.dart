import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordAuthenticationPage extends ConsumerStatefulWidget {
  const PasswordAuthenticationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PasswordAuthenticationPageState();
}

class _PasswordAuthenticationPageState
    extends ConsumerState<PasswordAuthenticationPage> {
  late final TextEditingController _passwordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
            child: Form(
              key: _formKey,
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
                      Icons.book_outlined,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  AppSpacing.verticalXxl,

                  // Welcome text
                  Text(
                    l10n.welcomeBack,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    userData.username,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    l10n.enterPasswordToContinue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Password card
                  AppCard.outlined(
                    color: theme.colorScheme.secondaryContainer,
                    borderColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                    padding: AppSpacing.paddingAllXl,
                    child: Column(
                        children: [
                          // Password field
                          AppTextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            label: l10n.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterYourPassword;
                              }
                              return null;
                            },
                          ),
                          AppSpacing.verticalXl,

                          // Sign in button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _attemptLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderRadiusMd,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.signIn,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ),
                  AppSpacing.verticalMd,

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
      ),
    );
  }

  void _attemptLogin() {
    final l10n = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      final userData = ref.read(userDataProvider);
      bool success = ref
          .read(userDataProvider.notifier)
          .login(userData.username, _passwordController.text);

      if (!success) {
        AppSnackBar.error(context, message: l10n.incorrectPassword);
      }
    }
  }
}
