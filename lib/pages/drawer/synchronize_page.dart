import 'dart:io';

import 'package:SimpleDiary/model/active_platform.dart';
import 'package:SimpleDiary/widgets/filesystempicker/filesystempicker_new_file_context_action.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/file_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class SynchronizePage extends ConsumerStatefulWidget {
  const SynchronizePage({super.key});

  @override
  ConsumerState<SynchronizePage> createState() => _SynchronizePageState();
}


class _SynchronizePageState extends ConsumerState<SynchronizePage> {
  // bool _isUploading = false;
  // double _uploadProcess = 100;
  late Directory _importExportRootDirectory; //! the root directory of the import/export dialog
  // todo: the root directory should be the current user directory on desktop and the internal storage on android

  @override
  void initState() {
    _onInitAsync();
    super.initState();
  }

  void _onInitAsync() async {
    _importExportRootDirectory = await _getPlatformSpecificDocumentsDirectory();
  }

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

      String? path = await FilesystemPicker.openDialog(
        title: 'Select or create a file in which the data should be exported',
        context: context,
        fsType: FilesystemType.file,
        rootDirectory: _importExportRootDirectory,
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
        await ref.read(fileDbStateProvider.notifier).export(ref.read(diaryDayFullDataProvider), File(path));
      } catch (e) {
        LogWrapper.logger.e('Error exporting "$path": "$e"');
      }
      LogWrapper.logger.i('export finished');
    } catch (e) {
      LogWrapper.logger.e('Error during exporting: ${e.toString()}');
      // ignore: use_build_context_synchronously
      _onError(context, 'Error during exporting');
    }
  }

  void _onImportFromFile() async {
    try {
      LogWrapper.logger.i('import database');
      String? path = await FilesystemPicker.openDialog(
        title: 'Select or create a file that should be imported',
        context: context,
        fsType: FilesystemType.file,
        rootDirectory: _importExportRootDirectory,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        contextActions: [],
      );
      if (path == null) {
        return;
      }
      try {
        LogWrapper.logger.i('downloads database');
        //* download data
        await ref.read(fileDbStateProvider.notifier).import(File(path));
        //* clear local dbs
        await ref.read(diaryDayLocalDbDataProvider.notifier).clearTable();
        await ref.read(notesLocalDataProvider.notifier).clearTable();
        //* add diaryDay to local dbs
        for (var diaryDay in ref.read(fileDbStateProvider)) {
          await ref.read(diaryDayLocalDbDataProvider.notifier).addElement(diaryDay);
          for (var note in diaryDay.notes) {
            await ref.read(notesLocalDataProvider.notifier).addElement(note);
          }
        }
        LogWrapper.logger.i('import finished');
      } catch (e) {
        LogWrapper.logger.i('Error exporting "$path": "$e"');
      }
    } catch (e) {
      LogWrapper.logger.t('Error during importing: ${e.toString()}');
      // ignore: use_build_context_synchronously
      _onError(context, 'Error during importing');
    }
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

  Future<Directory> _getPlatformSpecificDocumentsDirectory() async{
    if(activePlatform.platform == ActivePlatform.android || activePlatform.platform == ActivePlatform.ios){
        return Directory('/storage/emulated/0/');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
}
