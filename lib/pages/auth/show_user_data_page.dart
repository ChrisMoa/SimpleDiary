// ignore_for_file: use_build_context_synchronously

import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:SimpleDiary/widgets/auth/simple_input_data_widget.dart';
import 'package:SimpleDiary/widgets/auth/yes_no_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowUserDataPage extends ConsumerStatefulWidget {
  const ShowUserDataPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowUserDataPageState();
}

class _ShowUserDataPageState extends ConsumerState<ShowUserDataPage> {
  final _formKey = GlobalKey<FormState>();
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
          obscureText: entry.key == 'pin' || entry.key == 'password', // can maybe be changed with an additional button
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var userData = ref.watch(userDataProvider);
    var userDataMap = userData.toMap();
    simpleInputDataWidgets.forEach((element) {
      element.value = userDataMap.containsKey(element.mapKey) ? userDataMap[element.mapKey] : 'Test';
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
        title: const Text('Account settings'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
            ),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...simpleInputDataWidgets
                            .where(
                              (element) => !element.extendedItem,
                            )
                            .map((e) => e),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSaveButton(),
                            _buildLogoutButton(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //? builds -------------------------------------------------------------------

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        _onSaveClicked();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      child: const Text('Save'),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => YesNoAlertDialog(
              onYesPressed: () async {
                ref.read(userDataProvider.notifier).logout();
                await ref.read(diaryDayLocalDbDataProvider.notifier).clearProvider();
                await ref.read(notesLocalDataProvider.notifier).clearProvider();
                Navigator.of(context).pop();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              onNoPressed: () {
                Navigator.of(context).pop();
              },
              question: 'Do you want to logout?',
              context: context,
            ),
          );
        });
      },
      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      child: const Text('Logout'),
    );
  }

  //? callbacks ----------------------------------------------------------------

  void _onSaveClicked() async {
    setState(() {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => YesNoAlertDialog(
              onYesPressed: () async {
                final isValid = _formKey.currentState!.validate();
                if (!isValid) {
                  return;
                }
                try {
                  _formKey.currentState!.save();

                  //* create userData
                  Map<String, dynamic> userDataMap = {};
                  for (var userDataInput in simpleInputDataWidgets) {
                    userDataMap[userDataInput.mapKey] = userDataInput.value;
                  }
                  final userData = UserData.fromMap(userDataMap);
                  ref.read(userDataProvider.notifier).updateUser(userData);
                  Navigator.of(context).pop();
                } on AssertionError catch (e) {
                  setState(() {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(actions: const [], title: Text('${e.message}')),
                    );
                  });
                } catch (e) {
                  setState(() {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(actions: const [], title: Text('unknown exception : $e')),
                    );
                  });
                }
              },
              onNoPressed: () {
                Navigator.of(context).pop();
              },
              context: context,
              question: 'Do you want to overwrite your userdata?'));
    });
  }
}
