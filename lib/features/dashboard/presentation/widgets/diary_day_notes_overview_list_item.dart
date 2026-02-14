import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DiaryDayNotesOverviewListItem extends ConsumerWidget {
  const DiaryDayNotesOverviewListItem(
      {super.key, required this.note, required this.onSelectNote});

  final Note note;
  final void Function(Note note) onSelectNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: note.noteCategory.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (note.description.isNotEmpty)
                  Text(
                    note.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Favorite toggle
          GestureDetector(
            onTap: () {
              final updated = note.copyWith(isFavorite: !note.isFavorite);
              ref.read(notesLocalDataProvider.notifier).addOrUpdateElement(updated);
            },
            child: Icon(
              note.isFavorite ? Icons.star : Icons.star_outline,
              size: 20,
              color: note.isFavorite
                  ? Colors.amber
                  : theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getTimeRangeText(note),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeRangeText(Note note) {
    if (note.isAllDay) {
      return 'All day';
    }

    final timeFormat = DateFormat('HH:mm');
    return '${timeFormat.format(note.from)} - ${timeFormat.format(note.to)}';
  }
}
