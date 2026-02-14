import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

class LogoutAlertDialog extends AlertDialog {
  final void Function() onLogoutPressed;
  final void Function() onStayInPressed;

  final BuildContext context;

  LogoutAlertDialog(
      {required this.onLogoutPressed,
      required this.onStayInPressed,
      required this.context,
      super.key})
      : super(
          title: Text(AppLocalizations.of(context).logout),
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
          actionsOverflowButtonSpacing: 20,
          actions: [
            ElevatedButton(
                onPressed: () {
                  LogWrapper.logger.t('stay here pressed');
                  onStayInPressed();
                },
                child: Text(AppLocalizations.of(context).stayHere)),
            ElevatedButton(
                onPressed: () {
                  LogWrapper.logger.t('logout pressed');
                  onLogoutPressed();
                },
                child: Text(AppLocalizations.of(context).logout)),
          ],
          content: Text(AppLocalizations.of(context).logoutMessage),
        );
}
