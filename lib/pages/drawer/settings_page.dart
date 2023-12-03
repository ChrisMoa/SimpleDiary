import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _readSharedPreferences() async {
    // const storage = FlutterSecureStorage();
    // there arent currently any changeable settings
  }

  @override
  Widget build(BuildContext context) {
    _readSharedPreferences();
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: const Center(
        child: Text("settings screen"),
      ),
    );
  }
}
