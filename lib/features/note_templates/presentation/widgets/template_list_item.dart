import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
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
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return AppCard.outlined(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16, vertical: 8),
      color: theme.colorScheme.secondaryContainer,
      borderColor: theme.colorScheme.outline.withValues(alpha: 0.1),
      borderRadius: AppRadius.borderRadiusMd,
      onTap: () => onTap(template),
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
                  AppSpacing.horizontalXs,
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
                      borderRadius: AppRadius.borderRadiusMd,
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
                  AppSpacing.horizontalXs,
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
                            AppSpacing.horizontalXs,
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                            AppSpacing.horizontalXs,
                            Text(l10n.delete),
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
              AppSpacing.verticalXs,
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
    );
  }
}

