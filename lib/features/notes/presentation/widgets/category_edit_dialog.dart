import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryEditDialog extends ConsumerStatefulWidget {
  const CategoryEditDialog({
    super.key,
    this.category,
  });

  final NoteCategory? category;

  @override
  ConsumerState<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends ConsumerState<CategoryEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late Color _selectedColor;
  late String? _categoryId;

  // Predefined color palette
  final List<Color> _colorPalette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _titleController.text = widget.category!.title;
      _selectedColor = widget.category!.color;
      _categoryId = widget.category!.id;
    } else {
      _selectedColor = _colorPalette.first;
      _categoryId = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 450,
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
                        widget.category != null
                            ? 'Edit Category'
                            : 'Create Category',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 18 : 22,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: AppLocalizations.of(context).close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                AppSpacing.verticalXl,

                // Title field
                AppTextField(
                  controller: _titleController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveCategory(),
                  label: 'Category Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    // Check for duplicate names
                    final provider =
                        ref.read(categoryLocalDataProvider.notifier);
                    if (provider.categoryNameExists(value,
                        excludeId: _categoryId)) {
                      return 'A category with this name already exists';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalLg,

                // Color section
                Text(
                  'Category Color',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalSm,

                // Color preview
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: AppRadius.borderRadiusSm,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _titleController.text.isEmpty
                          ? 'Preview'
                          : _titleController.text,
                      style: TextStyle(
                        color: _getContrastColor(_selectedColor),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                AppSpacing.verticalMd,

                // Color palette
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPalette.map((color) {
                    final isSelected = color.toARGB32() == _selectedColor.toARGB32();
                    final colorName = _colorName(color);
                    return Semantics(
                      label: AppLocalizations.of(context).categoryColorLabel(colorName),
                      selected: isSelected,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: _getContrastColor(color),
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppSpacing.verticalXl,

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    AppSpacing.horizontalSm,
                    ElevatedButton(
                      onPressed: _saveCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Text(widget.category != null ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = NoteCategory(
      id: _categoryId,
      title: _titleController.text.trim(),
      color: _selectedColor,
    );

    final provider = ref.read(categoryLocalDataProvider.notifier);

    if (widget.category != null) {
      // Edit existing category
      provider.editElement(category, widget.category!);
      AppSnackBar.success(context, message: 'Category updated');
    } else {
      // Create new category
      provider.addElement(category);
      AppSnackBar.success(context, message: 'Category created');
    }

    Navigator.of(context).pop();
  }

  /// Get a human-readable name for a Material color.
  String _colorName(Color color) {
    const names = <int, String>{
      0xFFF44336: 'Red',
      0xFFE91E63: 'Pink',
      0xFF9C27B0: 'Purple',
      0xFF673AB7: 'Deep Purple',
      0xFF3F51B5: 'Indigo',
      0xFF2196F3: 'Blue',
      0xFF03A9F4: 'Light Blue',
      0xFF00BCD4: 'Cyan',
      0xFF009688: 'Teal',
      0xFF4CAF50: 'Green',
      0xFF8BC34A: 'Light Green',
      0xFFCDDC39: 'Lime',
      0xFFFFEB3B: 'Yellow',
      0xFFFFC107: 'Amber',
      0xFFFF9800: 'Orange',
      0xFFFF5722: 'Deep Orange',
      0xFF795548: 'Brown',
      0xFF9E9E9E: 'Grey',
      0xFF607D8B: 'Blue Grey',
    };
    return names[color.toARGB32()] ?? 'Color';
  }

  /// Get contrast color (white or black) based on background color
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
