import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/authentication/presentation/widgets/simple_input_data_widget.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/core/log/logger_instance.dart';

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
  ConsumerState<ConsumerStatefulWidget> createState() => _UserProfileWidgetState();
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
      simpleInputDataWidgets.add(SimpleInputDataWidget(mapKey: entry.key, value: entry.value, extendedItem: false));
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
        leading: widget.enableReturn ? const CloseButton() : TextButton(onPressed: () {}, child: const Text('')),
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
    return AppCard.elevated(
      margin: AppSpacing.paddingAllLg,
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.paddingAllMd,
          child: Form(
            key: widget.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...simpleInputDataWidgets.map((e) => e),
                if (widget.enableRemoteAccount) _buildRemoteAccCheckbox(),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteAccCheckbox() {
    LogWrapper.logger.d('Building remote account checkbox');
    return CheckboxListTile(
      title: const Text('Remote Account'),
      value: _isRemoteAccount,
      onChanged: (bool? value) {
        LogWrapper.logger.d('Remote account checkbox changed: $value');
        setState(() {
          _isRemoteAccount = value ?? false;
        });
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    LogWrapper.logger.d('Building user profile buttons');
    return Column(
      children: [
        ...widget.addButtons,
        if (widget.enableEditing)
          ElevatedButton(
            onPressed: () {
              LogWrapper.logger.d('Edit button clicked');
              if (widget.formKey.currentState!.validate()) {
                widget.formKey.currentState!.save();
                LogWrapper.logger.d('Form validated and saved');
                // Update user data
                Map<String, dynamic> userDataMap = {};
                for (var userDataInput in simpleInputDataWidgets) {
                  userDataMap[userDataInput.mapKey] = userDataInput.value;
                }
                final userData = UserData.fromMap(userDataMap);
                LogWrapper.logger.d('Updating user data');
                ref.read(userDataProvider.notifier).updateUser(userData);
              } else {
                LogWrapper.logger.w('Form validation failed');
              }
            },
            child: const Text('Edit'),
          ),
      ],
    );
  }
}
