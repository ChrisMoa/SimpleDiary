import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateEditingWidget extends ConsumerStatefulWidget {
  const TemplateEditingWidget({
    super.key,
    this.template,
  });

  final NoteTemplate? template;

  @override
  ConsumerState<TemplateEditingWidget> createState() => _TemplateEditingWidgetState();
}

class _TemplateEditingWidgetState extends ConsumerState<TemplateEditingWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late NoteTemplate _template;
  bool _useDescriptionSections = false;
  List<DescriptionSection> _sections = [];

  @override
  void initState() {
    super.initState();
    _template = widget.template ?? NoteTemplate.fromEmpty();
    _titleController.text = _template.title;
    _useDescriptionSections = _template.hasDescriptionSections;
    if (_useDescriptionSections) {
      _sections = List.from(_template.descriptionSections);
    } else {
      _descriptionController.text = _template.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * (isKeyboardVisible ? 0.9 : 0.8),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.template != null ? l10n.editTemplate : l10n.createTemplate,
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
                const SizedBox(height: 24),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(theme, l10n.templateName),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterTemplateName;
                    }
                    return null;
                  },
                  onSaved: (value) => _template.title = value!,
                ),
                const SizedBox(height: 16),

                // Duration field
                TextFormField(
                  initialValue: _template.durationMinutes.toString(),
                  decoration: _buildInputDecoration(theme, l10n.durationMinutes),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterDuration;
                    }
                    final minutes = int.tryParse(value);
                    if (minutes == null || minutes <= 0) {
                      return l10n.pleaseEnterValidDuration;
                    }
                    return null;
                  },
                  onSaved: (value) => _template.durationMinutes = int.parse(value!),
                ),
                const SizedBox(height: 16),

                // Category dropdown
                _buildCategoryDropdown(theme, l10n),
                const SizedBox(height: 20),

                // Description mode toggle
                _buildDescriptionModeToggle(theme),
                const SizedBox(height: 12),

                // Description content (simple or sections)
                if (_useDescriptionSections)
                  _buildSectionsEditor(theme, isSmallScreen)
                else
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _buildInputDecoration(theme, l10n.description),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 3,
                    onSaved: (value) => _template.description = value ?? '',
                  ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                      child: Text(widget.template != null ? l10n.update : l10n.createTemplate),
                    ),
                  ],
                ),
                // Add extra padding at the bottom when keyboard is visible
                SizedBox(height: isKeyboardVisible ? 16 : 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.primary),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme, AppLocalizations l10n) {
    final categories = ref.watch(categoryLocalDataProvider);
    // Value must be an item in the list; match by title, fallback to first
    NoteCategory? selectedCategory;
    if (categories.isNotEmpty) {
      selectedCategory = categories.cast<NoteCategory?>().firstWhere(
        (cat) => cat!.title == _template.noteCategory.title,
        orElse: () => null,
      ) ?? categories.first;
    }
    return DropdownButtonFormField<NoteCategory>(
      value: selectedCategory,
      decoration: _buildInputDecoration(theme, l10n.category),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      dropdownColor: theme.colorScheme.surface,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(category.title),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _template.noteCategory = value;
          });
        }
      },
      onSaved: (value) {
        if (value != null) _template.noteCategory = value;
      },
    );
  }

  Widget _buildDescriptionModeToggle(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          label: Text(l10n.simple),
          icon: const Icon(Icons.notes, size: 18),
        ),
        ButtonSegment(
          value: true,
          label: Text(l10n.sections),
          icon: const Icon(Icons.list_alt, size: 18),
        ),
      ],
      selected: {_useDescriptionSections},
      onSelectionChanged: (selection) {
        setState(() {
          _useDescriptionSections = selection.first;
          if (_useDescriptionSections && _sections.isEmpty) {
            _sections.add(const DescriptionSection(title: ''));
          }
        });
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(
          theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionsEditor(ThemeData theme, bool isSmallScreen) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          return _buildSectionCard(index, section, theme, isSmallScreen);
        }),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _sections.add(const DescriptionSection(title: ''));
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addSection),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(int index, DescriptionSection section, ThemeData theme, bool isSmallScreen) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section number indicator
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Input fields
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: section.title,
                    decoration: InputDecoration(
                      labelText: l10n.sectionTitle,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (value) {
                      _sections[index] = _sections[index].copyWith(title: value);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: section.hint,
                    decoration: InputDecoration(
                      labelText: l10n.hintOptional,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    onChanged: (value) {
                      _sections[index] = _sections[index].copyWith(hint: value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Remove button
            IconButton(
              onPressed: () {
                setState(() {
                  _sections.removeAt(index);
                });
              },
              icon: Icon(
                Icons.remove_circle_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: l10n.removeSection,
            ),
          ],
        ),
      ),
    );
  }

  void _saveTemplate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_useDescriptionSections) {
        _template.description = '';
        _template.descriptionSections =
            _sections.where((s) => s.title.isNotEmpty).toList();
      } else {
        _template.descriptionSections = [];
      }

      if (widget.template != null) {
        // Update existing template
        ref.read(noteTemplateLocalDataProvider.notifier).editElement(
              _template,
              widget.template!,
            );
      } else {
        // Create new template
        ref.read(noteTemplateLocalDataProvider.notifier).addElement(_template);
      }

      Navigator.of(context).pop();

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.template != null ? l10n.templateUpdatedSuccessfully : l10n.templateCreatedSuccessfully,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
