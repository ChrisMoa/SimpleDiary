import 'dart:io';

import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:path/path.dart' as p;

class ImageStorageService {
  Directory _imagesDir() {
    final basePath = settingsContainer.applicationDocumentsPath;
    return Directory(p.join(basePath, 'images'));
  }

  Directory _noteDirFor(String noteId) {
    return Directory(p.join(_imagesDir().path, noteId));
  }

  /// Copies [sourceFile] into the app's image store for [noteId].
  /// Returns a [NoteAttachment] describing the saved file.
  Future<NoteAttachment> saveImage(File sourceFile, String noteId) async {
    final noteDir = _noteDirFor(noteId);
    if (!noteDir.existsSync()) {
      noteDir.createSync(recursive: true);
    }

    final ext = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path)
        : '.jpg';
    final attachmentId = Utils.uuid.v4();
    final destPath = p.join(noteDir.path, '$attachmentId$ext');
    final destFile = await sourceFile.copy(destPath);

    final fileSize = destFile.lengthSync();
    LogWrapper.logger.d('ImageStorageService: saved image to $destPath ($fileSize bytes)');

    return NoteAttachment(
      id: attachmentId,
      noteId: noteId,
      filePath: destPath,
      createdAt: DateTime.now(),
      fileSize: fileSize,
    );
  }

  /// Deletes the file referenced by [attachment] from disk.
  Future<void> deleteAttachment(NoteAttachment attachment) async {
    final file = File(attachment.filePath);
    if (file.existsSync()) {
      file.deleteSync();
      LogWrapper.logger.d('ImageStorageService: deleted ${attachment.filePath}');
    }
    // Remove note dir if empty
    final noteDir = _noteDirFor(attachment.noteId);
    if (noteDir.existsSync() && noteDir.listSync().isEmpty) {
      noteDir.deleteSync();
    }
  }

  /// Deletes all image files for [noteId].
  Future<void> deleteAllForNote(String noteId) async {
    final noteDir = _noteDirFor(noteId);
    if (noteDir.existsSync()) {
      noteDir.deleteSync(recursive: true);
      LogWrapper.logger.d('ImageStorageService: deleted all images for note $noteId');
    }
  }

  /// Returns total bytes used by stored images.
  int getTotalStorageBytes() {
    final dir = _imagesDir();
    if (!dir.existsSync()) return 0;
    var total = 0;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File) {
        total += entity.lengthSync();
      }
    }
    return total;
  }
}

final imageStorageService = ImageStorageService();
