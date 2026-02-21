import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PinAuthenticationPage extends ConsumerStatefulWidget {
  const PinAuthenticationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PinAuthenticationPageState();
}

class _PinAuthenticationPageState extends ConsumerState<PinAuthenticationPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _pinController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _pinController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userData = ref.read(userDataProvider);
      if (userData.isLoggedIn) {
        _usernameController.text = userData.username;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Pin',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppTextField(
                controller: _pinController,
                label: 'Pin',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pin';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final userData = ref.read(userDataProvider);
                  if (userData.username.isNotEmpty) {
                    ref
                        .read(userDataProvider.notifier)
                        .login(userData.username, _pinController.text);
                    // Pin is correct, proceed to next page or action
                  } else {
                    // Incorrect pin, show error
                    AppSnackBar.error(context, message: 'Incorrect pin');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Submit',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary)),
            ),
            TextButton(
              onPressed: () {
                ref.read(userDataProvider.notifier).logout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: Text('Switch User',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
