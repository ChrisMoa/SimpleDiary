import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:SimpleDiary/widgets/auth/simple_input_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileWidget extends ConsumerStatefulWidget {
  UserProfileWidget({
    required this.addButtons,
    required this.enableReturn,
    required this.enableEditing,
    super.key,
    bool? enableRemoteAccount,
  }) : enableRemoteAccount = enableRemoteAccount ?? true;

  final List<Widget> addButtons;
  final bool enableReturn;
  final bool enableEditing;
  final bool enableRemoteAccount;
  final formKey = GlobalKey<FormState>();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  var _userData = UserData.fromEmpty();
  bool _isRemoteAccount = false;

  List<SimpleInputDataWidget> simpleInputDataWidgets = [];

  @override
  initState() {
    super.initState();
    var userDataMap = _userData.toMap();
    for (var entry in userDataMap.entries) {
      simpleInputDataWidgets.add(SimpleInputDataWidget(
          mapKey: entry.key,
          value: entry.value,
          extendedItem: !(entry.key == 'username' || entry.key == 'pin')));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userData = ref.watch(userDataProvider);
    // _isRemoteAccount = _userData.isRemoteUser;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Simple Diary'),
        leading: widget.enableReturn
            ? const CloseButton()
            : TextButton(onPressed: () {}, child: const Text('')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoginPicture(context),
              _buildCredentials(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPicture(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 30,
        bottom: 30,
        left: 20,
        right: 20,
      ),
      width: 200,
      child: Image.asset('assets/images/chat.png'),
    );
  }

  Widget _buildCredentials(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: widget.formKey,
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
                if (widget.enableRemoteAccount) _buildRemoteAccCheckbox(),
                _buildButtons(context),
              ],
            ),
          ),
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

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        ...widget.addButtons,
      ],
    );
  }
}
