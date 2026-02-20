import 'dart:io';

import 'package:day_tracker/core/database/db_repository.dart';
import 'package:day_tracker/core/services/image_storage_service.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// NoteAttachmentsProvider — subclasses DbRepository for custom image logic.
class NoteAttachmentsProvider extends DbRepository<NoteAttachment> {
  NoteAttachmentsProvider()
      : super(
          tableName: NoteAttachment.tableName,
          columns: NoteAttachment.columns,
          fromMap: NoteAttachment.fromDbMap,
          migrations: NoteAttachment.migrations,
        );

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
