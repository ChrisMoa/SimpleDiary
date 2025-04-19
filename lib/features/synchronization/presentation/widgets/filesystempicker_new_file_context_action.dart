import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:filesystem_picker/src/actions/action.dart';
import 'package:filesystem_picker/src/actions/shakeable_dialogs.dart';
import 'package:flutter/material.dart';

/// The signature of the error message string interpolator when the folder being created already exists.
typedef FilesystemPickerNewFileMessageBuilder = String Function(String value);

/// Defines the action to create a new folder.
class FilesystemPickerNewFileContextAction extends FilesystemPickerContextAction {
  /// Title of the dialog for creating a new folder.
  final String? dialogTitle;

  /// Message in the dialog for creating a new folder.
  final String? dialogPrompt;

  /// The text of the "OK" button in the dialog for creating a new folder.
  final String? dialogOkText;

  /// The text of the "Cancel" button in the dialog for creating a new folder.
  final String? dialogCancelText;

  /// The interpolator of the error message string when the folder being created already exists.
  /// Default message: 'The folder with the name "&lt;new folder name&gt;" already exists. Please use another name.'
  final FilesystemPickerNewFileMessageBuilder? alreadyExistsMessage;

  /// The theme that is passed to the dialog.
  final ThemeData? theme;

  /// Creates an action definition.
  FilesystemPickerNewFileContextAction({
    super.icon = const Icon(Icons.insert_drive_file_rounded),
    super.text = 'New file',
    this.dialogTitle,
    this.dialogPrompt,
    this.dialogOkText,
    this.dialogCancelText,
    this.alreadyExistsMessage,
    this.theme,
  }) : super();

  /// Called when the user tapped on a button or menu item of a contextual action.
  @override
  Future<bool> call(BuildContext context, Directory path) async {
    Widget dialog = FilesystemPickerNewFileDialog(
      title: dialogTitle,
      prompt: dialogPrompt,
      okText: dialogOkText,
      cancelText: dialogCancelText,
      onDone: (value) async {
        if (value != null) {
          try {
            if (!await _createFile(path, value)) {
              final message = (alreadyExistsMessage != null) ? alreadyExistsMessage!.call(value) : 'The file with the name "$value" already exists. Please use another filename.';

              if (context.mounted) {
                await _showError(context, message);
              }
              return;
            }
          } catch (e) {
            // debugPrint('Error: ${e.runtimeType}');

            if (context.mounted) {
              await _showError(context, '$e');
            }
            return;
          }
        }

        if (context.mounted) {
          Navigator.maybeOf(context)?.pop(true);
        }
      },
    );

    if (theme != null) {
      dialog = Theme(
        data: theme!,
        child: dialog,
      );
    }

    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => dialog,
    );
    return (result == true);
  }

  Future<void> _showError(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.maybeOf(context)?.pop(),
          ),
        ],
      ),
    );
  }

  Future<bool> _createFile(Directory parentDirectory, String fileName) async {
    final newFile = File(p.join(parentDirectory.path, fileName));
    if (newFile.existsSync()) {
      return false;
    } else {
      newFile.createSync();
      return true;
    }
  }
}

/// A dialog asking for a name for the new folder.
class FilesystemPickerNewFileDialog extends StatefulWidget {
  /// Dialog title.
  final String? title;

  /// Dialog message before the new folder name input field.
  final String? prompt;

  /// The text of the "OK" button.
  final String? okText;

  /// The text of the "Cancel" button.
  final String? cancelText;

  /// The handler called when the user specified the name of the new folder and clicked the "OK" button.
  final ValueChanged<String?> onDone;

  /// Creates a dialog asking for a name for the new folder.
  const FilesystemPickerNewFileDialog({
    Key? key,
    this.title,
    this.prompt,
    this.okText,
    this.cancelText,
    required this.onDone,
  }) : super(key: key);

  @override
  State<FilesystemPickerNewFileDialog> createState() => _FilesystemPickerNewFileDialogState();
}

class _FilesystemPickerNewFileDialogState extends State<FilesystemPickerNewFileDialog> {
  final ShakeableController _shakeController = ShakeableController();
  String? _folderName;

  @override
  Widget build(BuildContext context) {
    return ShakeableAnimation(
      controller: _shakeController,
      child: AlertDialog(
        title: Text(widget.title ?? 'New file'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.prompt?.isNotEmpty ?? true)
              Text(
                widget.prompt ?? 'Please enter new file name',
              ),
            TextField(
              autofocus: true,
              onChanged: (value) => _folderName = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text((widget.cancelText ?? 'Cancel').toUpperCase()),
            // style: TextButton.styleFrom(
            //   // foregroundColor: Theme.of(context).textTheme.button?.color,
            //   foregroundColor: Theme.of(context).dialogTheme.contentTextStyle?.color ??
            //       Theme.of(context).textTheme.bodyMedium?.color,
            // ),
            onPressed: () {
              Navigator.maybeOf(context)?.pop();
            },
          ),
          TextButton(
            child: Text((widget.okText ?? 'OK').toUpperCase()),
            // style: TextButton.styleFrom(
            //   foregroundColor: Theme.of(context).primaryColor,
            // ),
            onPressed: () {
              if (_folderName?.isNotEmpty ?? false) {
                widget.onDone.call(_folderName);
              } else {
                _shakeController.shake();
              }
            },
          ),
        ],
      ),
    );
  }
}

