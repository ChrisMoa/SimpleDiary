// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:day_tracker/features/synchronization/domain/providers/pdf_export_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/log/logger_instance.dart';

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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
          borderRadius: BorderRadius.circular(16),
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
                  const SizedBox(width: 8),
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

              const SizedBox(height: 16),

              Text(
                l10n.pdfExportDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 24),

              // Quick export section
              Text(
                l10n.quickExport,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

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

              const SizedBox(height: 20),

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

              const SizedBox(height: 12),

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        color: isPrimary
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surface,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
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

  Future<void> _exportAll() async {
    final diaryDays = ref.read(diaryDayLocalDbDataProvider);
    final dates = diaryDays.map((d) => d.day).toList();
    final range = DateRange.all(dates);
    await _generateAndExport(range);
  }

  Future<void> _generateAndExport(DateRange range) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      LogWrapper.logger.i('Generating PDF report for range: ${range.start} to ${range.end}');

      final pdfData = await ref.read(pdfExportProvider(range).future);

      LogWrapper.logger.i('PDF generated successfully, showing print dialog');

      // Show print/share dialog
      await Printing.layoutPdf(
        onLayout: (_) => pdfData,
        name: _generateFileName(range),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pdfExportSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e, stackTrace) {
      LogWrapper.logger.e('Failed to generate PDF', error: e, stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pdfExportError(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  String _generateFileName(DateRange range) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return 'diary_report_${dateFormat.format(range.start)}_to_${dateFormat.format(range.end)}.pdf';
  }
}
