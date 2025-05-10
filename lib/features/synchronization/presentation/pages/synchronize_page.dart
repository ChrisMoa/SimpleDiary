// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/synchronization/domain/providers/file_db_provider.dart';
import 'package:day_tracker/features/synchronization/presentation/widgets/supabase_sync_widget.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SynchronizePage extends ConsumerStatefulWidget {
  const SynchronizePage({super.key});

  @override
  ConsumerState<SynchronizePage> createState() => _SynchronizePageState();
}

class _SynchronizePageState extends ConsumerState<SynchronizePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // File Import/Export Section
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
                vertical: 5, horizontal: 10),
            child: _buildListItem(
              context,
              icon: const Icon(Icons.cloud_upload),
              onPressed: () => _onExportToFile(context),
              buttonText: 'Export',
              headerText: 'Export to .json',
              subText:
                  'Notes within the period will be exported to a .json file',
            ),
          ),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
                vertical: 10, horizontal: 10),
            child: _buildListItem(
              context,
              icon: const Icon(Icons.cloud_download),
              onPressed: () => _onImportFromFile(context),
              buttonText: 'Import',
              headerText: 'Import .json',
              subText: 'Files will be imported from a .json file',
            ),
          ),

          // Divider between sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
              thickness: 1,
            ),
          ),

          // Supabase Synchronization Section - Fixed to avoid Expanded issue
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: const SupabaseSyncWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required VoidCallback onPressed,
    required Icon icon,
    required String buttonText,
    required String headerText,
    required String subText,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      color: theme.colorScheme.secondaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerText,
                style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                subText,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: TextButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(
                buttonText,
                style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return theme.colorScheme.tertiaryContainer
                          .withOpacity(0.6);
                    }
                    return theme.colorScheme.tertiaryContainer;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onExportToFile(BuildContext context) async {
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

  Future<void> _onImportFromFile(BuildContext context) async {
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

  // Helper methods for file name and password prompts
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
