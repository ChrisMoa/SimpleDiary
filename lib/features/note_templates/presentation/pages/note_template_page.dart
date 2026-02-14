import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/presentation/widgets/template_editing_widget.dart';
import 'package:day_tracker/features/note_templates/presentation/widgets/template_list_item.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteTemplatePage extends ConsumerStatefulWidget {
  const NoteTemplatePage({super.key});

  @override
  ConsumerState<NoteTemplatePage> createState() => _NoteTemplatePageState();
}

class _NoteTemplatePageState extends ConsumerState<NoteTemplatePage> {
  @override
  void initState() {
    super.initState();
    // Read templates from database when page loads
    Future.microtask(() {
      ref.read(noteTemplateLocalDataProvider.notifier).readObjectsFromDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final templates = ref.watch(noteTemplateLocalDataProvider);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      color: theme.colorScheme.surface,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 28 : 32,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.noteTemplates,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Template list
                Expanded(
                  child: templates.isEmpty
                      ? _buildEmptyState(theme, l10n, isSmallScreen)
                      : ListView.builder(
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            return TemplateListItem(
                              template: template,
                              onTap: (template) => _showTemplateInfo(template),
                              onEdit: (template) => _editTemplate(template),
                              onDelete: (template) => _confirmDeleteTemplate(template),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _createNewTemplate,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n, bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: isSmallScreen ? 48 : 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTemplatesYet,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createTemplatesToQuicklyAdd,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewTemplate,
            icon: const Icon(Icons.add),
            label: Text(l10n.createTemplate),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  void _createNewTemplate() {
    showDialog(
      context: context,
      builder: (context) => const TemplateEditingWidget(),
    );
  }

  void _editTemplate(NoteTemplate template) {
    showDialog(
      context: context,
      builder: (context) => TemplateEditingWidget(template: template),
    );
  }

  void _confirmDeleteTemplate(NoteTemplate template) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.confirmDeleteTemplate(template.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(noteTemplateLocalDataProvider.notifier).deleteElement(template);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.templateDeleted),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showTemplateInfo(NoteTemplate template) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                  Text(template.noteCategory.title),
                ],
              ),
              const SizedBox(height: 8),
              Text(l10n.durationInMinutes(template.durationMinutes)),
              if (template.hasDescriptionSections) ...[
                const SizedBox(height: 16),
                Text(l10n.descriptionSections, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...template.descriptionSections.map((section) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.label_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(section.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        if (section.hint.isNotEmpty)
                          Text(
                            ' - ${section.hint}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ] else if (template.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.descriptionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(template.description),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editTemplate(template);
            },
            child: Text(l10n.edit),
          ),
        ],
      ),
    );
  }
}
