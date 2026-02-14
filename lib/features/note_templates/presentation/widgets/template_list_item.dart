import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateListItem extends ConsumerWidget {
  const TemplateListItem({
    super.key,
    required this.template,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final NoteTemplate template;
  final void Function(NoteTemplate template) onTap;
  final void Function(NoteTemplate template) onEdit;
  final void Function(NoteTemplate template) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16, vertical: 8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: template.noteCategory.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${template.durationMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(template);
                      } else if (value == 'delete') {
                        onDelete(template);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (template.hasDescriptionSections)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: template.descriptionSections.map((section) =>
                    Chip(
                      label: Text(
                        section.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      padding: EdgeInsets.zero,
                    ),
                  ).toList(),
                )
              else if (template.description.isNotEmpty)
                Text(
                  template.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

