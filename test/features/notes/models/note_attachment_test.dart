import 'dart:convert';

import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteAttachment', () {
    NoteAttachment createSample({String? remoteUrl}) {
      return NoteAttachment(
        id: 'attachment-id-1',
        noteId: 'note-id-1',
        filePath: '/app/images/note-id-1/attachment-id-1.jpg',
        createdAt: DateTime(2024, 6, 15, 10, 30),
        fileSize: 204800,
        remoteUrl: remoteUrl,
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
        expect(a.remoteUrl, isNull);
      });

      test('creates with remoteUrl', () {
        final a = createSample(remoteUrl: 'https://storage.example.com/img.jpg');
        expect(a.remoteUrl, 'https://storage.example.com/img.jpg');
      });

      test('remoteUrl defaults to null', () {
        final a = NoteAttachment(
          noteId: 'n',
          filePath: '/path.jpg',
          createdAt: DateTime.now(),
          fileSize: 0,
        );
        expect(a.remoteUrl, isNull);
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
        expect(copy.remoteUrl, original.remoteUrl);
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
          remoteUrl: 'https://example.com/new.jpg',
        );

        expect(copy.id, 'new-id');
        expect(copy.noteId, 'new-note');
        expect(copy.filePath, '/new/path.png');
        expect(copy.createdAt, newDate);
        expect(copy.fileSize, 1024);
        expect(copy.remoteUrl, 'https://example.com/new.jpg');
      });

      test('can set remoteUrl on attachment without one', () {
        final original = createSample();
        expect(original.remoteUrl, isNull);

        final updated = original.copyWith(
          remoteUrl: 'https://storage.example.com/synced.jpg',
        );
        expect(updated.remoteUrl, 'https://storage.example.com/synced.jpg');
        expect(updated.id, original.id);
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
        expect(restored.remoteUrl, original.remoteUrl);
      });

      test('round-trip preserves remoteUrl', () {
        final original = createSample(
          remoteUrl: 'https://storage.example.com/img.jpg',
        );
        final map = original.toMap();
        final restored = NoteAttachment.fromMap(map);

        expect(restored.remoteUrl, 'https://storage.example.com/img.jpg');
      });

      test('map contains expected keys', () {
        final map = createSample().toMap();
        expect(map.keys, containsAll([
          'id',
          'noteId',
          'filePath',
          'createdAt',
          'fileSize',
          'remoteUrl',
        ]));
      });

      test('fileSize defaults to 0 when missing from map', () {
        final map = createSample().toMap()..remove('fileSize');
        final restored = NoteAttachment.fromMap(map);
        expect(restored.fileSize, 0);
      });

      test('remoteUrl defaults to null when missing from map (backward compat)', () {
        final map = <String, dynamic>{
          'id': 'att-1',
          'noteId': 'note-1',
          'filePath': '/path.jpg',
          'createdAt': Utils.toDateTime(DateTime(2024, 1, 1)),
          'fileSize': 100,
        };
        final restored = NoteAttachment.fromMap(map);
        expect(restored.remoteUrl, isNull);
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
        expect(restored.remoteUrl, original.remoteUrl);
      });

      test('round-trip via JSON with remoteUrl', () {
        final original = createSample(
          remoteUrl: 'https://storage.example.com/img.jpg',
        );
        final jsonStr = original.toJson();
        final restored = NoteAttachment.fromJson(jsonStr);

        expect(restored.remoteUrl, 'https://storage.example.com/img.jpg');
      });
    });

    group('LocalDb map conversion', () {
      test('round-trip preserves data', () {
        final original = createSample();
        final dbMap = original.toDbMap();
        final restored = NoteAttachment.fromDbMap(dbMap);

        expect(restored.id, original.id);
        expect(restored.noteId, original.noteId);
        expect(restored.filePath, original.filePath);
        expect(restored.fileSize, original.fileSize);
        expect(restored.remoteUrl, original.remoteUrl);
      });

      test('round-trip preserves remoteUrl', () {
        final original = createSample(
          remoteUrl: 'https://storage.example.com/img.jpg',
        );
        final dbMap = original.toDbMap();
        final restored = NoteAttachment.fromDbMap(dbMap);

        expect(restored.remoteUrl, 'https://storage.example.com/img.jpg');
      });

      test('dbMap contains all keys', () {
        final a = createSample();
        final dbMap = a.toDbMap();
        expect(dbMap.keys, containsAll([
          'id',
          'noteId',
          'filePath',
          'createdAt',
          'fileSize',
          'remoteUrl',
        ]));
      });
    });

    group('primaryKeyValue', () {
      test('returns the attachment id', () {
        expect(createSample().primaryKeyValue, 'attachment-id-1');
      });
    });
  });
}
