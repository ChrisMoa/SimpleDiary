import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:flutter/material.dart';

class YesNoAlertDialog extends AlertDialog {
  final void Function() onYesPressed;
  final void Function() onNoPressed;
  final String question;

  final BuildContext context;

  YesNoAlertDialog({required this.onYesPressed, required this.onNoPressed, required this.context, required this.question, super.key})
      : super(
          title: Text(question),
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          actionsOverflowButtonSpacing: 20,
          actions: [
            ElevatedButton(
                onPressed: () {
                  LogWrapper.logger.t('yes pressed');
                  onYesPressed();
                },
                child: const Text("yes")),
            ElevatedButton(
                onPressed: () {
                  LogWrapper.logger.t('no pressed');
                  onNoPressed();
                },
                child: const Text("no")),
          ],
          content: const Text(''),
        );
}
