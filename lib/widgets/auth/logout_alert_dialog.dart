import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:flutter/material.dart';

class LogoutAlertDialog extends AlertDialog {
  final void Function() onLogoutPressed;
  final void Function() onStayInPressed;

  final BuildContext context;

  LogoutAlertDialog({required this.onLogoutPressed, required this.onStayInPressed, required this.context, super.key})
      : super(
          title: const Text("Logout"),
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          actionsOverflowButtonSpacing: 20,
          actions: [
            ElevatedButton(
                onPressed: () {
                  LogWrapper.logger.t('stay here pressed');
                  onStayInPressed();
                },
                child: const Text("stay here")),
            ElevatedButton(
                onPressed: () {
                  LogWrapper.logger.t('logout pressed');
                  onLogoutPressed();
                },
                child: const Text("logout")),
          ],
          content: const Text("Are you sure that you want to logout?"),
        );
}
