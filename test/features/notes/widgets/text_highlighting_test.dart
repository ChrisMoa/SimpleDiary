import 'package:day_tracker/features/notes/presentation/widgets/note_search_result_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildHighlightSpans', () {
    final baseStyle = const TextStyle(fontSize: 14);
    final highlightColor = Colors.yellow;
    final highlightTextColor = Colors.black;

    test('empty query returns single span with full text', () {
      final spans = buildHighlightSpans(
        'Hello World',
        '',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 1);
      expect(spans[0].text, 'Hello World');
      expect(spans[0].style, baseStyle);
    });

    test('matching text produces highlighted span', () {
      final spans = buildHighlightSpans(
        'Hello World',
        'World',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 2);
      // First span: non-matching part
      expect(spans[0].text, 'Hello ');
      expect(spans[0].style, baseStyle);
      // Second span: highlighted match
      expect(spans[1].text, 'World');
      expect(spans[1].style!.backgroundColor, highlightColor);
      expect(spans[1].style!.fontWeight, FontWeight.bold);
    });

    test('match at start of text', () {
      final spans = buildHighlightSpans(
        'Hello World',
        'Hello',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 2);
      expect(spans[0].text, 'Hello');
      expect(spans[0].style!.backgroundColor, highlightColor);
      expect(spans[1].text, ' World');
      expect(spans[1].style, baseStyle);
    });

    test('match at end of text', () {
      final spans = buildHighlightSpans(
        'Hello World',
        'World',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 2);
      expect(spans[0].text, 'Hello ');
      expect(spans[1].text, 'World');
      expect(spans[1].style!.backgroundColor, highlightColor);
    });

    test('multiple matches produce multiple highlighted spans', () {
      final spans = buildHighlightSpans(
        'test and test again',
        'test',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 4);
      // "test" + " and " + "test" + " again"
      expect(spans[0].text, 'test');
      expect(spans[0].style!.backgroundColor, highlightColor);
      expect(spans[1].text, ' and ');
      expect(spans[1].style, baseStyle);
      expect(spans[2].text, 'test');
      expect(spans[2].style!.backgroundColor, highlightColor);
      expect(spans[3].text, ' again');
      expect(spans[3].style, baseStyle);
    });

    test('consecutive matches', () {
      final spans = buildHighlightSpans(
        'aaa',
        'a',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 3);
      expect(spans.every((s) => s.text == 'a'), true);
      expect(spans.every((s) => s.style!.backgroundColor == highlightColor), true);
    });

    test('case-insensitive matching', () {
      final spans = buildHighlightSpans(
        'Hello WORLD',
        'world',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 2);
      expect(spans[0].text, 'Hello ');
      expect(spans[1].text, 'WORLD'); // Original case preserved
      expect(spans[1].style!.backgroundColor, highlightColor);
    });

    test('case-insensitive with mixed case', () {
      final spans = buildHighlightSpans(
        'The Meeting is about meetings',
        'MEETING',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 5);
      expect(spans[0].text, 'The ');
      expect(spans[1].text, 'Meeting'); // Original case preserved
      expect(spans[1].style!.backgroundColor, highlightColor);
      expect(spans[2].text, ' is about ');
      expect(spans[3].text, 'meeting'); // Original case preserved (matches "meeting" in "meetings")
      expect(spans[3].style!.backgroundColor, highlightColor);
      expect(spans[4].text, 's'); // Remaining text after match
    });

    test('no match returns single span with full text', () {
      final spans = buildHighlightSpans(
        'Hello World',
        'xyz',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 1);
      expect(spans[0].text, 'Hello World');
      expect(spans[0].style, baseStyle);
    });

    test('partial word match', () {
      final spans = buildHighlightSpans(
        'Planning session',
        'plan',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 2);
      expect(spans[0].text, 'Plan'); // Matches beginning of "Planning"
      expect(spans[0].style!.backgroundColor, highlightColor);
      expect(spans[1].text, 'ning session');
    });

    test('query longer than text returns single span', () {
      final spans = buildHighlightSpans(
        'Hi',
        'Hello',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 1);
      expect(spans[0].text, 'Hi');
      expect(spans[0].style, baseStyle);
    });

    test('empty text with query returns empty result', () {
      final spans = buildHighlightSpans(
        '',
        'test',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans, isEmpty);
    });

    test('empty text with empty query returns single empty span', () {
      final spans = buildHighlightSpans(
        '',
        '',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 1);
      expect(spans[0].text, '');
    });

    test('special characters are matched literally', () {
      final spans = buildHighlightSpans(
        'Price: \$100',
        '\$',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 3);
      expect(spans[0].text, 'Price: ');
      expect(spans[1].text, '\$');
      expect(spans[1].style!.backgroundColor, highlightColor);
      expect(spans[2].text, '100'); // Remaining text after match
    });

    test('whitespace is matched', () {
      final spans = buildHighlightSpans(
        'Hello   World',
        '   ',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 3);
      expect(spans[0].text, 'Hello');
      expect(spans[1].text, '   ');
      expect(spans[1].style!.backgroundColor, highlightColor);
      expect(spans[2].text, 'World'); // Remaining text after match
    });

    test('overlapping matches handled correctly', () {
      // "aaaa" with query "aa" should match twice: "aa" at 0 and "aa" at 2
      final spans = buildHighlightSpans(
        'aaaa',
        'aa',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 2);
      expect(spans[0].text, 'aa');
      expect(spans[0].style!.backgroundColor, highlightColor);
      expect(spans[1].text, 'aa');
      expect(spans[1].style!.backgroundColor, highlightColor);
    });

    test('single character match', () {
      final spans = buildHighlightSpans(
        'a b c',
        'b',
        baseStyle,
        highlightColor,
        highlightTextColor,      );

      expect(spans.length, 3);
      expect(spans[0].text, 'a ');
      expect(spans[1].text, 'b');
      expect(spans[1].style!.backgroundColor, highlightColor);
      expect(spans[2].text, ' c');
    });

    test('highlighted span preserves other style properties', () {
      final customStyle = const TextStyle(
        fontSize: 20,
        fontStyle: FontStyle.italic,
      );

      final spans = buildHighlightSpans(
        'Hello World',
        'World',
        customStyle,
        highlightColor,
        highlightTextColor,      );

      final highlightedSpan = spans[1];
      expect(highlightedSpan.style!.fontSize, 20);
      expect(highlightedSpan.style!.fontStyle, FontStyle.italic);
      expect(highlightedSpan.style!.backgroundColor, highlightColor);
      expect(highlightedSpan.style!.fontWeight, FontWeight.bold);
    });
  });
}
