import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthUserDataPage extends ConsumerStatefulWidget {
  const AuthUserDataPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AuthUserDataPageState();
}

class _AuthUserDataPageState extends ConsumerState<AuthUserDataPage> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = settingsContainer.userSettings.isNotEmpty;
  var _isAuthenticating = false;
  var _isRemoteAccount = false;
  var _isPasswordVisible = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  //? build --------------------------------------------------------------------

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              AppCard.elevated(
                margin: AppSpacing.paddingAllLg,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: AppSpacing.paddingAllMd,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildUsernameField(),
                          AppSpacing.verticalSm,
                          _buildPasswordField(),
                          AppSpacing.verticalSm,
                          if (!_isLogin) _buildEmailField(),
                          if (!_isLogin) AppSpacing.verticalSm,
                          if (!_isLogin) _buildRemoteAccCheckbox(),
                          AppSpacing.verticalSm,
                          if (_isAuthenticating)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            ),
                          if (!_isAuthenticating) _buildLoginButton(),
                          if (!_isAuthenticating) _buildRegisterButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //? builds -------------------------------------------------------------------

  Widget _buildUsernameField() {
    final l10n = AppLocalizations.of(context);
    return AppTextField(
      controller: _usernameController,
      label: l10n.username,
      prefixIcon: const Icon(Icons.person),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.pleaseEnterUsername;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final l10n = AppLocalizations.of(context);
    return AppTextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      label: l10n.password,
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.pleaseEnterPassword;
        }
        if (!_isLogin && value.length < 8) {
          return l10n.passwordMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    final l10n = AppLocalizations.of(context);
    return AppTextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      label: l10n.emailOptional,
      prefixIcon: const Icon(Icons.email),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return l10n.pleaseEnterValidEmail;
          }
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    final l10n = AppLocalizations.of(context);
    return ElevatedButton(
      onPressed: () {
        _onAuthClicked(_isLogin);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(
        _isLogin ? l10n.login : l10n.signUp,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    final l10n = AppLocalizations.of(context);
    return TextButton(
      onPressed: _onToggleRegisterClicked,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        _isLogin ? l10n.createAccount : l10n.alreadyHaveAccount,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildRemoteAccCheckbox() {
    final l10n = AppLocalizations.of(context);
    return Row(children: [
        Text(
          l10n.remoteAccount,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        Checkbox(
          value: _isRemoteAccount,
          checkColor: Theme.of(context).colorScheme.onPrimary,
          fillColor: WidgetStateProperty.resolveWith((states) {
            const Set<WidgetState> interactiveStates = <WidgetState>{
              WidgetState.pressed,
              WidgetState.hovered,
              WidgetState.focused,
            };
            if (states.any(interactiveStates.contains)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Theme.of(context).colorScheme.primaryContainer;
          }),
          onChanged: (bool? value) {
            setState(() {
              _isRemoteAccount = value!;
            });
          },
        ),
      ]);
  }

  //? callbacks ----------------------------------------------------------------

  void _onToggleRegisterClicked() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _onAuthClicked(bool login) {
    final l10n = AppLocalizations.of(context);
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    try {
      setState(() {
        _isAuthenticating = true;
      });

      final username = _usernameController.text;
      final password = _passwordController.text;
      final email = _emailController.text;

      if (login) {
        final success =
            ref.read(userDataProvider.notifier).login(username, password);

        if (!success) {
          _showErrorDialog(l10n.invalidUsernameOrPassword);
        }
      } else {
        // Create new user with password (instead of PIN)
        final userData = UserData(
          username: username,
          clearPassword: password, // Use clearPassword property
          email: email,
        );

        ref.read(userDataProvider.notifier).createUser(userData);
      }
    } on AssertionError catch (e) {
      _showErrorDialog('${e.message}');
    } catch (e) {
      _showErrorDialog(l10n.unexpectedError(e.toString()));
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.authenticationError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
