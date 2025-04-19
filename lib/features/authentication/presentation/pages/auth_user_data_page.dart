import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
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
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildUsernameField(),
                          const SizedBox(height: 12),
                          _buildPasswordField(),
                          const SizedBox(height: 12),
                          if (!_isLogin) _buildEmailField(),
                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin) _buildRemoteAccCheckbox(),
                          const SizedBox(height: 12),
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
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
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
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (!_isLogin && value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email (optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
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
        _isLogin ? 'Login' : 'Sign Up',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: _onToggleRegisterClicked,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        _isLogin ? 'Create an account' : 'I already have an account',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildRemoteAccCheckbox() => Row(children: [
        Text(
          'Remote Account?',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        Checkbox(
          value: _isRemoteAccount,
          checkColor: Colors.white,
          fillColor: WidgetStateProperty.resolveWith((states) {
            const Set<WidgetState> interactiveStates = <WidgetState>{
              WidgetState.pressed,
              WidgetState.hovered,
              WidgetState.focused,
            };
            if (states.any(interactiveStates.contains)) {
              return Colors.blue;
            }
            return Colors.red;
          }),
          onChanged: (bool? value) {
            setState(() {
              _isRemoteAccount = value!;
            });
          },
        ),
      ]);

  //? callbacks ----------------------------------------------------------------

  void _onToggleRegisterClicked() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _onAuthClicked(bool login) {
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
          _showErrorDialog('Invalid username or password. Please try again.');
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
      _showErrorDialog('An unexpected error occurred: $e');
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
