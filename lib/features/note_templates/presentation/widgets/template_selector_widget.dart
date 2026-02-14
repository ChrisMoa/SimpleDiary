import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateSelectorWidget extends ConsumerWidget {
  const TemplateSelectorWidget({
    super.key,
    required this.onTemplateSelected,
  });

  final void Function(NoteTemplate template) onTemplateSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);
    final templates = ref.watch(noteTemplateLocalDataProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    if (templates.isEmpty) {
      return Center(
        child: Text(
          l10n.noTemplatesAvailable,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.selectTemplate,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 22,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Template list
            Expanded(
              child: ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: theme.colorScheme.secondaryContainer,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onTemplateSelected(template);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: template.noteCategory.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (template.hasDescriptionSections)
                                    Text(
                                      template.descriptionSections.map((s) => s.title).join(' / '),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  else if (template.description.isNotEmpty)
                                    Text(
                                      template.description,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${template.durationMinutes} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
