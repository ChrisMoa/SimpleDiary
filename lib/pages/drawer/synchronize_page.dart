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

class _ListItem extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String buttonText;
  final String headerText;
  final String subText;

  const _ListItem({required this.onPressed, required this.icon, required this.buttonText, required this.headerText, required this.subText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
                headerText,
              ),
              Text(
                subText,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer, // Change font color based on theme
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
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.6); // Change color when pressed
                    }
                    return Theme.of(context).colorScheme.tertiaryContainer; // Default color
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SynchronizePageState extends ConsumerState<SynchronizePage> {
  //* parameters -------------------------------------------------------------------------------------------------------------------------------------

  //* builds -----------------------------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 10),
            child: _ListItem(
              icon: const Icon(Icons.cloud_upload),
              onPressed: _onExportToFile,
              buttonText: 'Export',
              headerText: 'Exportieren nach .json',
              subText: 'Notizen in dem Zeitraum werden zu einer .json Datei exportiert',
            ),
          ),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 10),
            child: _ListItem(
              icon: const Icon(Icons.cloud_upload),
              onPressed: _onImportFromFile,
              buttonText: 'Import',
              headerText: 'Importieren .json',
              subText: 'Dateien werden von einer .json Datei importiert',
            ),
          ),
        ],
      ),
    );
  }

  //* build helper -----------------------------------------------------------------------------------------------------------------------------------

  //* callbacks --------------------------------------------------------------------------------------------------------------------------------------

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
