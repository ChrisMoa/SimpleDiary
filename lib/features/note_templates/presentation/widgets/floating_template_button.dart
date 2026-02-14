import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/presentation/widgets/template_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingTemplateButton extends ConsumerWidget {
  const FloatingTemplateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final templates = ref.watch(noteTemplateLocalDataProvider);

    // Don't show button if there are no templates
    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Quick template selection buttons for first 3 templates
          if (templates.length >= 1)
            ...templates.take(3).map((template) => _buildQuickAddButton(
                  context,
                  ref,
                  theme,
                  template,
                )),
          const SizedBox(height: 8),

          // Main template selector button
          FloatingActionButton(
            onPressed: () => _showTemplateSelector(context, ref),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            child: const Icon(Icons.note_alt),
            heroTag: 'template_fab',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    NoteTemplate template,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.small(
        onPressed: () => _createNoteFromTemplate(context, ref, template),
        backgroundColor: template.noteCategory.color,
        foregroundColor: theme.colorScheme.onPrimary,
        heroTag: 'template_${template.id}',
        child: Text(
          template.title.substring(0, 1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showTemplateSelector(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => TemplateSelectorWidget(
        onTemplateSelected: (template) => _createNoteFromTemplate(context, ref, template),
      ),
    );
  }

  void _createNoteFromTemplate(
    BuildContext context,
    WidgetRef ref,
    NoteTemplate template,
  ) {
    try {
      // Create a new note directly to avoid Provider.family caching issues
      final nextAvailableTime = ref.read(nextAvailableTimeSlotProvider);
      final newNote = Note(
        title: template.title,
        description: template.generateDescription(),
        from: nextAvailableTime,
        to: nextAvailableTime.add(Duration(minutes: template.durationMinutes)),
        noteCategory: template.noteCategory,
      );

      // Add to database
      ref.read(notesLocalDataProvider.notifier).addElement(newNote);

      // Select the new note in the wizard
      ref.read(selectedWizardNoteProvider.notifier).selectNote(newNote);

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added "${template.title}" at ${newNote.from.hour.toString().padLeft(2, '0')}:${newNote.from.minute.toString().padLeft(2, '0')}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating note: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
