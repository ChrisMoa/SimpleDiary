import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/features/day_rating/data/models/day_rating.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:day_tracker/features/synchronization/data/models/export_data.dart';
import 'package:day_tracker/features/synchronization/data/services/zip_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ZipExportService zipService;

  setUp(() {
    zipService = ZipExportService();
  });

  List<DiaryDay> createSampleDiaryDays() {
    return [
      DiaryDay(
        day: DateTime(2024, 3, 10),
        ratings: [
          DayRating(dayRating: DayRatings.social, score: 4),
          DayRating(dayRating: DayRatings.productivity, score: 3),
        ],
      ),
      DiaryDay(
        day: DateTime(2024, 3, 11),
        ratings: [
          DayRating(dayRating: DayRatings.sport, score: 5),
        ],
      ),
    ];
  }

  group('ZipExportService', () {
    group('createZipExport', () {
      test('creates valid ZIP with manifest.json', () {
        final diaryDays = createSampleDiaryDays();
        final zipBytes = zipService.createZipExport(
          diaryDays: diaryDays,
          attachments: [],
          encrypted: false,
        );

        expect(zipBytes, isNotEmpty);

        // Verify it's a valid ZIP
        final archive = ZipDecoder().decodeBytes(zipBytes);
        final manifest = archive.findFile('manifest.json');
        expect(manifest, isNotNull);

        // Verify manifest content
        final manifestJson =
            utf8.decode(manifest!.content as List<int>);
        final manifestMap =
            json.decode(manifestJson) as Map<String, dynamic>;
        expect(manifestMap['version'], '1.1');
        expect(manifestMap['metadata'], isA<Map>());
        expect(manifestMap['data'], isA<String>());
        expect(manifestMap['attachments'], isA<List>());
      });

      test('creates ZIP with empty attachments list', () {
        final zipBytes = zipService.createZipExport(
          diaryDays: createSampleDiaryDays(),
          attachments: [],
          encrypted: false,
        );

        final archive = ZipDecoder().decodeBytes(zipBytes);
        final manifest = archive.findFile('manifest.json');
        final manifestMap = json.decode(
            utf8.decode(manifest!.content as List<int>)) as Map<String, dynamic>;
        final attachments = manifestMap['attachments'] as List;
        expect(attachments, isEmpty);
      });

      test('includes attachment metadata with zipPath null when file missing',
          () {
        final attachment = NoteAttachment(
          id: 'att-1',
          noteId: 'note-1',
          filePath: '/nonexistent/path/image.jpg',
          createdAt: DateTime(2024, 3, 10),
          fileSize: 1024,
        );

        final zipBytes = zipService.createZipExport(
          diaryDays: createSampleDiaryDays(),
          attachments: [attachment],
          encrypted: false,
        );

        final archive = ZipDecoder().decodeBytes(zipBytes);
        final manifest = archive.findFile('manifest.json');
        final manifestMap = json.decode(
            utf8.decode(manifest!.content as List<int>)) as Map<String, dynamic>;
        final attachments = manifestMap['attachments'] as List;

        expect(attachments.length, 1);
        expect(attachments[0]['zipPath'], isNull);
        expect(attachments[0]['id'], 'att-1');
        expect(attachments[0]['noteId'], 'note-1');
      });

      test('includes image files in ZIP when they exist', () {
        // Create a temp image file
        final tempDir = Directory.systemTemp.createTempSync('zip_test_');
        final tempFile = File('${tempDir.path}/test_image.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

        final attachment = NoteAttachment(
          id: 'att-1',
          noteId: 'note-1',
          filePath: tempFile.path,
          createdAt: DateTime(2024, 3, 10),
          fileSize: 6,
        );

        try {
          final zipBytes = zipService.createZipExport(
            diaryDays: createSampleDiaryDays(),
            attachments: [attachment],
            encrypted: false,
          );

          final archive = ZipDecoder().decodeBytes(zipBytes);

          // Check that image file exists in the archive
          final imageFile = archive.findFile('images/note-1/att-1.jpg');
          expect(imageFile, isNotNull);
          expect((imageFile!.content as List<int>).length, 6);

          // Check manifest references the zipPath
          final manifest = archive.findFile('manifest.json');
          final manifestMap = json.decode(
              utf8.decode(manifest!.content as List<int>)) as Map<String, dynamic>;
          final attachments = manifestMap['attachments'] as List;
          expect(attachments[0]['zipPath'], 'images/note-1/att-1.jpg');
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('creates encrypted manifest', () {
        const password = 'testPassword123';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;

        final zipBytes = zipService.createZipExport(
          diaryDays: createSampleDiaryDays(),
          attachments: [],
          encrypted: true,
          password: password,
          salt: salt,
        );

        final archive = ZipDecoder().decodeBytes(zipBytes);
        final manifest = archive.findFile('manifest.json');
        final manifestMap = json.decode(
            utf8.decode(manifest!.content as List<int>)) as Map<String, dynamic>;

        expect(manifestMap['metadata']['encrypted'], true);
        expect(manifestMap['metadata']['salt'], salt);

        // Data should be an encrypted base64 string, not a JSON array
        final dataField = manifestMap['data'] as String;
        expect(() => json.decode(dataField), throwsFormatException);

        // Should be decryptable
        final encryptionKey =
            PasswordAuthService.getDatabaseEncryptionKey(password, salt);
        final decryptor = AesEncryptor(encryptionKey: encryptionKey);
        final decrypted = decryptor.decryptStringFromBase64(dataField);
        final parsed = json.decode(decrypted) as List;
        expect(parsed.length, 2);
      });

      test('sets version to 1.1', () {
        final zipBytes = zipService.createZipExport(
          diaryDays: createSampleDiaryDays(),
          attachments: [],
          encrypted: false,
        );

        final archive = ZipDecoder().decodeBytes(zipBytes);
        final manifest = archive.findFile('manifest.json');
        final manifestMap = json.decode(
            utf8.decode(manifest!.content as List<int>)) as Map<String, dynamic>;
        expect(manifestMap['version'], '1.1');
      });
    });

    group('extractZipImport', () {
      test('extracts unencrypted ZIP and restores images', () {
        // Create a temp dir for image output
        final tempDir = Directory.systemTemp.createTempSync('zip_import_');
        final sourceDir = Directory.systemTemp.createTempSync('zip_source_');
        final sourceFile = File('${sourceDir.path}/photo.jpg');
        sourceFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        final attachment = NoteAttachment(
          id: 'att-1',
          noteId: 'note-1',
          filePath: sourceFile.path,
          createdAt: DateTime(2024, 3, 10),
          fileSize: 4,
        );

        try {
          // Create ZIP
          final zipBytes = zipService.createZipExport(
            diaryDays: createSampleDiaryDays(),
            attachments: [attachment],
            encrypted: false,
          );

          // Write ZIP to temp file
          final zipFile = File('${tempDir.path}/test.zip');
          zipFile.writeAsBytesSync(zipBytes);

          // Extract
          final targetImageDir = '${tempDir.path}/images';
          final result = zipService.extractZipImport(
            zipFile: zipFile,
            targetImageDir: targetImageDir,
          );

          expect(result.diaryDays.length, 2);
          expect(result.attachments.length, 1);
          expect(result.metadata, isNotNull);
          expect(result.metadata!.encrypted, false);

          // Verify restored image file exists
          final restoredPath = result.attachments[0].filePath;
          expect(File(restoredPath).existsSync(), true);
          expect(File(restoredPath).readAsBytesSync(),
              [0xFF, 0xD8, 0xFF, 0xE0]);
        } finally {
          tempDir.deleteSync(recursive: true);
          sourceDir.deleteSync(recursive: true);
        }
      });

      test('extracts encrypted ZIP with correct password', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_enc_');
        const password = 'securePass!';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;

        try {
          final zipBytes = zipService.createZipExport(
            diaryDays: createSampleDiaryDays(),
            attachments: [],
            encrypted: true,
            password: password,
            salt: salt,
          );

          final zipFile = File('${tempDir.path}/encrypted.zip');
          zipFile.writeAsBytesSync(zipBytes);

          final result = zipService.extractZipImport(
            zipFile: zipFile,
            targetImageDir: '${tempDir.path}/images',
            password: password,
          );

          expect(result.diaryDays.length, 2);
          expect(result.metadata!.encrypted, true);
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('throws on missing manifest.json', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_no_manifest_');

        try {
          // Create a ZIP without manifest.json
          final archive = Archive();
          final dummyBytes = utf8.encode('hello');
          archive.addFile(ArchiveFile('dummy.txt', dummyBytes.length, dummyBytes));
          final zipBytes = ZipEncoder().encode(archive);

          final zipFile = File('${tempDir.path}/no_manifest.zip');
          zipFile.writeAsBytesSync(zipBytes);

          expect(
            () => zipService.extractZipImport(
              zipFile: zipFile,
              targetImageDir: '${tempDir.path}/images',
            ),
            throwsException,
          );
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('skips missing images in ZIP gracefully', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_skip_');

        try {
          // Create a manifest that references images not in the ZIP
          final manifestMap = {
            'version': '1.1',
            'metadata': {
              'username': null,
              'salt': null,
              'exportDate': DateTime.now().toIso8601String(),
              'encrypted': false,
            },
            'data': jsonEncode([]),
            'attachments': [
              {
                'id': 'att-1',
                'noteId': 'note-1',
                'filePath': '/fake/path.jpg',
                'createdAt': '10.03.2024 00:00',
                'fileSize': 100,
                'zipPath': 'images/note-1/att-1.jpg', // not in archive
              },
            ],
          };

          final archive = Archive();
          final manifestBytes = utf8.encode(jsonEncode(manifestMap));
          archive.addFile(
              ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
          final zipBytes = ZipEncoder().encode(archive);

          final zipFile = File('${tempDir.path}/missing_images.zip');
          zipFile.writeAsBytesSync(zipBytes);

          final result = zipService.extractZipImport(
            zipFile: zipFile,
            targetImageDir: '${tempDir.path}/images',
          );

          // Should skip the missing image and return empty attachments
          expect(result.attachments, isEmpty);
          expect(result.diaryDays, isEmpty);
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('handles ZIP with no attachments key (backward compat)', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_compat_');

        try {
          final diaryDays = createSampleDiaryDays();
          final manifestMap = {
            'version': '1.0',
            'metadata': {
              'username': null,
              'salt': null,
              'exportDate': DateTime.now().toIso8601String(),
              'encrypted': false,
            },
            'data': jsonEncode(diaryDays.map((d) => d.toMap()).toList()),
            // No 'attachments' key
          };

          final archive = Archive();
          final manifestBytes = utf8.encode(jsonEncode(manifestMap));
          archive.addFile(
              ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
          final zipBytes = ZipEncoder().encode(archive);

          final zipFile = File('${tempDir.path}/no_attachments.zip');
          zipFile.writeAsBytesSync(zipBytes);

          final result = zipService.extractZipImport(
            zipFile: zipFile,
            targetImageDir: '${tempDir.path}/images',
          );

          expect(result.diaryDays.length, 2);
          expect(result.attachments, isEmpty);
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });
    });

    group('createZipExport → extractZipImport round-trip', () {
      test('round-trip preserves diary days and attachment metadata', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_rt_');
        final sourceDir = Directory.systemTemp.createTempSync('zip_rt_src_');

        // Create test image files
        final img1 = File('${sourceDir.path}/img1.jpg');
        img1.writeAsBytesSync(List.generate(100, (i) => i % 256));
        final img2 = File('${sourceDir.path}/img2.png');
        img2.writeAsBytesSync(List.generate(200, (i) => (i * 3) % 256));

        final attachments = [
          NoteAttachment(
            id: 'att-1',
            noteId: 'note-1',
            filePath: img1.path,
            createdAt: DateTime(2024, 3, 10, 14, 30),
            fileSize: 100,
          ),
          NoteAttachment(
            id: 'att-2',
            noteId: 'note-1',
            filePath: img2.path,
            createdAt: DateTime(2024, 3, 10, 15, 0),
            fileSize: 200,
          ),
        ];

        try {
          final diaryDays = createSampleDiaryDays();

          // Export
          final zipBytes = zipService.createZipExport(
            diaryDays: diaryDays,
            attachments: attachments,
            encrypted: false,
            username: 'roundtrip_user',
          );

          final zipFile = File('${tempDir.path}/roundtrip.zip');
          zipFile.writeAsBytesSync(zipBytes);

          // Import
          final result = zipService.extractZipImport(
            zipFile: zipFile,
            targetImageDir: '${tempDir.path}/images',
          );

          // Verify diary days
          expect(result.diaryDays.length, 2);

          // Verify attachments
          expect(result.attachments.length, 2);
          expect(result.attachments[0].id, 'att-1');
          expect(result.attachments[0].noteId, 'note-1');
          expect(result.attachments[1].id, 'att-2');

          // Verify image files were written
          expect(File(result.attachments[0].filePath).existsSync(), true);
          expect(File(result.attachments[1].filePath).existsSync(), true);
          expect(File(result.attachments[0].filePath).readAsBytesSync().length,
              100);
          expect(File(result.attachments[1].filePath).readAsBytesSync().length,
              200);

          // Verify metadata
          expect(result.metadata!.username, 'roundtrip_user');
        } finally {
          tempDir.deleteSync(recursive: true);
          sourceDir.deleteSync(recursive: true);
        }
      });

      test('encrypted round-trip preserves data', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_rt_enc_');

        const password = 'roundTripPassword!';
        final hashResult = PasswordAuthService.hashPassword(password);
        final salt = hashResult['salt']!;

        try {
          final diaryDays = createSampleDiaryDays();

          final zipBytes = zipService.createZipExport(
            diaryDays: diaryDays,
            attachments: [],
            encrypted: true,
            password: password,
            salt: salt,
            username: 'encrypted_user',
          );

          final zipFile = File('${tempDir.path}/enc_roundtrip.zip');
          zipFile.writeAsBytesSync(zipBytes);

          final result = zipService.extractZipImport(
            zipFile: zipFile,
            targetImageDir: '${tempDir.path}/images',
            password: password,
          );

          expect(result.diaryDays.length, 2);
          expect(result.metadata!.encrypted, true);
          expect(result.metadata!.username, 'encrypted_user');
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });
    });

    group('isZipFile', () {
      test('returns true for valid ZIP file', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_detect_');

        try {
          final archive = Archive();
          final bytes = utf8.encode('test');
          archive.addFile(ArchiveFile('test.txt', bytes.length, bytes));
          final zipBytes = ZipEncoder().encode(archive);

          final zipFile = File('${tempDir.path}/test.zip');
          zipFile.writeAsBytesSync(zipBytes);

          expect(ZipExportService.isZipFile(zipFile), true);
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('returns false for non-ZIP file', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_detect_no_');

        try {
          final file = File('${tempDir.path}/test.json');
          file.writeAsStringSync('{"key": "value"}');

          expect(ZipExportService.isZipFile(file), false);
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('returns false for nonexistent file', () {
        final file = File('/nonexistent/path/file.zip');
        expect(ZipExportService.isZipFile(file), false);
      });

      test('returns false for empty file', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_detect_empty_');

        try {
          final file = File('${tempDir.path}/empty.zip');
          file.writeAsBytesSync([]);

          expect(ZipExportService.isZipFile(file), false);
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });
    });

    group('ZipImportResult', () {
      test('stores all fields', () {
        final result = ZipImportResult(
          diaryDays: createSampleDiaryDays(),
          attachments: [],
          metadata: ExportMetadata(
            exportDate: '2024-03-15',
            encrypted: false,
          ),
        );

        expect(result.diaryDays.length, 2);
        expect(result.attachments, isEmpty);
        expect(result.metadata, isNotNull);
        expect(result.metadata!.encrypted, false);
      });

      test('allows null metadata', () {
        final result = ZipImportResult(
          diaryDays: [],
          attachments: [],
        );

        expect(result.metadata, isNull);
      });
    });

    group('ZIP structure verification', () {
      test('ZIP contains expected directory structure', () {
        final tempDir = Directory.systemTemp.createTempSync('zip_struct_');
        final img = File('${tempDir.path}/test.jpg');
        img.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        try {
          final zipBytes = zipService.createZipExport(
            diaryDays: createSampleDiaryDays(),
            attachments: [
              NoteAttachment(
                id: 'a1',
                noteId: 'n1',
                filePath: img.path,
                createdAt: DateTime(2024, 1, 1),
                fileSize: 4,
              ),
              NoteAttachment(
                id: 'a2',
                noteId: 'n2',
                filePath: img.path,
                createdAt: DateTime(2024, 1, 2),
                fileSize: 4,
              ),
            ],
            encrypted: false,
          );

          final archive = ZipDecoder().decodeBytes(zipBytes);
          final fileNames =
              archive.files.map((f) => f.name).toList()..sort();

          expect(fileNames, contains('manifest.json'));
          expect(fileNames, contains('images/n1/a1.jpg'));
          expect(fileNames, contains('images/n2/a2.jpg'));
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });
    });
  });
}
