import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettingsWidget extends ConsumerStatefulWidget {
  const ThemeSettingsWidget({super.key});

  @override
  ConsumerState<ThemeSettingsWidget> createState() =>
      _ThemeSettingsWidgetState();
}

class _ThemeSettingsWidgetState extends ConsumerState<ThemeSettingsWidget> {
  Color _dialogPickerColor =
      settingsContainer.activeUserSettings.themeSeedColor;
  var _darkModeSwitch = settingsContainer.activeUserSettings.darkThemeMode;

  void _autoSave() => settingsContainer.saveSettings().ignore();

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.themeSettings,
      icon: Icons.palette_outlined,
      children: [
        SettingsTile(
          icon: Icons.palette,
          title: l10n.themeColor,
          subtitle: l10n.clickColorToChange,
          trailing: ColorIndicator(
            width: 32,
            height: 32,
            borderRadius: 8,
            color: _dialogPickerColor,
            onSelectFocus: false,
            onSelect: () async {
              final colorBefore = _dialogPickerColor;
              if (!(await colorPickerDialog())) {
                setState(() => _dialogPickerColor = colorBefore);
              }
            },
          ),
        ),
        SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.themeMode,
          subtitle: l10n.toggleDarkMode,
          trailing: Switch(
            value: _darkModeSwitch,
            onChanged: _onSwitchDarkModeClicked,
          ),
        ),
      ],
    );
  }

  Future<bool> colorPickerDialog() async {
    final l10n = AppLocalizations.of(context);
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
        l10n.selectColor,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        l10n.selectColorShade,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      wheelSubheading: Text(
        l10n.selectedColorAndShades,
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
      actionsPadding: AppSpacing.paddingAllMd,
      constraints:
          const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }

  void _onColorPickerAcceptedClicked(Color color) {
    setState(() => _dialogPickerColor = color);
    ref.read(themeProvider.notifier).updateThemeFromSeedColor(color);
    settingsContainer.activeUserSettings.themeSeedColor = color;
    _autoSave();
  }

  void _onSwitchDarkModeClicked(bool value) {
    setState(() => _darkModeSwitch = value);
    ref.read(themeProvider.notifier).toggleDarkMode(_darkModeSwitch);
    settingsContainer.activeUserSettings.darkThemeMode = value;
    _autoSave();
  }
}
