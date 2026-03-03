import 'package:day_tracker/features/day_rating/data/models/enhanced_day_rating.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/mood_quadrant_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {
    initTestSettingsContainer();
  });

  MoodPosition createPosition({
    double valence = 0.0,
    double arousal = 0.0,
  }) {
    return MoodPosition(
      valence: valence,
      arousal: arousal,
      timestamp: DateTime(2024, 3, 15, 10, 0),
    );
  }

  group('MoodQuadrantDisplayWidget', () {
    group('normal display', () {
      testWidgets('renders with header and mood label', (tester) async {
        final position = createPosition(valence: 0.7, arousal: 0.8);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MoodQuadrantDisplayWidget(position: position),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Header icon and title
        expect(find.byIcon(Icons.mood), findsOneWidget);
        expect(find.text('Mood Quadrant'), findsOneWidget);

        // Mood label should show "Excited" for high valence + high arousal
        expect(find.text('Excited'), findsOneWidget);
      });

      testWidgets('shows Anxious label for high arousal negative valence',
          (tester) async {
        final position = createPosition(valence: -0.7, arousal: 0.8);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MoodQuadrantDisplayWidget(position: position),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Anxious'), findsOneWidget);
      });

      testWidgets('shows Calm label for low arousal positive valence',
          (tester) async {
        final position = createPosition(valence: 0.7, arousal: -0.8);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MoodQuadrantDisplayWidget(position: position),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Calm'), findsOneWidget);
      });

      testWidgets('shows Sad label for low arousal negative valence',
          (tester) async {
        final position = createPosition(valence: -0.7, arousal: -0.8);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MoodQuadrantDisplayWidget(position: position),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Sad'), findsOneWidget);
      });

      testWidgets('shows Neutral label for center position', (tester) async {
        final position = createPosition(valence: 0.0, arousal: 0.0);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MoodQuadrantDisplayWidget(position: position),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Neutral'), findsOneWidget);
      });

      testWidgets('shows Pleasant label for moderate positive valence',
          (tester) async {
        final position = createPosition(valence: 0.4, arousal: 0.0);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MoodQuadrantDisplayWidget(position: position),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Pleasant'), findsOneWidget);
      });

      testWidgets('shows Unpleasant label for moderate negative valence',
          (tester) async {
        final position = createPosition(valence: -0.4, arousal: 0.0);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MoodQuadrantDisplayWidget(position: position),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Unpleasant'), findsOneWidget);
      });
    });

    group('compact display', () {
      testWidgets('renders at specified compact size', (tester) async {
        final position = createPosition(valence: 0.5, arousal: 0.5);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: MoodQuadrantDisplayWidget(
              position: position,
              displaySize: MoodQuadrantDisplaySize.compact,
              compactSize: 60,
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Should not show header or mood label in compact mode
        expect(find.text('Mood Quadrant'), findsNothing);
        expect(find.byIcon(Icons.mood), findsNothing);
      });

      testWidgets('renders at custom compact size', (tester) async {
        final position = createPosition(valence: 0.5, arousal: 0.5);

        await tester.pumpWidget(createTestApp(
          Scaffold(
            body: MoodQuadrantDisplayWidget(
              position: position,
              displaySize: MoodQuadrantDisplaySize.compact,
              compactSize: 40,
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 40);
        expect(sizedBox.height, 40);
      });
    });
  });

  group('quadrantColor', () {
    test('returns orange for highEnergyPositive', () {
      expect(quadrantColor(MoodQuadrant.highEnergyPositive), Colors.orange);
    });

    test('returns green for lowEnergyPositive', () {
      expect(quadrantColor(MoodQuadrant.lowEnergyPositive), Colors.green);
    });

    test('returns red for highEnergyNegative', () {
      expect(quadrantColor(MoodQuadrant.highEnergyNegative), Colors.red);
    });

    test('returns blueGrey for lowEnergyNegative', () {
      expect(quadrantColor(MoodQuadrant.lowEnergyNegative), Colors.blueGrey);
    });
  });
}
