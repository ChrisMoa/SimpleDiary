import 'package:SimpleDiary/model/Settings/settings_container.dart';
import 'package:SimpleDiary/provider/theme_provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettingsWidget extends ConsumerStatefulWidget {
  const ThemeSettingsWidget({super.key});

  @override
  ConsumerState<ThemeSettingsWidget> createState() => _ThemeSettingsWidgetState();
}

class _ThemeSettingsWidgetState extends ConsumerState<ThemeSettingsWidget> {
  Color _dialogPickerColor = settingsContainer.activeUserSettings.themeSeedColor;
  var _darkModeSwitch = settingsContainer.activeUserSettings.darkThemeMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: Text(
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
              'Theme Color',
            ),
            title: Text(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
              'Click this color to change it in a dialog',
            ),
            trailing: ColorIndicator(
              width: 44,
              height: 44,
              borderRadius: 4,
              color: _dialogPickerColor,
              onSelectFocus: false,
              onSelect: () async {
                final Color colorBeforeDialog = _dialogPickerColor;
                if (!(await colorPickerDialog())) {
                  setState(() {
                    _dialogPickerColor = colorBeforeDialog;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: Text(
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
              'Theme Mode',
            ),
            title: Text(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
              'Toggle this button to switch between dark and light theme',
            ),
            trailing: Switch(
              value: _darkModeSwitch,
              onChanged: _onSwitchDarkModeClicked,
            ),
          ),
        )
      ],
    );
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      color: _dialogPickerColor,
      onColorChanged: _onColorPickerAcceptedClicked,
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
      colorCodePrefixStyle: Theme.of(context).textTheme.bodySmall,
      selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      actionsPadding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }

  //* callbacks --------------------------------------------------------------------------------------------------------------------------------------

  void _onColorPickerAcceptedClicked(Color color) {
    setState(() {
      _dialogPickerColor = color;
    });
    ref.read(themeProvider.notifier).updateThemeFromSeedColor(color);
    settingsContainer.activeUserSettings.themeSeedColor = color;
  }

  void _onSwitchDarkModeClicked(bool value) {
    setState(() {
      _darkModeSwitch = value;
    });
    ref.read(themeProvider.notifier).toggleDarkMode(_darkModeSwitch);
    settingsContainer.activeUserSettings.darkThemeMode = value;
  }
}
