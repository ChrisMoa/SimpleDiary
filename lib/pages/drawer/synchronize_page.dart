import 'dart:io';

import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/file_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/remote_db_provider.dart';
import 'package:SimpleDiary/provider/user/remote_user_login_provider.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/user/user_data.dart';

class SynchronizePage extends ConsumerStatefulWidget {
  const SynchronizePage({super.key});

  @override
  ConsumerState<SynchronizePage> createState() => _SynchronizePageState();
}

class _SynchronizePageState extends ConsumerState<SynchronizePage> {
  // bool _isUploading = false;
  // double _uploadProcess = 100;
  late Directory _rootDirectory; //! the root directory of the dialog

  @override
  void initState() {
    _onInitAsync();
    super.initState();
  }

  void _onInitAsync() async {
    _rootDirectory = await getApplicationDocumentsDirectory();
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
            _buildFirebaseFrame(context),
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
            onPressed: () async {
              try {
                LogWrapper.logger.i('export started');

                String? path = await FilesystemPicker.openDialog(
                  title: 'Select or create a file in which the data should be exported',
                  context: context,
                  fsType: FilesystemType.file,
                  rootDirectory: _rootDirectory,
                  fileTileSelectMode: FileTileSelectMode.wholeTile,
                  contextActions: [
                    FilesystemPickerNewFolderContextAction(),
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
                onError(context, 'Error during exporting');
              }
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Export"),
          ),
          const SizedBox(
            width: 40,
          ),
          TextButton.icon(
            onPressed: () async {
              try {
                LogWrapper.logger.i('import database');
                String? path = await FilesystemPicker.openDialog(
                  title: 'Select or create a file that should be imported',
                  context: context,
                  fsType: FilesystemType.file,
                  rootDirectory: _rootDirectory,
                  fileTileSelectMode: FileTileSelectMode.wholeTile,
                  contextActions: [
                    FilesystemPickerNewFolderContextAction(),
                  ],
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
                onError(context, 'Error during importing');
              }
            },
            icon: const Icon(Icons.cloud_download),
            label: const Text("Download"),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseFrame(BuildContext context) {
    return FutureBuilder<String>(
        future: ref.watch(remoteUserLoginProvider),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('An error occured fetching values: ${snapshot.error.toString()}');
          }
          var user = ref.read(userDataProvider);

          ref.read(remoteDbStateProvider.notifier).token = snapshot.data!;
          ref.watch(remoteDbStateProvider);

          return Column(
            children: [
              SizedBox(
                height: 60,
                width: double.infinity,
                child: _buildFirebaseButtons(context, snapshot.data!, user),
              ),
            ],
          );
        });
  }

  Widget _buildFirebaseButtons(BuildContext context, String token, UserData user) {
    if (!user.isRemoteUser) {
      return SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Text('create remote db settings on user account', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary)));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () async {
            try {
              LogWrapper.logger.i('upload started');
              await ref.read(remoteDbStateProvider.notifier).upload(ref.read(diaryDayFullDataProvider));
              LogWrapper.logger.i('upload finished');
            } catch (e) {
              LogWrapper.logger.e('Error during uploading: ${e.toString()}');
              // ignore: use_build_context_synchronously
              onError(context, 'Error during uploading');
            }
          },
          icon: const Icon(Icons.cloud_upload),
          label: const Text("Upload"),
        ),
        const SizedBox(
          width: 40,
        ),
        TextButton.icon(
          onPressed: () async {
            try {
              LogWrapper.logger.i('downloads database');
              //* download data
              await ref.read(remoteDbStateProvider.notifier).download();
              //* clear local dbs
              await ref.read(diaryDayLocalDbDataProvider.notifier).clearTable();
              await ref.read(notesLocalDataProvider.notifier).clearTable();
              //* add diaryDay to local dbs
              for (var diaryDay in ref.read(remoteDbStateProvider)) {
                await ref.read(diaryDayLocalDbDataProvider.notifier).addElement(diaryDay);
                for (var note in diaryDay.notes) {
                  await ref.read(notesLocalDataProvider.notifier).addElement(note);
                }
              }
              LogWrapper.logger.i('download finished');
            } catch (e) {
              LogWrapper.logger.t('Error during downloading: ${e.toString()}');
              // ignore: use_build_context_synchronously
              onError(context, 'Error during downloading');
            }
          },
          icon: const Icon(Icons.cloud_download),
          label: const Text("Download"),
        ),
      ],
    );
  }

  void onError(BuildContext context, String errorMsg) {
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
