import 'dart:io';
import 'package:SimpleDiary/model/Settings/settings_container.dart';
import 'package:SimpleDiary/model/encryption/aes_encryptor.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:SimpleDiary/widgets/filesystempicker/filesystempicker_new_file_context_action.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/file_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
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
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            _buildFileSynchronization(context),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSynchronization(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _onExportToFile,
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Export"),
          ),
          const SizedBox(
            width: 40,
          ),
          TextButton.icon(
            onPressed: _onImportFromFile,
            icon: const Icon(Icons.cloud_download),
            label: const Text("Import"),
          ),
        ],
      ),
    );
  }

  void _onExportToFile() async {
    try {
      LogWrapper.logger.i('export started');
      var rootDirectory = Directory(settingsContainer.pathSettings.applicationDocumentsPath.value);

      String? path = await FilesystemPicker.openDialog(
        title: 'Select or create a file in which the data should be exported',
        context: context,
        fsType: FilesystemType.file,
        allowedExtensions: ['.json'],
        showGoUp: true,
        rootDirectory: rootDirectory,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        contextActions: [
          FilesystemPickerNewFolderContextAction(),
          FilesystemPickerNewFileContextAction(),
        ],
      );
      if (path == null) {
        return;
      }
      try {
        File file = File(path);
        var userData = ref.read(userDataProvider);
        var encryptor = AesEncryptor(password: userData.password);
        await ref.read(fileDbStateProvider.notifier).export(ref.read(diaryDayFullDataProvider), file);
        encryptor.encryptFile(file);
      } catch (e) {
        LogWrapper.logger.e('Error exporting "$path": "$e"');
      }
      LogWrapper.logger.i('export finished');
      _onImportExportSuccessfully();
    } catch (e) {
      LogWrapper.logger.e('Error during exporting: ${e.toString()}');
      // ignore: use_build_context_synchronously
      _onError(context, 'Error during exporting');
    }
  }

  void _onImportFromFile() async {
    try {
      LogWrapper.logger.i('import database');
      var rootDirectory = Directory(settingsContainer.pathSettings.applicationDocumentsPath.value);
      String? path = await FilesystemPicker.openDialog(
        title: 'Select or create a file that should be imported',
        context: context,
        fsType: FilesystemType.file,
        allowedExtensions: ['.json'],
        rootDirectory: rootDirectory,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        contextActions: [],
      );
      if (path == null) {
        return;
      }
      try {
        File file = File(path);
        LogWrapper.logger.i('import from file ${file.path}');
        var userData = ref.read(userDataProvider);
        var decryptor = AesEncryptor(password: userData.password);
        decryptor.decryptFile(file);
        await ref.read(fileDbStateProvider.notifier).import(File(path));
        decryptor.encryptFile(file);

        //* read data
        //* add diaryDay to local dbs
        for (var diaryDay in ref.read(fileDbStateProvider)) {
          await ref.read(diaryDayLocalDbDataProvider.notifier).addElement(diaryDay);
          for (var note in diaryDay.notes) {
            await ref.read(notesLocalDataProvider.notifier).addElement(note);
          }
        }
        LogWrapper.logger.i('import finished successfully');
        _onImportExportSuccessfully();
      } catch (e) {
        LogWrapper.logger.i('Error importing from file "$path": "$e"');
      }
    } catch (e) {
      LogWrapper.logger.t('Error during importing: ${e.toString()}');
      // ignore: use_build_context_synchronously
      _onError(context, 'Error during importing');
    }
  }

  void _onImportExportSuccessfully() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Import/Export was successfully'),
        action: SnackBarAction(
          label: 'OK',
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
          duration: const Duration(seconds: 3),
          content: Text('Error: $errorMsg'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        ),
      );
      errorMsg = '';
    }
  }
}
