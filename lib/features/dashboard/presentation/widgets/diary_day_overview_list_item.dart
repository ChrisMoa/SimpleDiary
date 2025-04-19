import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/diary_day_notes_overview_list_item.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiaryDayOverviewListItem extends StatelessWidget {
  final DiaryDay diaryDay;
  final Function(DiaryDay) onSelectDiaryDay;

  const DiaryDayOverviewListItem({
    super.key,
    required this.diaryDay,
    required this.onSelectDiaryDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Use the secondaryContainer color from theme to match other UI elements
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Optional subtle border
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onSelectDiaryDay(diaryDay),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
              _buildRatingsSection(context),
              const SizedBox(height: 16),
              _buildNotesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final date = diaryDay.day;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Row(
      children: [
        Text(
          '${date.day}',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Utils.printMonth(date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              dateFormat.format(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            // Use semantically meaningful colors but apply theme-aware opacity
            color: _getScoreColor(diaryDay.overallScore)
                .withOpacity(theme.brightness == Brightness.dark ? 0.7 : 1.0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Score: ${diaryDay.overallScore}',
            style: theme.textTheme.bodyMedium?.copyWith(
              // Make sure text is always visible on the score background
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: diaryDay.ratings.map((rating) {
        return _buildRatingItem(
            context, rating.dayRating.name.substring(0, 3), rating.score);
      }).toList(),
    );
  }

  Widget _buildRatingItem(BuildContext context, String label, int score) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            // Apply theme-aware brightness to rating colors
            color: _getRatingColor(score)
                .withOpacity(theme.brightness == Brightness.dark ? 0.8 : 1.0),
            shape: BoxShape.circle,
            // Optional subtle border for better visibility in all themes
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '$score',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);

    if (diaryDay.notes.isEmpty) {
      return Text(
        'No notes for this day',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Display up to 3 notes with a "more" indicator if needed
        ...diaryDay.notes.take(3).map((note) => DiaryDayNotesOverviewListItem(
              note: note,
              onSelectNote: (_) {}, // No-op or implement if needed
            )),
        if (diaryDay.notes.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ ${diaryDay.notes.length - 3} more notes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  // Keep semantic colors for scores but adjust in the UI with opacity
  Color _getScoreColor(int score) {
    final maxScore = 20; // Assuming 4 categories * 5 max score
    final percentage = score / maxScore;

    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.5) return Colors.orange;
    if (percentage < 0.7) return Colors.amber;
    if (percentage < 0.9) return Colors.lightGreen;
    return Colors.green;
  }

  // Keep semantic colors for ratings but adjust in the UI with opacity
  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
