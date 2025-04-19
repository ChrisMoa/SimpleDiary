import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiaryDayNotesOverviewListItem extends StatelessWidget {
  const DiaryDayNotesOverviewListItem(
      {super.key, required this.note, required this.onSelectNote});

  final Note note;
  final void Function(Note note) onSelectNote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                if (note.description.isNotEmpty)
                  Text(
                    note.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getTimeRangeText(note),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
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
