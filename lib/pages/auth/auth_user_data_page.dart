import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:SimpleDiary/widgets/auth/simple_input_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthUserDataPage extends ConsumerStatefulWidget {
  const AuthUserDataPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LoginUserDataPageState();
}

class _LoginUserDataPageState extends ConsumerState<AuthUserDataPage> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isAuthenticating = false;
  var _isRemoteAccount = false;
  List<SimpleInputDataWidget> simpleInputDataWidgets = [];

  //? build --------------------------------------------------------------------

  @override
  initState() {
    super.initState();
    for (var entry in UserData.fromEmpty().toMap().entries) {
      simpleInputDataWidgets.add(
        SimpleInputDataWidget(
            mapKey: entry.key,
            value: entry.value,
            shouldNotBeEmpty: entry.key == 'username',
            extendedItem: !(entry.key == 'username' || entry.key == 'pin'),
            obscureText: entry.key == 'pin' || entry.key == 'password'),
      );
    }
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
                          ...simpleInputDataWidgets
                              .where(
                                (element) => !element.extendedItem,
                              )
                              .map((e) => e),
                          if (_isRemoteAccount)
                            ...simpleInputDataWidgets
                                .where(
                                  (element) => element.extendedItem,
                                )
                                .map((e) => e),
                          if (!_isLogin) _buildRemoteAccCheckbox(),
                          const SizedBox(
                            height: 12,
                          ),
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        _onAuthClicked(_isLogin);
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      child: Text(_isLogin ? 'Login' : 'Signup'),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: _onToggleRegisterClicked,
      child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
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
          fillColor: MaterialStateProperty.resolveWith((states) {
            const Set<MaterialState> interactiveStates = <MaterialState>{
              MaterialState.pressed,
              MaterialState.hovered,
              MaterialState.focused,
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

  void _onAuthClicked(bool login) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    try {
      _formKey.currentState!.save();
      setState(() {
        _isAuthenticating = true;
      });

      //* create userData
      Map<String, dynamic> userDataMap = {};
      for (var userDataInput in simpleInputDataWidgets) {
        userDataMap[userDataInput.mapKey] = userDataInput.value;
      }
      final userData = UserData.fromMap(userDataMap);
      if (login) {
        await ref
            .read(userDataProvider.notifier)
            .login(userData.username, userData.pin);
      } else {
        await ref.read(userDataProvider.notifier).createUser(userData);
      }
    } on AssertionError catch (e) {
      setState(() {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(actions: const [], title: Text('${e.message}')),
        );
      });
    } catch (e) {
      setState(() {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              actions: const [], title: Text('unknown exception : $e')),
        );
      });
    }
    setState(() {
      _isAuthenticating = false;
    });
  }
}
