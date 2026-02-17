import 'dart:io';

import 'package:day_tracker/core/database/abstract_local_db_provider_state.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/core/services/image_storage_service.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:day_tracker/features/notes/data/repositories/note_attachments_local_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteAttachmentsProvider
    extends AbstractLocalDbProviderState<NoteAttachment> {
  NoteAttachmentsProvider()
      : super(tableName: 'note_attachments', primaryKey: 'id');

  @override
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    return NoteAttachmentsLocalDbHelper(
      tableName: tableName,
      primaryKey: primaryKey,
      dbFile: File(
          '${settingsContainer.applicationDocumentsPath}/note_attachments.db'),
    );
  }

  List<NoteAttachment> getAttachmentsForNote(String noteId) {
    return state.where((a) => a.noteId == noteId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<NoteAttachment> addImage(File imageFile, String noteId) async {
    final attachment = await imageStorageService.saveImage(imageFile, noteId);
    await addElement(attachment);
    return attachment;
  }

  Future<void> removeAttachment(NoteAttachment attachment) async {
    await imageStorageService.deleteAttachment(attachment);
    await deleteElement(attachment);
  }

  Future<void> removeAllForNote(String noteId) async {
    final toDelete = getAttachmentsForNote(noteId);
    await imageStorageService.deleteAllForNote(noteId);
    for (final attachment in toDelete) {
      await deleteElement(attachment);
    }
  }
}

final noteAttachmentsProvider =
    StateNotifierProvider<NoteAttachmentsProvider, List<NoteAttachment>>((ref) {
  return NoteAttachmentsProvider();
});
