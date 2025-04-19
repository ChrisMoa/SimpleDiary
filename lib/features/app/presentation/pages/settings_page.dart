import 'package:day_tracker/features/app/presentation/widgets/theme_settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  //* builds -----------------------------------------------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Column(
        children: [
          ThemeSettingsWidget(),
        ],
      ),
    );
  }

  //* build helper -----------------------------------------------------------------------------------------------------------------------------------
}
