import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Tests to verify that ARB files are well-formed and have valid syntax
void main() {
  group('ARB Validity', () {
    late Map<String, dynamic> enArb;
    late Map<String, dynamic> deArb;

    setUpAll(() {
      final enFile = File('lib/l10n/app_en.arb');
      final deFile = File('lib/l10n/app_de.arb');

      expect(enFile.existsSync(), isTrue);
      expect(deFile.existsSync(), isTrue);

      enArb = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
      deArb = json.decode(deFile.readAsStringSync()) as Map<String, dynamic>;
    });

    group('JSON Syntax', () {
      test('English ARB is valid JSON', () {
        final enFile = File('lib/l10n/app_en.arb');
        expect(() => json.decode(enFile.readAsStringSync()), returnsNormally);
      });

      test('German ARB is valid JSON', () {
        final deFile = File('lib/l10n/app_de.arb');
        expect(() => json.decode(deFile.readAsStringSync()), returnsNormally);
      });
    });

    group('Placeholder Consistency', () {
      test('placeholders in messages match their metadata definitions', () {
        // Check English ARB
        _validatePlaceholders(enArb, 'English');
        // Check German ARB
        _validatePlaceholders(deArb, 'German');
      });
    });

    group('Value Types', () {
      test('all non-metadata values are strings', () {
        // Check English
        for (final entry in enArb.entries) {
          if (!entry.key.startsWith('@') && entry.key != '@@locale') {
            expect(entry.value, isA<String>(),
                reason:
                    'English ARB key "${entry.key}" has non-string value: ${entry.value}');
          }
        }

        // Check German
        for (final entry in deArb.entries) {
          if (!entry.key.startsWith('@') && entry.key != '@@locale') {
            expect(entry.value, isA<String>(),
                reason:
                    'German ARB key "${entry.key}" has non-string value: ${entry.value}');
          }
        }
      });
    });

    group('ICU Message Format', () {
      test('placeholder syntax is valid', () {
        final placeholderPattern = RegExp(r'\{(\w+)\}');

        // Validate English
        for (final entry in enArb.entries) {
          if (!entry.key.startsWith('@') &&
              entry.key != '@@locale' &&
              entry.value is String) {
            final value = entry.value as String;
            final matches = placeholderPattern.allMatches(value);

            for (final match in matches) {
              final placeholder = match.group(1)!;
              // Verify metadata exists if there are placeholders
              if (matches.isNotEmpty) {
                final metadataKey = '@${entry.key}';
                if (enArb.containsKey(metadataKey)) {
                  final metadata = enArb[metadataKey] as Map<String, dynamic>?;
                  if (metadata != null && metadata.containsKey('placeholders')) {
                    final placeholders =
                        metadata['placeholders'] as Map<String, dynamic>;
                    expect(placeholders.containsKey(placeholder), isTrue,
                        reason:
                            'English key "${entry.key}" uses placeholder {$placeholder} but it is not defined in metadata');
                  }
                }
              }
            }
          }
        }
      });

      test('no unclosed placeholders', () {
        void checkUnbalanced(Map<String, dynamic> arb, String language) {
          for (final entry in arb.entries) {
            if (!entry.key.startsWith('@') &&
                entry.key != '@@locale' &&
                entry.value is String) {
              final value = entry.value as String;

              // Count opening and closing braces
              final openCount = value.split('{').length - 1;
              final closeCount = value.split('}').length - 1;

              expect(openCount, equals(closeCount),
                  reason:
                      '$language key "${entry.key}" has unbalanced braces: $value');
            }
          }
        }

        checkUnbalanced(enArb, 'English');
        checkUnbalanced(deArb, 'German');
      });
    });
  });
}

/// Helper function to validate that placeholders in messages match their metadata
void _validatePlaceholders(Map<String, dynamic> arb, String language) {
  for (final entry in arb.entries) {
    // Skip metadata entries and locale marker
    if (entry.key.startsWith('@') || entry.key == '@@locale') {
      continue;
    }

    final messageKey = entry.key;
    final messageValue = entry.value as String;
    final metadataKey = '@$messageKey';

    // Extract placeholders from message using regex
    final placeholderPattern = RegExp(r'\{(\w+)\}');
    final placeholdersInMessage =
        placeholderPattern.allMatches(messageValue).map((m) => m.group(1)!).toSet();

    // If message has placeholders, check metadata
    if (placeholdersInMessage.isNotEmpty && arb.containsKey(metadataKey)) {
      final metadata = arb[metadataKey] as Map<String, dynamic>?;

      if (metadata != null && metadata.containsKey('placeholders')) {
        final placeholdersMeta = metadata['placeholders'] as Map<String, dynamic>;
        final definedPlaceholders = placeholdersMeta.keys.toSet();

        // Verify all message placeholders are defined in metadata
        for (final placeholder in placeholdersInMessage) {
          expect(definedPlaceholders.contains(placeholder), isTrue,
              reason:
                  '$language key "$messageKey" uses placeholder {$placeholder} not defined in metadata');
        }

        // Verify all metadata placeholders are used in message
        for (final placeholder in definedPlaceholders) {
          expect(placeholdersInMessage.contains(placeholder), isTrue,
              reason:
                  '$language key "$messageKey" defines unused placeholder {$placeholder} in metadata');
        }
      }
    }
  }
}
