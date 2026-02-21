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
  ConsumerState<ThemeSettingsWidget> createState() => _ThemeSettingsWidgetState();
}

class _ThemeSettingsWidgetState extends ConsumerState<ThemeSettingsWidget> {
  Color _dialogPickerColor = settingsContainer.activeUserSettings.themeSeedColor;
  var _darkModeSwitch = settingsContainer.activeUserSettings.darkThemeMode;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return AppCard.elevated(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.palette,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  AppSpacing.horizontalXs,
                  Text(
                    l10n.themeSettings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalMd,

              Text(
                l10n.customizeAppearance,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              AppSpacing.verticalXl,

              // Theme Color
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: .2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.themeColor,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      l10n.clickColorToChange,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: .7),
                      ),
                    ),
                    AppSpacing.verticalMd,
                    ColorIndicator(
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
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              // Theme Mode
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: .2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.themeMode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      l10n.toggleDarkMode,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: .7),
                      ),
                    ),
                    AppSpacing.verticalMd,
                    Switch(
                      value: _darkModeSwitch,
                      onChanged: _onSwitchDarkModeClicked,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      constraints: const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }

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
