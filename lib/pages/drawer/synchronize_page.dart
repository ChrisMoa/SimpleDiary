import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/remote_db_provider.dart';
import 'package:SimpleDiary/provider/user/remote_user_login_provider.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SynchronizePage extends ConsumerStatefulWidget {
  const SynchronizePage({super.key});

  @override
  ConsumerState<SynchronizePage> createState() => _SynchronizePageState();
}

class _SynchronizePageState extends ConsumerState<SynchronizePage> {
  // bool _isUploading = false;
  // double _uploadProcess = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: FutureBuilder<String>(
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
              if (!user.isRemoteUser) {
                return SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Text('create remote db settings on user account', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary)));
              }

              ref.read(remoteDbStateProvider.notifier).token = snapshot.data!;
              ref.watch(remoteDbStateProvider);

              return Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildUploadButton(context, snapshot.data!),
                        const SizedBox(
                          width: 40,
                        ),
                        _buildDownloadButton(context, snapshot.data!),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
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

  Widget _buildUploadButton(BuildContext context, String token) {
    return TextButton.icon(
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
    );
  }

  Widget _buildDownloadButton(BuildContext context, String token) {
    return TextButton.icon(
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
    );
  }
}
