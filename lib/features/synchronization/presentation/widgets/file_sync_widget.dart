// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:day_tracker/features/synchronization/domain/providers/file_db_provider.dart';
import 'package:day_tracker/features/synchronization/domain/providers/ics_file_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
                    'File Synchronization',
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
                'Import and export your diary data to JSON or ICS calendar files with optional encryption.',
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
                label: 'Export to JSON',
                description: 'Save your diary data to a file',
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
                label: 'Import from JSON',
                description: 'Load diary data from a file',
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
                label: 'Export to ICS Calendar',
                description: 'Save notes as calendar events (.ics)',
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
                label: 'Import from ICS Calendar',
                description: 'Load calendar events from .ics file',
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
    try {
      LogWrapper.logger.i('JSON export started');

      // Prompt for encryption password first
      final userData = ref.read(userDataProvider);
      final defaultPassword = userData.clearPassword;

      final password = await _promptForPassword(
        context,
        'Encrypt JSON Export (Optional)',
        defaultValue: defaultPassword,
      );

      // Use native file picker to save file
      final defaultFileName = 'data_export_${Utils.toFileDateTime(DateTime.now())}.json';

      // Get last used directory
      final lastDir = await _getLastUsedDirectory();

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save JSON Export File',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: lastDir,
      );

      if (outputPath != null) {
        try {
          // Ensure .json extension
          if (!outputPath.endsWith('.json')) {
            outputPath = '$outputPath.json';
          }

          // Save this directory for next time
          await _saveLastUsedDirectory(outputPath);

          File file = File(outputPath);
          final bool willEncrypt = password != null && password.isNotEmpty;

          // Use new export format with metadata
          await ref.read(fileDbStateProvider.notifier).exportWithMetadata(
                diaryDays: ref.read(diaryDayFullDataProvider),
                file: file,
                username: userData.username.isNotEmpty ? userData.username : null,
                salt: willEncrypt ? userData.salt : null,
                encrypted: willEncrypt,
                password: willEncrypt ? password : null,
              );

          LogWrapper.logger.i('JSON export finished successfully to $outputPath');
          _onImportExportSuccessfully(context);
        } catch (e) {
          LogWrapper.logger.e('Error exporting JSON "$outputPath": "$e"');
          _onError(context, 'Error during JSON export: $e');
        }
      } else {
        LogWrapper.logger.i('JSON export cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during JSON exporting: ${e.toString()}');
      _onError(context, 'Error during JSON exporting');
    }
  }

  Future<void> _onImportFromFile(BuildContext context, WidgetRef ref) async {
    try {
      LogWrapper.logger.i('JSON import started');

      // Get last used directory
      final lastDir = await _getLastUsedDirectory();

      // Use native file picker to select JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select JSON File to Import',
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
            _onError(context,
              'This file uses the old encryption format and cannot be imported.\n'
              'Please export your data again with the new version.');
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
              'Decrypt JSON Import',
              defaultValue: defaultPassword,
            );

            if (password == null || password.isEmpty) {
              _onError(context, 'Password required for encrypted file');
              return;
            }
          }

          // Import the data (decryption happens internally)
          try {
            await ref.read(fileDbStateProvider.notifier).import(
              File(path),
              password: password,
            );

            // Add diary entries to local DB
            for (var diaryDay in ref.read(fileDbStateProvider)) {
              await ref
                  .read(diaryDayLocalDbDataProvider.notifier)
                  .addElement(diaryDay);
              for (var note in diaryDay.notes) {
                await ref.read(notesLocalDataProvider.notifier).addElement(note);
              }
            }

            LogWrapper.logger.i('JSON import finished successfully');
            _onImportExportSuccessfully(context);
          } catch (e) {
            LogWrapper.logger.e('Error during JSON import: $e');
            _onError(context, 'Error during JSON import. Wrong password or corrupted file?');
          }
        } catch (e) {
          LogWrapper.logger.e('Error importing from file "$path": "$e"');
          _onError(context, 'Error during JSON import: $e');
        }
      } else {
        LogWrapper.logger.i('JSON import cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during JSON importing: ${e.toString()}');
      _onError(context, 'Error during JSON importing');
    }
  }

  void _onImportExportSuccessfully(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Operation completed successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'OK',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      ),
    );
  }

  Future<void> _onExportToIcs(BuildContext context, WidgetRef ref) async {
    try {
      LogWrapper.logger.i('ICS export started');

      // Prompt for encryption password first
      final userData = ref.read(userDataProvider);
      final defaultPassword = userData.clearPassword;

      final password = await _promptForPassword(
        context,
        'Encrypt ICS Export (Optional)',
        defaultValue: defaultPassword,
      );

      // Use native file picker to save file
      final defaultFileName = 'diary_export_${Utils.toFileDateTime(DateTime.now())}.ics';

      // Get last used directory
      final lastDir = await _getLastUsedDirectory();

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save ICS Calendar File',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['ics'],
        initialDirectory: lastDir,
      );

      if (outputPath != null) {
        try {
          // Ensure .ics extension
          if (!outputPath.endsWith('.ics')) {
            outputPath = '$outputPath.ics';
          }

          // Save this directory for next time
          await _saveLastUsedDirectory(outputPath);

          File file = File(outputPath);
          final bool willEncrypt = password != null && password.isNotEmpty;

          // Get all notes from local data provider
          final notes = ref.read(notesLocalDataProvider);

          // Use ICS export with metadata
          await ref.read(icsFileStateProvider.notifier).exportWithMetadata(
                notes: notes,
                file: file,
                username: userData.username.isNotEmpty ? userData.username : null,
                salt: willEncrypt ? userData.salt : null,
                encrypted: willEncrypt,
                password: willEncrypt ? password : null,
              );

          LogWrapper.logger.i('ICS export finished successfully to $outputPath');
          _onImportExportSuccessfully(context);
        } catch (e) {
          LogWrapper.logger.e('Error exporting ICS "$outputPath": "$e"');
          _onError(context, 'Error during ICS export: $e');
        }
      } else {
        LogWrapper.logger.i('ICS export cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during ICS exporting: ${e.toString()}');
      _onError(context, 'Error during ICS exporting');
    }
  }

  Future<void> _onImportFromIcs(BuildContext context, WidgetRef ref) async {
    try {
      LogWrapper.logger.i('ICS import started');

      // Get last used directory
      final lastDir = await _getLastUsedDirectory();

      // Use native file picker to select ICS file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select ICS Calendar File to Import',
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
            _onError(context, 'Cannot read ICS file. File may be corrupted.');
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
              'Decrypt ICS Import',
              defaultValue: defaultPassword,
            );

            if (password == null || password.isEmpty) {
              _onError(context, 'Password required for encrypted ICS file');
              return;
            }
          }

          // Import the ICS data
          try {
            await ref.read(icsFileStateProvider.notifier).importFromIcs(
              File(path),
              password: password,
            );

            // Get imported notes and add to local DB
            final importedNotes = ref.read(icsFileStateProvider);

            for (var note in importedNotes) {
              await ref.read(notesLocalDataProvider.notifier).addElement(note);
              LogWrapper.logger.d('Imported note: ${note.title}');
            }

            LogWrapper.logger.i('ICS import finished successfully (${importedNotes.length} notes)');

            // Show success message with count
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Text('Successfully imported ${importedNotes.length} notes from ICS calendar'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  },
                ),
              ),
            );
          } catch (e) {
            LogWrapper.logger.e('Error during ICS import: $e');
            _onError(context, 'Error during ICS import. Wrong password or invalid ICS file?');
          }
        } catch (e) {
          LogWrapper.logger.e('Error importing ICS from file "$path": "$e"');
          _onError(context, 'Error during ICS import: $e');
        }
      } else {
        LogWrapper.logger.i('ICS import cancelled by user');
      }
    } catch (e) {
      LogWrapper.logger.e('Error during ICS importing: ${e.toString()}');
      _onError(context, 'Error during ICS importing');
    }
  }

  void _onError(BuildContext context, String errorMsg) {
    if (errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text('Error: $errorMsg'),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'OK',
            textColor: Theme.of(context).colorScheme.onError,
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        ),
      );
    }
  }

  Future<String?> _promptForPassword(BuildContext context, String title,
      {String? defaultValue}) async {
    final TextEditingController controller = TextEditingController(
      text: defaultValue ?? '',
    );
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password (Optional)',
            hintText: 'Leave empty for no encryption',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return password != null && password.isNotEmpty ? password : null;
  }

}
