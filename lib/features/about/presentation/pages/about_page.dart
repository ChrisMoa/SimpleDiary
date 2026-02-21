import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surface,
      body: ListView(
        padding: AppSpacing.paddingAllMd,
        children: [
          AppCard.outlined(
            color: colorScheme.secondaryContainer,
            borderColor: colorScheme.outline.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderRadiusMd,
            padding: AppSpacing.paddingAllMd,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: AppSpacing.paddingAllSm,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/app_logo.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  AppSpacing.verticalMd,
                  Center(
                    child: Text(
                      l10n.dayTracker,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      l10n.version(_version),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  AppSpacing.verticalXl,
                  _buildInfoRow(context, l10n.developer, 'Your Name'),
                  _buildInfoRow(context, l10n.contact, 'your.email@example.com'),
                  Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
                  AppSpacing.verticalXs,
                  Text(
                    l10n.description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    l10n.appDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  AppSpacing.verticalMd,
                  Text(
                    l10n.features,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  _buildFeatureItem(
                    context,
                    l10n.featureTrackActivities,
                  ),
                  _buildFeatureItem(
                    context,
                    l10n.featureRateDay,
                  ),
                  _buildFeatureItem(
                    context,
                    l10n.featureCalendar,
                  ),
                  _buildFeatureItem(context, l10n.featureEncryption),
                  _buildFeatureItem(
                    context,
                    l10n.featureSync,
                  ),
                  _buildFeatureItem(context, l10n.featureExportImport),
                  AppSpacing.verticalMd,
                  Text(
                    l10n.licenses,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  TextButton(
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationName: l10n.dayTracker,
                        applicationVersion: _version,
                        applicationIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/app_logo.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                    child: Text(
                      l10n.viewLicenses,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
          ),
          Padding(
            padding: AppSpacing.paddingVerticalMd,
            child: Center(
              child: Text(
                l10n.copyright(DateTime.now().year),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: colorScheme.primary,
          ),
          AppSpacing.horizontalXs,
          Expanded(
            child: Text(
              feature,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
