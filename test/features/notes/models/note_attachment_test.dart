import 'dart:convert';

import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteAttachment', () {
    NoteAttachment createSample() {
      return NoteAttachment(
        id: 'attachment-id-1',
        noteId: 'note-id-1',
        filePath: '/app/images/note-id-1/attachment-id-1.jpg',
        createdAt: DateTime(2024, 6, 15, 10, 30),
        fileSize: 204800,
      );
    }

    group('construction', () {
      test('creates with all fields', () {
        final a = createSample();
        expect(a.id, 'attachment-id-1');
        expect(a.noteId, 'note-id-1');
        expect(a.filePath, '/app/images/note-id-1/attachment-id-1.jpg');
        expect(a.createdAt, DateTime(2024, 6, 15, 10, 30));
        expect(a.fileSize, 204800);
      });

      test('auto-generates UUID when id is not provided', () {
        final a = NoteAttachment(
          noteId: 'note-x',
          filePath: '/some/path.jpg',
          createdAt: DateTime.now(),
          fileSize: 0,
        );
        expect(a.id, isNotNull);
        expect(a.id, isNotEmpty);
      });

      test('two auto-generated IDs are different', () {
        final a1 = NoteAttachment(
          noteId: 'n',
          filePath: '/a.jpg',
          createdAt: DateTime.now(),
          fileSize: 0,
        );
        final a2 = NoteAttachment(
          noteId: 'n',
          filePath: '/b.jpg',
          createdAt: DateTime.now(),
          fileSize: 0,
        );
        expect(a1.id, isNot(equals(a2.id)));
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = createSample();
        final copy = original.copyWith(fileSize: 512000);

        expect(copy.fileSize, 512000);
        expect(copy.id, original.id);
        expect(copy.noteId, original.noteId);
        expect(copy.filePath, original.filePath);
        expect(copy.createdAt, original.createdAt);
      });

      test('can update all fields', () {
        final original = createSample();
        final newDate = DateTime(2025, 1, 1, 12, 0);
        final copy = original.copyWith(
          id: 'new-id',
          noteId: 'new-note',
          filePath: '/new/path.png',
          createdAt: newDate,
          fileSize: 1024,
        );

        expect(copy.id, 'new-id');
        expect(copy.noteId, 'new-note');
        expect(copy.filePath, '/new/path.png');
        expect(copy.createdAt, newDate);
        expect(copy.fileSize, 1024);
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        final original = createSample();
        final map = original.toMap();
        final restored = NoteAttachment.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.noteId, original.noteId);
        expect(restored.filePath, original.filePath);
        expect(
          Utils.toDateTime(restored.createdAt),
          Utils.toDateTime(original.createdAt),
        );
        expect(restored.fileSize, original.fileSize);
      });

      test('map contains expected keys', () {
        final map = createSample().toMap();
        expect(map, contains('id'));
        expect(map, contains('noteId'));
        expect(map, contains('filePath'));
        expect(map, contains('createdAt'));
        expect(map, contains('fileSize'));
      });

      test('fileSize defaults to 0 when missing from map', () {
        final map = createSample().toMap()..remove('fileSize');
        final restored = NoteAttachment.fromMap(map);
        expect(restored.fileSize, 0);
      });
    });

    group('toJson / fromJson', () {
      test('produces valid JSON string', () {
        final a = createSample();
        final jsonStr = a.toJson();
        expect(() => json.decode(jsonStr), returnsNormally);
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        expect(decoded['noteId'], 'note-id-1');
      });

      test('round-trip via JSON', () {
        final original = createSample();
        final jsonStr = original.toJson();
        final restored = NoteAttachment.fromJson(jsonStr);

        expect(restored.id, original.id);
        expect(restored.noteId, original.noteId);
        expect(restored.filePath, original.filePath);
        expect(restored.fileSize, original.fileSize);
      });
    });

    group('LocalDb map conversion', () {
      test('round-trip preserves data', () {
        final original = createSample();
        final dbMap = original.toDbMap();
        final restored = original.fromLocalDbMap(dbMap) as NoteAttachment;

        expect(restored.id, original.id);
        expect(restored.noteId, original.noteId);
        expect(restored.filePath, original.filePath);
        expect(restored.fileSize, original.fileSize);
      });

      test('dbMap uses same keys as toMap', () {
        final a = createSample();
        final dbMap = a.toDbMap();
        expect(dbMap, contains('id'));
        expect(dbMap, contains('noteId'));
        expect(dbMap, contains('filePath'));
        expect(dbMap, contains('createdAt'));
        expect(dbMap, contains('fileSize'));
      });
    });

    group('getId', () {
      test('returns the attachment id', () {
        expect(createSample().getId(), 'attachment-id-1');
      });
    });
  });
}
