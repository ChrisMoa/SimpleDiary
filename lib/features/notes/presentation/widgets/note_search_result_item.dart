import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pure function to build text spans with highlighted matches
/// Extracted for testability
List<TextSpan> buildHighlightSpans(
  String text,
  String query,
  TextStyle baseStyle,
  Color highlightColor,
  Color highlightTextColor,
) {
  if (query.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final spans = <TextSpan>[];

  int start = 0;
  int index;

  while ((index = lowerText.indexOf(lowerQuery, start)) != -1) {
    // Non-matching part before the match
    if (index > start) {
      spans.add(TextSpan(
        text: text.substring(start, index),
        style: baseStyle,
      ));
    }

    // Matching part (highlighted)
    spans.add(TextSpan(
      text: text.substring(index, index + query.length),
      style: baseStyle.copyWith(
        backgroundColor: highlightColor,
        color: highlightTextColor,
        fontWeight: FontWeight.bold,
      ),
    ));

    start = index + query.length;
  }

  // Remaining text after last match
  if (start < text.length) {
    spans.add(TextSpan(
      text: text.substring(start),
      style: baseStyle,
    ));
  }

  return spans;
}

/// A list item widget that displays a note with search query highlighting
class NoteSearchResultItem extends ConsumerWidget {
  const NoteSearchResultItem({
    super.key,
    required this.note,
    required this.onSelectNote,
    this.searchQuery = '',
  });

  final Note note;
  final void Function(Note note) onSelectNote;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final highlightColor = theme.colorScheme.primaryContainer;
    final highlightTextColor = theme.colorScheme.onPrimaryContainer;

    return Card(
      margin: AppSpacing.paddingAllXs,
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusSm,
      ),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () => onSelectNote(note),
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${note.from.day}',
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2.0,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    Utils.printMonth(note.from),
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: note.noteCategory.color,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildHighlightedText(
                      note.title,
                      theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                      highlightColor,
                      highlightTextColor,
                    ),
                  ),
                ],
              ),
              _buildHighlightedText(
                note.description.isNotEmpty
                    ? note.description
                    : 'no description',
                theme.textTheme.labelMedium!.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                highlightColor,
                highlightTextColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    TextStyle style,
    Color highlightColor,
    Color highlightTextColor, {
    int? maxLines,
    TextOverflow? overflow,
  }) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = buildHighlightSpans(
      text,
      searchQuery,
      style,
      highlightColor,
      highlightTextColor,
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
