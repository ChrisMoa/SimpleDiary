// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/synchronization/domain/providers/file_db_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileSyncWidget extends ConsumerWidget {
  const FileSyncWidget({super.key});

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
                'Import and export your diary data to JSON files with optional encryption.',
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
      LogWrapper.logger.i('Export started');
      var rootDirectory =
          Directory(settingsContainer.applicationExternalDocumentsPath);

      // Show dialog to enter filename first
      final fileName = await _promptForFileName(
        context,
        'Export Data',
        'data_export.json',
      );
      if (fileName == null) return;

      // Pick directory
      String? dirPath = await FilesystemPicker.open(
        title: 'Select directory to save export file',
        context: context,
        fsType: FilesystemType.folder,
        rootDirectory: rootDirectory,
        pickText: 'Save file here',
        folderIconColor: Theme.of(context).colorScheme.primary,
      );

      if (dirPath != null) {
        final fullPath = '$dirPath/$fileName';

        // Prompt for encryption password, default to user's password
        final userData = ref.read(userDataProvider);
        final defaultPassword = userData.clearPassword;

        final password = await _promptForPassword(
          context,
          'Encrypt Export',
          defaultValue: defaultPassword,
        );

        try {
          File file = File(fullPath);
          await ref
              .read(fileDbStateProvider.notifier)
              .export(ref.read(diaryDayFullDataProvider), file);

          if (password != null && password.isNotEmpty) {
            // Use password for encryption
            String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(
                password, userData.salt);
            var encryptor = AesEncryptor(encryptionKey: encryptionKey);
            encryptor.encryptFile(file);
            LogWrapper.logger.i('File encrypted with provided password');
          } else {
            LogWrapper.logger.i('File exported without encryption');
          }

          LogWrapper.logger.i('Export finished successfully');
          _onImportExportSuccessfully(context);
        } catch (e) {
          LogWrapper.logger.e('Error exporting "$fullPath": "$e"');
          _onError(context, 'Error during export: $e');
        }
      }
    } catch (e) {
      LogWrapper.logger.e('Error during exporting: ${e.toString()}');
      _onError(context, 'Error during exporting');
    }
  }

  Future<void> _onImportFromFile(BuildContext context, WidgetRef ref) async {
    try {
      LogWrapper.logger.i('Import database started');
      var rootDirectory =
          Directory(settingsContainer.applicationExternalDocumentsPath);

      // Use open instead of openDialog to properly select files
      String? path = await FilesystemPicker.open(
        title: 'Select file to import',
        context: context,
        fsType: FilesystemType.file,
        allowedExtensions: ['.json'],
        rootDirectory: rootDirectory,
        pickText: 'Select this file',
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        requestPermission: () async => true,
      );

      if (path != null) {
        try {
          File file = File(path);
          LogWrapper.logger.i('Import from file ${file.path}');

          // Prompt for decryption password
          final userData = ref.read(userDataProvider);
          final defaultPassword = userData.clearPassword;

          final password = await _promptForPassword(
            context,
            'Decrypt Import',
            defaultValue: defaultPassword,
          );

          if (password != null && password.isNotEmpty) {
            // Use password for decryption
            String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(
                password, userData.salt);
            var decryptor = AesEncryptor(encryptionKey: encryptionKey);

            try {
              decryptor.decryptFile(file);
              LogWrapper.logger.i('File decrypted with provided password');
            } catch (e) {
              LogWrapper.logger.e('Error decrypting file: $e');
              _onError(context, 'Error decrypting file. Wrong password?');
              return;
            }
          }

          await ref.read(fileDbStateProvider.notifier).import(File(path));

          // Re-encrypt the file if needed
          if (password != null && password.isNotEmpty) {
            String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(
                password, userData.salt);
            var encryptor = AesEncryptor(encryptionKey: encryptionKey);
            encryptor.encryptFile(file);
          }

          // Add diary entries to local DB
          for (var diaryDay in ref.read(fileDbStateProvider)) {
            await ref
                .read(diaryDayLocalDbDataProvider.notifier)
                .addElement(diaryDay);
            for (var note in diaryDay.notes) {
              await ref.read(notesLocalDataProvider.notifier).addElement(note);
            }
          }

          LogWrapper.logger.i('Import finished successfully');
          _onImportExportSuccessfully(context);
        } catch (e) {
          LogWrapper.logger.e('Error importing from file "$path": "$e"');
          _onError(context, 'Error during import: $e');
        }
      }
    } catch (e) {
      LogWrapper.logger.e('Error during importing: ${e.toString()}');
      _onError(context, 'Error during importing');
    }
  }

  void _onImportExportSuccessfully(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Operation completed successfully'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      ),
    );
  }

  void _onError(BuildContext context, String errorMsg) {
    if (errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text('Error: $errorMsg'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
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

  Future<String?> _promptForFileName(
    BuildContext context,
    String title,
    String defaultName,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: defaultName,
    );
    final fileName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'Enter file name with .json extension',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will create a new file or overwrite an existing file with the same name.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String name = controller.text.trim();
              // Ensure the file has .json extension
              if (!name.endsWith('.json')) {
                name += '.json';
              }
              Navigator.pop(context, name);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return fileName;
  }
}
