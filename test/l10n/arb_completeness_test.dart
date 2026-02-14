import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Tests to verify that all ARB translation files have complete coverage
/// of all translation keys from the template (English) file.
void main() {
  group('ARB Completeness', () {
    late Map<String, dynamic> enArb;
    late Map<String, dynamic> deArb;

    setUpAll(() {
      // Load ARB files
      final enFile = File('lib/l10n/app_en.arb');
      final deFile = File('lib/l10n/app_de.arb');

      expect(enFile.existsSync(), isTrue,
          reason: 'English ARB file not found at lib/l10n/app_en.arb');
      expect(deFile.existsSync(), isTrue,
          reason: 'German ARB file not found at lib/l10n/app_de.arb');

      enArb = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
      deArb = json.decode(deFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('all English keys exist in German translation', () {
      // Get all non-metadata keys from English ARB
      final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();

      // Get all non-metadata keys from German ARB
      final deKeys = deArb.keys.where((k) => !k.startsWith('@')).toSet();

      // Find missing keys
      final missingKeys = enKeys.difference(deKeys);

      expect(missingKeys, isEmpty,
          reason:
              'German ARB is missing the following keys: ${missingKeys.join(", ")}');
    });

    test('no extra keys in German translation that are not in English', () {
      final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();
      final deKeys = deArb.keys.where((k) => !k.startsWith('@')).toSet();

      // Find extra/orphaned keys
      final extraKeys = deKeys.difference(enKeys);

      expect(extraKeys, isEmpty,
          reason:
              'German ARB has extra keys not in English template: ${extraKeys.join(", ")}');
    });

    test('no ARB values are empty strings', () {
      final emptyEnKeys = <String>[];
      final emptyDeKeys = <String>[];

      // Check English
      for (final entry in enArb.entries) {
        if (!entry.key.startsWith('@') && entry.value is String) {
          if ((entry.value as String).trim().isEmpty) {
            emptyEnKeys.add(entry.key);
          }
        }
      }

      // Check German
      for (final entry in deArb.entries) {
        if (!entry.key.startsWith('@') && entry.value is String) {
          if ((entry.value as String).trim().isEmpty) {
            emptyDeKeys.add(entry.key);
          }
        }
      }

      expect(emptyEnKeys, isEmpty,
          reason: 'English ARB has empty values for keys: ${emptyEnKeys.join(", ")}');
      expect(emptyDeKeys, isEmpty,
          reason: 'German ARB has empty values for keys: ${emptyDeKeys.join(", ")}');
    });

    test('metadata entries reference existing keys', () {
      final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();
      // Filter out @@locale which is a special marker, not regular metadata
      final metadataKeys = enArb.keys
          .where((k) => k.startsWith('@') && !k.startsWith('@@'))
          .map((k) => k.substring(1))
          .toSet();

      // Find metadata entries that don't have corresponding keys
      final orphanedMetadata = metadataKeys.difference(enKeys);

      expect(orphanedMetadata, isEmpty,
          reason:
              'English ARB has metadata (@-entries) without corresponding keys: ${orphanedMetadata.map((k) => "@$k").join(", ")}');
    });

    test('both ARB files have the same number of translation keys', () {
      final enKeyCount = enArb.keys.where((k) => !k.startsWith('@')).length;
      final deKeyCount = deArb.keys.where((k) => !k.startsWith('@')).length;

      expect(deKeyCount, equals(enKeyCount),
          reason:
              'Translation key count mismatch: English has $enKeyCount keys, German has $deKeyCount keys');
    });

    test('locale markers are correct', () {
      expect(enArb['@@locale'], equals('en'),
          reason: 'English ARB should have @@locale set to "en"');
      expect(deArb['@@locale'], equals('de'),
          reason: 'German ARB should have @@locale set to "de"');
    });
  });
}
