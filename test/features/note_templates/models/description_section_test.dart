import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DescriptionSection', () {
    group('construction', () {
      test('creates with required title', () {
        const section = DescriptionSection(title: 'Warm-up');
        expect(section.title, 'Warm-up');
        expect(section.hint, ''); // default
      });

      test('creates with title and hint', () {
        const section =
            DescriptionSection(title: 'Exercise', hint: 'Do 3 sets');
        expect(section.title, 'Exercise');
        expect(section.hint, 'Do 3 sets');
      });
    });

    group('toMap / fromMap', () {
      test('round-trip preserves data', () {
        const original =
            DescriptionSection(title: 'Warm-up', hint: '10 minutes');
        final map = original.toMap();
        final restored = DescriptionSection.fromMap(map);

        expect(restored.title, original.title);
        expect(restored.hint, original.hint);
      });

      test('map contains correct keys', () {
        const section = DescriptionSection(title: 'Test', hint: 'A hint');
        final map = section.toMap();

        expect(map, contains('title'));
        expect(map, contains('hint'));
        expect(map['title'], 'Test');
        expect(map['hint'], 'A hint');
      });

      test('fromMap handles missing title gracefully', () {
        final section = DescriptionSection.fromMap({});
        expect(section.title, '');
        expect(section.hint, '');
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        const original =
            DescriptionSection(title: 'Original', hint: 'Original hint');
        final copy = original.copyWith(title: 'Updated');

        expect(copy.title, 'Updated');
        expect(copy.hint, 'Original hint');
      });

      test('can update all fields', () {
        const original =
            DescriptionSection(title: 'Original', hint: 'Original hint');
        final copy = original.copyWith(title: 'New', hint: 'New hint');

        expect(copy.title, 'New');
        expect(copy.hint, 'New hint');
      });
    });

    group('encode / decode', () {
      test('round-trip for list of sections', () {
        final sections = [
          const DescriptionSection(title: 'Warm-up', hint: '10 min'),
          const DescriptionSection(title: 'Main Set', hint: 'Exercises'),
          const DescriptionSection(title: 'Cool-down', hint: 'Stretch'),
        ];

        final encoded = DescriptionSection.encode(sections);
        expect(encoded, isNotEmpty);

        final decoded = DescriptionSection.decode(encoded);
        expect(decoded.length, 3);
        expect(decoded[0].title, 'Warm-up');
        expect(decoded[0].hint, '10 min');
        expect(decoded[1].title, 'Main Set');
        expect(decoded[2].title, 'Cool-down');
      });

      test('encode empty list returns empty string', () {
        final encoded = DescriptionSection.encode([]);
        expect(encoded, '');
      });

      test('decode empty string returns empty list', () {
        final decoded = DescriptionSection.decode('');
        expect(decoded, isEmpty);
      });

      test('decode invalid JSON returns empty list', () {
        final decoded = DescriptionSection.decode('not valid json');
        expect(decoded, isEmpty);
      });

      test('encode single section', () {
        final sections = [
          const DescriptionSection(title: 'Only One'),
        ];
        final encoded = DescriptionSection.encode(sections);
        final decoded = DescriptionSection.decode(encoded);
        expect(decoded.length, 1);
        expect(decoded[0].title, 'Only One');
      });
    });
  });
}
