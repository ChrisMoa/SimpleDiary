import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/core/services/widget_service.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

class QuickNoteDialog extends ConsumerStatefulWidget {
  final String? preselectedCategory;

  const QuickNoteDialog({super.key, this.preselectedCategory});

  @override
  ConsumerState<QuickNoteDialog> createState() => _QuickNoteDialogState();
}

class _QuickNoteDialogState extends ConsumerState<QuickNoteDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  NoteCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize category after the first frame when ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCategory();
    });
  }

  void _initCategory() {
    final categories = ref.read(categoryLocalDataProvider);
    if (widget.preselectedCategory != null) {
      try {
        _selectedCategory = categories.firstWhere(
          (c) => c.title == widget.preselectedCategory,
        );
      } catch (e) {
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
      }
    } else {
      _selectedCategory = categories.isNotEmpty ? categories.first : null;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.titleRequired)),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.categoryRequired)),
      );
      return;
    }

    final now = DateTime.now();
    final note = Note(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      from: now,
      to: now.add(const Duration(minutes: 15)),
      isAllDay: false,
      noteCategory: _selectedCategory!,
    );

    // Save note
    await ref.read(notesLocalDataProvider.notifier).addElement(note);

    // Update widget with last used category
    await WidgetService.updateWidget(lastCategory: _selectedCategory!.title);

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noteSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryLocalDataProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.flash_on, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(l10n.quickNote),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: l10n.title,
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                hintText: l10n.enterNoteTitle,
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.title, color: theme.colorScheme.onSurfaceVariant),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description input (optional)
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: l10n.description,
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                hintText: l10n.optionalDescription,
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes, color: theme.colorScheme.onSurfaceVariant),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Category selector
            Text(
              l10n.category,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = _selectedCategory?.title == category.title;
                return FilterChip(
                  label: Text(
                    category.title,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  avatar: CircleAvatar(
                    backgroundColor: category.color,
                    radius: 8,
                  ),
                  selectedColor: category.color.withValues(alpha: 0.3),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Time info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.willBeRecordedNow,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _saveNote,
          icon: const Icon(Icons.check),
          label: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Show quick note dialog
Future<bool?> showQuickNoteDialog(
  BuildContext context, {
  String? preselectedCategory,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => QuickNoteDialog(
      preselectedCategory: preselectedCategory,
    ),
  );
}
