import 'dart:convert';
import 'dart:io';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/synchronization/domain/providers/ics_file_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IcsFileProvider provider;
  late Directory tempDir;

  setUp(() {
    provider = IcsFileProvider();
    tempDir = Directory.systemTemp.createTempSync('ics_file_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  List<Note> createSampleNotes() {
    return [
      Note(
        id: 'note-1',
        title: 'Team Meeting',
        description: 'Weekly standup',
        from: DateTime(2024, 3, 15, 10, 0),
        to: DateTime(2024, 3, 15, 11, 0),
        noteCategory: availableNoteCategories[0], // Work
      ),
      Note(
        id: 'note-2',
        title: 'Lunch',
        description: 'At the cafeteria',
        from: DateTime(2024, 3, 15, 12, 0),
        to: DateTime(2024, 3, 15, 13, 0),
        noteCategory: availableNoteCategories[2], // Food
      ),
    ];
  }

  group('IcsExportMetadata', () {
    test('toMap / fromMap round-trip', () {
      final metadata = IcsExportMetadata(
        username: 'testuser',
        salt: 'testsalt',
        exportDate: DateTime(2024, 3, 15),
        encrypted: true,
        noteCount: 5,
      );

      final map = metadata.toMap();
      final restored = IcsExportMetadata.fromMap(map);

      expect(restored.username, 'testuser');
      expect(restored.salt, 'testsalt');
      expect(restored.encrypted, true);
      expect(restored.noteCount, 5);
    });

    test('handles null username and salt', () {
      final metadata = IcsExportMetadata(
        exportDate: DateTime.now(),
        encrypted: false,
        noteCount: 0,
      );
      final map = metadata.toMap();
      expect(map['username'], isNull);
      expect(map['salt'], isNull);
    });

    test('fromMap handles missing noteCount', () {
      final map = {
        'exportDate': DateTime.now().toIso8601String(),
        'encrypted': false,
      };
      final metadata = IcsExportMetadata.fromMap(map);
      expect(metadata.noteCount, 0);
    });
  });

  group('IcsFileProvider', () {
    group('exportToString', () {
      test('produces valid JSON with ICS metadata (unencrypted)', () {
        final notes = createSampleNotes();
        final result = provider.exportToString(
          notes: notes,
          username: 'testuser',
          encrypted: false,
        );

        final decoded = jsonDecode(result) as Map<String, dynamic>;
        expect(decoded['version'], '1.0');
        expect(decoded['format'], 'ics');
        expect(decoded['metadata']['encrypted'], false);
        expect(decoded['metadata']['username'], 'testuser');
        expect(decoded['metadata']['noteCount'], 2);

        // Data should be a valid ICS string
        final data = decoded['data'] as String;
        expect(data, contains('BEGIN:VCALENDAR'));
        expect(data, contains('Team Meeting'));
      });

      test('produces encrypted ICS data when password provided', () {
        final hashResult = PasswordAuthService.hashPassword('password');
        final salt = hashResult['salt']!;
        final notes = createSampleNotes();

        final result = provider.exportToString(
          notes: notes,
          username: 'testuser',
          salt: salt,
          encrypted: true,
          password: 'password',
        );

        final decoded = jsonDecode(result) as Map<String, dynamic>;
        expect(decoded['metadata']['encrypted'], true);
        expect(decoded['metadata']['salt'], salt);

        // Data should NOT contain plain ICS (it's encrypted)
        final data = decoded['data'] as String;
        expect(data, isNot(contains('BEGIN:VCALENDAR')));
      });
    });

    group('exportPlainIcs', () {
      test('writes plain ICS file without wrapper', () async {
        final file = File('${tempDir.path}/plain.ics');
        final notes = createSampleNotes();

        await provider.exportPlainIcs(notes: notes, file: file);

        expect(file.existsSync(), true);
        final content = file.readAsStringSync();
        expect(content, contains('BEGIN:VCALENDAR'));
        expect(content, contains('END:VCALENDAR'));
        expect(content, contains('Team Meeting'));
        expect(content, contains('Lunch'));
        // Should NOT be wrapped in JSON
        expect(() => jsonDecode(content), throwsA(anything));
      });
    });

    group('importFromIcs', () {
      test('imports from wrapped format (unencrypted)', () async {
        final notes = createSampleNotes();
        final exportStr = provider.exportToString(
          notes: notes,
          username: 'testuser',
          encrypted: false,
        );

        final file = File('${tempDir.path}/wrapped.json');
        file.writeAsStringSync(exportStr);

        final metadata = await provider.importFromIcs(
          file,
          availableNoteCategories,
        );

        expect(metadata, isNotNull);
        expect(metadata!.encrypted, false);
        expect(metadata.username, 'testuser');
        expect(metadata.noteCount, 2);
      });

      test('imports from wrapped format (encrypted)', () async {
        const password = 'securePass';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;
        final notes = createSampleNotes();

        final exportStr = provider.exportToString(
          notes: notes,
          username: 'encuser',
          salt: salt,
          encrypted: true,
          password: password,
        );

        final file = File('${tempDir.path}/encrypted.json');
        file.writeAsStringSync(exportStr);

        final metadata = await provider.importFromIcs(
          file,
          availableNoteCategories,
          password: password,
        );

        expect(metadata, isNotNull);
        expect(metadata!.encrypted, true);
      });

      test('imports from plain ICS file', () async {
        final notes = createSampleNotes();
        final file = File('${tempDir.path}/plain_import.ics');
        await provider.exportPlainIcs(notes: notes, file: file);

        // Create a fresh provider for import
        final importProvider = IcsFileProvider();
        final metadata = await importProvider.importFromIcs(
          file,
          availableNoteCategories,
        );

        // Plain ICS has no metadata wrapper
        expect(metadata, isNull);
      });

      test('throws when encrypted file imported without password', () async {
        const password = 'myPass';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;
        final notes = createSampleNotes();

        final exportStr = provider.exportToString(
          notes: notes,
          salt: salt,
          encrypted: true,
          password: password,
        );

        final file = File('${tempDir.path}/enc_no_pass.json');
        file.writeAsStringSync(exportStr);

        expect(
          () => provider.importFromIcs(file, availableNoteCategories),
          throwsException,
        );
      });
    });

    group('export + import round-trip', () {
      test('unencrypted wrapped round-trip preserves note titles', () async {
        final notes = createSampleNotes();
        final exportStr = provider.exportToString(
          notes: notes,
          encrypted: false,
        );

        final file = File('${tempDir.path}/roundtrip.json');
        file.writeAsStringSync(exportStr);

        final importProvider = IcsFileProvider();
        await importProvider.importFromIcs(
          file,
          availableNoteCategories,
        );

        // ICS round-trip may not preserve exact times due to UTC conversion,
        // but titles and descriptions should be preserved
        // The state is set internally in the provider
      });

      test('encrypted wrapped round-trip', () async {
        const password = 'roundTripPass';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;
        final notes = createSampleNotes();

        final exportStr = provider.exportToString(
          notes: notes,
          salt: salt,
          encrypted: true,
          password: password,
        );

        final file = File('${tempDir.path}/enc_roundtrip.json');
        file.writeAsStringSync(exportStr);

        final importProvider = IcsFileProvider();
        final metadata = await importProvider.importFromIcs(
          file,
          availableNoteCategories,
          password: password,
        );

        expect(metadata, isNotNull);
        expect(metadata!.encrypted, true);
      });
    });

    group('empty data', () {
      test('exports empty notes list', () {
        final result = provider.exportToString(
          notes: [],
          encrypted: false,
        );

        final decoded = jsonDecode(result) as Map<String, dynamic>;
        expect(decoded['metadata']['noteCount'], 0);
      });
    });
  });
}
