import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/presentation/widgets/template_selector_widget.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingTemplateButton extends ConsumerStatefulWidget {
  const FloatingTemplateButton({super.key});

  @override
  ConsumerState<FloatingTemplateButton> createState() =>
      _FloatingTemplateButtonState();
}

class _FloatingTemplateButtonState
    extends ConsumerState<FloatingTemplateButton> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
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
          // Quick template selection buttons (animated)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: 1.0,
                  child: child,
                ),
              );
            },
            child: _expanded
                ? Column(
                    key: const ValueKey('expanded'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: templates
                        .take(3)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) => AnimatedListItem(
                              index: entry.key,
                              baseDelay: const Duration(milliseconds: 30),
                              child: _buildQuickAddButton(
                                context,
                                ref,
                                theme,
                                entry.value,
                              ),
                            ))
                        .toList(),
                  )
                : const SizedBox.shrink(key: ValueKey('collapsed')),
          ),
          AppSpacing.verticalXs,

          // Main template selector button with rotation animation
          GestureDetector(
            onLongPress: () => _showTemplateSelector(context, ref),
            child: FloatingActionButton(
              onPressed: () {
                setState(() => _expanded = !_expanded);
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              heroTag: 'template_fab',
              child: AnimatedRotation(
                turns: _expanded ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.note_alt),
              ),
            ),
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
        onPressed: () {
          _createNoteFromTemplate(context, ref, template);
          setState(() => _expanded = false);
        },
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
    setState(() => _expanded = false);
    showDialog(
      context: context,
      builder: (context) => TemplateSelectorWidget(
        onTemplateSelected: (template) =>
            _createNoteFromTemplate(context, ref, template),
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
        to: nextAvailableTime
            .add(Duration(minutes: template.durationMinutes)),
        noteCategory: template.noteCategory,
      );

      // Add to database
      ref.read(notesLocalDataProvider.notifier).addElement(newNote);

      // Select the new note in the wizard
      ref.read(selectedWizardNoteProvider.notifier).selectNote(newNote);

      // Show feedback to user
      final l10n = AppLocalizations.of(context);
      final timeStr =
          '${newNote.from.hour.toString().padLeft(2, '0')}:${newNote.from.minute.toString().padLeft(2, '0')}';
      AppSnackBar.success(context,
          message: l10n.addedTemplateAtTime(template.title, timeStr));
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      AppSnackBar.error(context, message: l10n.errorCreatingNote('$e'));
    }
  }
}
