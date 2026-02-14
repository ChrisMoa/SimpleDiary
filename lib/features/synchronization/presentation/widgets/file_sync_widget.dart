// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:day_tracker/features/synchronization/domain/providers/file_db_provider.dart';
import 'package:day_tracker/features/synchronization/domain/providers/ics_file_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class FileSyncWidget extends ConsumerWidget {
  const FileSyncWidget({super.key});

  // SharedPreferences keys
  static const String _kLastUsedDirectoryKey = 'last_used_export_directory';

  /// Save the last used directory to preferences
  Future<void> _saveLastUsedDirectory(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final directory = path.dirname(filePath);
      await prefs.setString(_kLastUsedDirectoryKey, directory);
      LogWrapper.logger.d('Saved last used directory: $directory');
    } catch (e) {
      LogWrapper.logger.w('Could not save last used directory: $e');
    }
  }

  /// Get the last used directory from preferences
  Future<String?> _getLastUsedDirectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final directory = prefs.getString(_kLastUsedDirectoryKey);
      LogWrapper.logger.d('Retrieved last used directory: $directory');
      return directory;
    } catch (e) {
      LogWrapper.logger.w('Could not retrieve last used directory: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    Icons.folder,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    l10n.fileSynchronization,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Text(
                l10n.fileSyncDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),

              SizedBox(height: 24),

              // Export Button
              _buildSyncButton(
                context: context,
                ref: ref,
                icon: Icons.upload_file,
                label: l10n.exportToJson,
                description: l10n.saveYourDiaryData,
                onPressed: () => _onExportToFile(context, ref),
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: 16),

              // Import Button
              _buildSyncButton(
                context: context,
                ref: ref,
                icon: Icons.download_for_offline,
                label: l10n.importFromJson,
                description: l10n.loadDiaryData,
                onPressed: () => _onImportFromFile(context, ref),
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: 16),

              // Export to ICS Button
              _buildSyncButton(
                context: context,
                ref: ref,
                icon: Icons.calendar_today,
                label: l10n.exportToIcsCalendar,
                description: l10n.saveNotesAsCalendarEvents,
                onPressed: () => _onExportToIcs(context, ref),
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: 16),

              // Import from ICS Button
              _buildSyncButton(
                context: context,
                ref: ref,
                icon: Icons.calendar_month,
                label: l10n.importFromIcsCalendar,
                description: l10n.loadCalendarEvents,
                onPressed: () => _onImportFromIcs(context, ref),
                theme: theme,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onPressed,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: isSmallScreen ? 16 : 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onExportToFile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      LogWrapper.logger.i('JSON export started');

      // Prompt for date range
      final dateRange = await _promptForDateRange(context);
      if (dateRange == null) {
        LogWrapper.logger.i('JSON export cancelled by user (date range)');
        return;
      }

      // Prompt for encryption password
      final userData = ref.read(userDataProvider);
      final defaultPassword = userData.clearPassword;

      final password = await _promptForPassword(
        context,
        l10n.encryptJsonExport,
        defaultValue: defaultPassword,
      );

      final defaultFileName = 'data_export_${Utils.toFileDateTime(DateTime.now())}.json';
      final bool willEncrypt = password != null && password.isNotEmpty;
      final rangeEnd = dateRange.end.add(const Duration(days: 1));

      // Get diary days with their matched notes
      var diaryDays = ref.read(diaryDayFullDataProvider).where((day) {
        return !day.day.isBefore(dateRange.start) && day.day.isBefore(rangeEnd);
      }).toList();

      // Find notes that have no matching diary day (orphan notes)
      final allNotes = ref.read(notesLocalDataProvider).where((note) {
        return !note.from.isBefore(dateRange.start) && note.from.isBefore(rangeEnd);
      }).toList();
      final exportedNoteIds = diaryDays.expand((d) => d.notes).map((n) => n.id).toSet();
      final orphanNotes = allNotes.where((n) => !exportedNoteIds.contains(n.id)).toList();

      // Group orphan notes by date and create temporary diary days for them
      if (orphanNotes.isNotEmpty) {
        final Map<String, List<Note>> orphanByDate = {};
        for (var note in orphanNotes) {
          final dateKey = '${note.from.year}-${note.from.month}-${note.from.day}';
          orphanByDate.putIfAbsent(dateKey, () => []).add(note);
        }
        for (var entry in orphanByDate.entries) {
          final firstNote = entry.value.first;
          final dd = DiaryDay(
            day: DateTime(firstNote.from.year, firstNote.from.month, firstNote.from.day),
            ratings: [],
          );
          dd.notes = entry.value;
          diaryDays.add(dd);
        }
        LogWrapper.logger.i('Added ${orphanNotes.length} orphan notes in ${orphanByDate.length} extra days');
      }

      LogWrapper.logger.i('Exporting ${diaryDays.length} diary days with ${allNotes.length} total notes');

      // Generate export content before showing file picker
      final content = ref.read(fileDbStateProvider.notifier).exportToString(
            diaryDays: diaryDays,
            username: userData.username.isNotEmpty ? userData.username : null,
            salt: willEncrypt ? userData.salt : null,
            encrypted: willEncrypt,
            password: willEncrypt ? password : null,
          );
      final contentBytes = Uint8List.fromList(utf8.encode(content));

      // Get last used directory (not supported on Android)
      final lastDir = Platform.isAndroid ? null : await _getLastUsedDirectory();

      // On Android/iOS, bytes must be passed to saveFile directly
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: l10n.saveJsonExportFile,
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: lastDir,
        bytes: contentBytes,
      );

      if (outputPath != null) {
        LogWrapper.logger.d('Export path selected: $outputPath');

        if (!Platform.isAndroid) {
          // On desktop, file picker only returns a path — we need to write manually
          if (!outputPath.endsWith('.json')) {
            outputPath = '$outputPath.json';
          }
          await File(outputPath).writeAsString(content);
          await _saveLastUsedDirectory(outputPath);
        }

        LogWrapper.logger.i('JSON export finished successfully to $outputPath');
        _onImportExportSuccessfully(context);
      } else {
        LogWrapper.logger.i('JSON export cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during JSON exporting: ${e.toString()}');
      _onError(context, 'Error during JSON export: $e');
    }
  }

  Future<void> _onImportFromFile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      LogWrapper.logger.i('JSON import started');

      // Get last used directory
      final lastDir = await _getLastUsedDirectory();

      // Use native file picker to select JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: l10n.selectJsonFileToImport,
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        initialDirectory: lastDir,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        // Save this directory for next time
        await _saveLastUsedDirectory(path);

        try {
          File file = File(path);
          LogWrapper.logger.i('Import from file ${file.path}');

          // Read file to check metadata (metadata is always readable)
          String fileContent;
          try {
            fileContent = file.readAsStringSync();
          } catch (e) {
            // File is not UTF-8 readable - this is the OLD format (completely encrypted)
            LogWrapper.logger.e('File is not readable as UTF-8 - this is a legacy encrypted format');
            _onError(context, l10n.oldEncryptionFormatError);
            return;
          }

          bool isEncrypted = false;

          // Check if file has metadata
          if (ExportData.isNewFormat(fileContent)) {
            final Map<String, dynamic> map = json.decode(fileContent);
            final metadataMap = map['metadata'] as Map<String, dynamic>;
            isEncrypted = metadataMap['encrypted'] as bool;
            LogWrapper.logger.i('Detected new format: encrypted=$isEncrypted');
          } else {
            LogWrapper.logger.i('Detected legacy format (unencrypted)');
          }

          // Prompt for password if encrypted
          final userData = ref.read(userDataProvider);
          final defaultPassword = userData.clearPassword;
          String? password;

          if (isEncrypted) {
            password = await _promptForPassword(
              context,
              l10n.decryptJsonImport,
              defaultValue: defaultPassword,
            );

            if (password == null || password.isEmpty) {
              _onError(context, l10n.passwordRequiredForEncryptedFile);
              return;
            }
          }

          // Import the data (decryption happens internally)
          try {
            await ref.read(fileDbStateProvider.notifier).import(
              File(path),
              password: password,
            );

            final importedDays = ref.read(fileDbStateProvider);
            int noteCount = 0;
            LogWrapper.logger.i('DEBUG: Parsed ${importedDays.length} diary days from file');

            // Add diary entries to local DB (upsert to restore deleted/modified entries)
            for (var diaryDay in importedDays) {
              LogWrapper.logger.d('DEBUG: Processing diary day ${diaryDay.day} with ${diaryDay.notes.length} notes');
              await ref
                  .read(diaryDayLocalDbDataProvider.notifier)
                  .addOrUpdateElement(diaryDay);
              for (var note in diaryDay.notes) {
                LogWrapper.logger.d('DEBUG: Importing note "${note.title}" (id=${note.id})');
                await ref.read(notesLocalDataProvider.notifier).addOrUpdateElement(note);
                noteCount++;
              }
            }

            // Force reload state from DB to ensure UI is in sync
            await ref.read(notesLocalDataProvider.notifier).reloadFromDatabase();
            await ref.read(diaryDayLocalDbDataProvider.notifier).reloadFromDatabase();

            final notesInState = ref.read(notesLocalDataProvider).length;
            LogWrapper.logger.i('JSON import finished: $noteCount notes imported, $notesInState total notes in state');

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Text(l10n.importedDaysWithNotes(importedDays.length, noteCount)),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } catch (e) {
            LogWrapper.logger.e('Error during JSON import: $e');
            _onError(context, l10n.errorPrefix('$e'));
          }
        } catch (e) {
          LogWrapper.logger.e('Error importing from file "$path": "$e"');
          _onError(context, l10n.errorPrefix('$e'));
        }
      } else {
        LogWrapper.logger.i('JSON import cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during JSON importing: ${e.toString()}');
      _onError(context, l10n.errorPrefix('$e'));
    }
  }

  void _onImportExportSuccessfully(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(l10n.operationCompletedSuccessfully),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: l10n.ok,
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      ),
    );
  }

  Future<void> _onExportToIcs(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      LogWrapper.logger.i('ICS export started');

      // Prompt for date range
      final dateRange = await _promptForDateRange(context);
      if (dateRange == null) {
        LogWrapper.logger.i('ICS export cancelled by user (date range)');
        return;
      }

      // Prompt for encryption password
      final userData = ref.read(userDataProvider);
      final defaultPassword = userData.clearPassword;

      final password = await _promptForPassword(
        context,
        l10n.encryptIcsExport,
        defaultValue: defaultPassword,
      );

      final defaultFileName = 'diary_export_${Utils.toFileDateTime(DateTime.now())}.ics';
      final bool willEncrypt = password != null && password.isNotEmpty;

      // Filter notes by date range (using the note's 'from' field)
      final rangeEnd = dateRange.end.add(const Duration(days: 1));
      final notes = ref.read(notesLocalDataProvider).where((note) {
        return !note.from.isBefore(dateRange.start) &&
            note.from.isBefore(rangeEnd);
      }).toList();

      LogWrapper.logger.i('Exporting ${notes.length} notes in range');

      // Generate export content before showing file picker
      final content = ref.read(icsFileStateProvider.notifier).exportToString(
            notes: notes,
            username: userData.username.isNotEmpty ? userData.username : null,
            salt: willEncrypt ? userData.salt : null,
            encrypted: willEncrypt,
            password: willEncrypt ? password : null,
          );
      final contentBytes = Uint8List.fromList(utf8.encode(content));

      // Get last used directory (not supported on Android)
      final lastDir = Platform.isAndroid ? null : await _getLastUsedDirectory();

      // On Android/iOS, bytes must be passed to saveFile directly
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: l10n.saveIcsCalendarFile,
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['ics'],
        initialDirectory: lastDir,
        bytes: contentBytes,
      );

      if (outputPath != null) {
        LogWrapper.logger.d('Export path selected: $outputPath');

        if (!Platform.isAndroid) {
          // On desktop, file picker only returns a path — we need to write manually
          if (!outputPath.endsWith('.ics')) {
            outputPath = '$outputPath.ics';
          }
          await File(outputPath).writeAsString(content);
          await _saveLastUsedDirectory(outputPath);
        }

        LogWrapper.logger.i('ICS export finished successfully to $outputPath');
        _onImportExportSuccessfully(context);
      } else {
        LogWrapper.logger.i('ICS export cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during ICS exporting: ${e.toString()}');
      _onError(context, l10n.errorPrefix('$e'));
    }
  }

  Future<void> _onImportFromIcs(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      LogWrapper.logger.i('ICS import started');

      // Get last used directory
      final lastDir = await _getLastUsedDirectory();

      // Use native file picker to select ICS file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: l10n.selectIcsFileToImport,
        type: FileType.custom,
        allowedExtensions: ['ics', 'ical'],
        allowMultiple: false,
        initialDirectory: lastDir,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        // Save this directory for next time
        await _saveLastUsedDirectory(path);

        try {
          File file = File(path);
          LogWrapper.logger.i('Import ICS from file ${file.path}');

          // Read file to check if it's encrypted (wrapped format)
          String fileContent;
          try {
            fileContent = file.readAsStringSync();
          } catch (e) {
            LogWrapper.logger.e('File is not readable: $e');
            _onError(context, l10n.cannotReadIcsFile);
            return;
          }

          bool isEncrypted = false;

          // Check if file has metadata wrapper
          try {
            final decoded = json.decode(fileContent);
            if (decoded is Map<String, dynamic> &&
                decoded.containsKey('format') &&
                decoded['format'] == 'ics') {
              final metadataMap = decoded['metadata'] as Map<String, dynamic>;
              isEncrypted = metadataMap['encrypted'] as bool;
              LogWrapper.logger.i('Detected wrapped ICS format: encrypted=$isEncrypted');
            }
          } catch (e) {
            // Not JSON wrapped format, it's a plain ICS file
            LogWrapper.logger.i('Detected plain ICS format');
          }

          // Prompt for password if encrypted
          final userData = ref.read(userDataProvider);
          final defaultPassword = userData.clearPassword;
          String? password;

          if (isEncrypted) {
            password = await _promptForPassword(
              context,
              l10n.decryptIcsImport,
              defaultValue: defaultPassword,
            );

            if (password == null || password.isEmpty) {
              _onError(context, l10n.passwordRequiredForEncryptedIcsFile);
              return;
            }
          }

          // Import the ICS data
          try {
            final categories = ref.read(categoryLocalDataProvider);
            await ref.read(icsFileStateProvider.notifier).importFromIcs(
              File(path),
              categories,
              password: password,
            );

            final importedNotes = ref.read(icsFileStateProvider);
            LogWrapper.logger.i('DEBUG: Parsed ${importedNotes.length} notes from ICS file');

            for (var note in importedNotes) {
              LogWrapper.logger.d('DEBUG: Importing note "${note.title}" (id=${note.id})');
              await ref.read(notesLocalDataProvider.notifier).addOrUpdateElement(note);
            }

            // Force reload state from DB to ensure UI is in sync
            await ref.read(notesLocalDataProvider.notifier).reloadFromDatabase();

            final notesInState = ref.read(notesLocalDataProvider).length;
            LogWrapper.logger.i('ICS import finished: ${importedNotes.length} notes imported, $notesInState total notes in state');

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Text(l10n.importedNotesFromIcs(importedNotes.length)),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } catch (e) {
            LogWrapper.logger.e('Error during ICS import: $e');
            _onError(context, l10n.errorPrefix('$e'));
          }
        } catch (e) {
          LogWrapper.logger.e('Error importing ICS from file "$path": "$e"');
          _onError(context, l10n.errorPrefix('$e'));
        }
      } else {
        LogWrapper.logger.i('ICS import cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during ICS importing: ${e.toString()}');
      _onError(context, l10n.errorPrefix('$e'));
    }
  }

  void _onError(BuildContext context, String errorMsg) {
    final l10n = AppLocalizations.of(context)!;
    if (errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text(errorMsg),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: l10n.ok,
            textColor: Theme.of(context).colorScheme.onError,
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        ),
      );
    }
  }

  /// Prompt the user to select a date range or export all.
  /// Returns null if the user cancels, or a DateTimeRange if they select a range.
  /// Returns a range from year 2000 to tomorrow if "All" is selected (sentinel value).
  Future<DateTimeRange?> _promptForDateRange(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final allRange = DateTimeRange(
      start: DateTime(2000),
      end: DateTime.now().add(const Duration(days: 1)),
    );

    final choice = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exportRange),
        content: Text(l10n.whichEntriesToExport),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.customRange),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.all),
          ),
        ],
      ),
    );

    if (choice == null) return null; // cancelled
    if (choice) return allRange; // all entries

    // Show date range picker
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
    );

    return picked;
  }

  Future<String?> _promptForPassword(BuildContext context, String title,
      {String? defaultValue}) async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController(
      text: defaultValue ?? '',
    );
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.passwordOptional,
            hintText: l10n.leaveEmptyForNoEncryption,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    return password != null && password.isNotEmpty ? password : null;
  }

}
