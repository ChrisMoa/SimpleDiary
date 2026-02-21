// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:day_tracker/features/synchronization/domain/providers/pdf_export_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';

class PdfExportWidget extends ConsumerStatefulWidget {
  const PdfExportWidget({super.key});

  @override
  ConsumerState<PdfExportWidget> createState() => _PdfExportWidgetState();
}

class _PdfExportWidgetState extends ConsumerState<PdfExportWidget> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    final l10n = AppLocalizations.of(context)!;

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
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    color: theme.colorScheme.error,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  AppSpacing.horizontalXs,
                  Expanded(
                    child: Text(
                      l10n.pdfExport,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 18 : 22,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalMd,

              Text(
                l10n.pdfExportDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              AppSpacing.verticalXl,

              // Quick export section
              Text(
                l10n.quickExport,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalSm,

              // Quick export chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickExportChip(
                    context,
                    theme,
                    l10n.lastWeek,
                    DateRange.lastWeek(),
                    Icons.calendar_view_week,
                  ),
                  _buildQuickExportChip(
                    context,
                    theme,
                    l10n.lastMonth,
                    DateRange.lastMonth(),
                    Icons.calendar_month,
                  ),
                  _buildQuickExportChip(
                    context,
                    theme,
                    l10n.currentMonth,
                    DateRange.currentMonth(),
                    Icons.today,
                  ),
                ],
              ),

              AppSpacing.verticalLg,

              // Custom range button
              _buildExportButton(
                context: context,
                theme: theme,
                icon: Icons.date_range,
                label: l10n.customRange,
                description: l10n.selectDateRangeForReport,
                onPressed: _isGenerating ? null : _selectCustomRange,
                isSmallScreen: isSmallScreen,
              ),

              AppSpacing.verticalSm,

              // Select month button
              _buildExportButton(
                context: context,
                theme: theme,
                icon: Icons.calendar_today,
                label: l10n.selectMonth,
                description: l10n.selectSpecificMonth,
                onPressed: _isGenerating ? null : _selectMonth,
                isSmallScreen: isSmallScreen,
              ),

              AppSpacing.verticalSm,

              // Export all button
              _buildExportButton(
                context: context,
                theme: theme,
                icon: Icons.download,
                label: l10n.exportAllData,
                description: l10n.generatePdfWithAllData,
                onPressed: _isGenerating ? null : _exportAll,
                isSmallScreen: isSmallScreen,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickExportChip(
    BuildContext context,
    ThemeData theme,
    String label,
    DateRange range,
    IconData icon,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: _isGenerating ? null : () => _generateAndExport(range),
      backgroundColor: theme.colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSecondaryContainer,
      ),
    );
  }

  Widget _buildExportButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback? onPressed,
    required bool isSmallScreen,
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        color: isPrimary
            ? theme.colorScheme.primaryContainer.withValues(alpha:0.3)
            : theme.colorScheme.surface,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                size: isSmallScreen ? 24 : 28,
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isPrimary
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalXxs,
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isGenerating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectCustomRange() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.read(themeProvider);
    final now = DateTime.now();
    final diaryDays = ref.read(diaryDayLocalDbDataProvider);

    // Find earliest date
    DateTime firstDate = now.subtract(const Duration(days: 365));
    if (diaryDays.isNotEmpty) {
      final dates = diaryDays.map((d) => d.day).toList()..sort();
      firstDate = dates.first;
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      helpText: l10n.selectDateRange,
      saveText: l10n.export,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final range = DateRange(start: picked.start, end: picked.end);
      await _generateAndExport(range);
    }
  }

  Future<void> _selectMonth() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.read(themeProvider);
    final now = DateTime.now();
    final diaryDays = ref.read(diaryDayLocalDbDataProvider);

    // Find earliest date
    DateTime firstDate = now.subtract(const Duration(days: 365));
    if (diaryDays.isNotEmpty) {
      final dates = diaryDays.map((d) => d.day).toList()..sort();
      firstDate = dates.first;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
      helpText: l10n.selectMonth,
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final range = DateRange.forMonth(picked.year, picked.month);
      await _generateAndExport(range);
    }
  }

  Future<void> _exportAll() async {
    final diaryDays = ref.read(diaryDayLocalDbDataProvider);
    final now = DateTime.now();
    // Filter out invalid dates (future dates beyond 1 year, or dates before 2000)
    final validDates = diaryDays
        .map((d) => d.day)
        .where((date) =>
          date.year >= 2000 &&
          date.isBefore(now.add(const Duration(days: 365))))
        .toList();
    final range = DateRange.all(validDates);
    await _generateAndExport(range);
  }

  static const String _kLastUsedDirectoryKey = 'last_used_pdf_export_directory';

  Future<String?> _getLastUsedDirectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kLastUsedDirectoryKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveLastUsedDirectory(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastUsedDirectoryKey, path.dirname(filePath));
    } catch (e) {
      LogWrapper.logger.w('Could not save last used directory: $e');
    }
  }

  Future<void> _generateAndExport(DateRange range) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      LogWrapper.logger.i('Generating PDF report for range: ${range.start} to ${range.end}');

      final pdfData = await ref.read(pdfExportProvider(range).future);
      final fileName = '${range.toFileName()}.pdf';

      LogWrapper.logger.i('PDF generated (${ pdfData.length} bytes), opening save dialog');

      final lastDir = Platform.isAndroid ? null : await _getLastUsedDirectory();

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: AppLocalizations.of(context).pdfExport,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        initialDirectory: lastDir,
        bytes: pdfData,
      );

      if (outputPath != null) {
        if (!Platform.isAndroid) {
          if (!outputPath.endsWith('.pdf')) {
            outputPath = '$outputPath.pdf';
          }
          await File(outputPath).writeAsBytes(pdfData);
          await _saveLastUsedDirectory(outputPath);
        }

        LogWrapper.logger.i('PDF export saved to $outputPath');

        if (mounted) {
          AppSnackBar.success(context, message: AppLocalizations.of(context).pdfExportSuccess);
        }
      } else {
        LogWrapper.logger.i('PDF export cancelled by user');
      }
    } catch (e, stackTrace) {
      LogWrapper.logger.e('Failed to generate PDF', error: e, stackTrace: stackTrace);

      if (mounted) {
        AppSnackBar.error(context, message: AppLocalizations.of(context).pdfExportError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
