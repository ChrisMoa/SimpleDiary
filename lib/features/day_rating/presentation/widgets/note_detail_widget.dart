import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
import 'package:day_tracker/features/notes/presentation/widgets/image_picker_widget.dart';
import 'package:day_tracker/features/note_templates/presentation/widgets/template_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';

class NoteDetailWidget extends ConsumerStatefulWidget {
  const NoteDetailWidget({super.key});

  @override
  ConsumerState<NoteDetailWidget> createState() => _NoteDetailWidgetState();
}

class _NoteDetailWidgetState extends ConsumerState<NoteDetailWidget> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _oldText = '';
  String? _lastNoteId;

  // Controller for the scrollable view
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeechToText() async {
    LogWrapper.logger.d('Initializing speech to text');
    if (_supportsPlatformSpeechRecognition()) {
      try {
        final initialized = await _speechToText.initialize(
          finalTimeout: const Duration(minutes: 1),
          onError: (error) {
            LogWrapper.logger.w('Speech recognition error: $error');
          },
          onStatus: (status) {
            LogWrapper.logger.d('Speech recognition status: $status');
          },
        );
        if (!initialized) {
          LogWrapper.logger.w('Speech recognition initialization failed');
        } else {
          LogWrapper.logger.d('Speech to text initialized successfully');
        }
      } catch (e) {
        LogWrapper.logger.w('Speech recognition initialization error: $e');
      }
    } else {
      LogWrapper.logger.w('Speech recognition not supported on this platform');
    }
  }

  bool _supportsPlatformSpeechRecognition() {
    return activePlatform.platform == ActivePlatform.android || activePlatform.platform == ActivePlatform.ios;
  }

  @override
  Widget build(BuildContext context) {
    final selectedNote = ref.watch(selectedWizardNoteProvider);
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);

    // Get screen dimensions for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;

    // Update controllers when selected note changes
    if (selectedNote != null && selectedNote.id != _lastNoteId) {
      _titleController.text = selectedNote.title;
      _descriptionController.text = selectedNote.description;
      _lastNoteId = selectedNote.id;
    }

    // If no note is selected, suggest creating a new note
    if (selectedNote == null) {
      return _buildEmptyNoteView(theme);
    }

    // Show the note details when a note is selected
    return AppCard.elevated(
      margin: AppSpacing.paddingAllXs,
      color: theme.colorScheme.secondaryContainer,
      borderRadius: AppRadius.borderRadiusMd,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: AppSpacing.paddingAllLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with time info - Responsive layout for small screens
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            color: selectedNote.noteCategory.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AppSpacing.horizontalSm,
                        Expanded(
                          child: Text(
                            l10n.noteDetails,
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          selectedNote.noteCategory.color.withValues(alpha: 0.15),
                          selectedNote.noteCategory.color.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: AppRadius.borderRadiusXl,
                      border: Border.all(
                        color: selectedNote.noteCategory.color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: selectedNote.noteCategory.color,
                        ),
                        AppSpacing.horizontalXxs,
                        Text(
                          '${Utils.toTime(selectedNote.from)} - ${Utils.toTime(selectedNote.to)}',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalLg,

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  if (value != selectedNote.title) {
                    _updateNote(
                      Note(
                        id: selectedNote.id,
                        title: value,
                        description: selectedNote.description,
                        from: selectedNote.from,
                        to: selectedNote.to,
                        noteCategory: selectedNote.noteCategory,
                        isAllDay: selectedNote.isAllDay,
                      ),
                    );
                  }
                },
              ),
              AppSpacing.verticalSm,

              // Time and category row - Adaptive layout based on screen size and keyboard visibility
              if (!isKeyboardVisible || !isSmallScreen) // Hide on small screens when keyboard is visible
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: isSmallScreen ? _buildCompactControls(selectedNote, theme) : _buildFullControls(selectedNote, theme),
                ),

              // Description field - with label and speech button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.description,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Speech-to-text button only on supported platforms
                  if (_supportsPlatformSpeechRecognition())
                    Container(
                      decoration: BoxDecoration(
                        color: _isListening
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                      child: IconButton(
                        onPressed: _isListening ? _stopListening : _startListening,
                        icon: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        tooltip: _isListening ? l10n.stopDictation : l10n.dictateDescription,
                      ),
                    ),
                ],
              ),
              AppSpacing.verticalSm,

              // Description text field - Larger height for better visibility on small screens
              SizedBox(
                height: 200, // Fixed height to ensure visibility on small screens
                child: Stack(
                  children: [
                    // Text field
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: l10n.addDetailsAboutNote,
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: AppSpacing.paddingAllMd,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      onTap: () {
                        // Auto-scroll to ensure the text field is visible when tapped
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      },
                      onChanged: (value) {
                        if (value != selectedNote.description) {
                          _updateNote(
                            Note(
                              id: selectedNote.id,
                              title: selectedNote.title,
                              description: value,
                              from: selectedNote.from,
                              to: selectedNote.to,
                              noteCategory: selectedNote.noteCategory,
                              isAllDay: selectedNote.isAllDay,
                            ),
                          );
                        }
                      },
                    ),

                    // Speech to text indicator
                    if (_isListening)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: AppSpacing.paddingAllXs,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                              AppSpacing.horizontalXs,
                              Text(
                                l10n.listening,
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Photo attachments
              AppSpacing.verticalMd,
              ImagePickerWidget(noteId: selectedNote.id!),

              // Action buttons for notes - show only when keyboard is not visible on small screens
              if (!isKeyboardVisible || !isSmallScreen)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      // Delete button
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: l10n.delete,
                        onPressed: () => _deleteNote(selectedNote),
                        backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                        foregroundColor: theme.colorScheme.error,
                        isSmallScreen: isSmallScreen,
                      ),
                      // Add from template button
                      _buildActionButton(
                        icon: Icons.note_add_outlined,
                        label: l10n.template,
                        onPressed: _showTemplateSelector,
                        backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        foregroundColor: theme.colorScheme.primary,
                        isSmallScreen: isSmallScreen,
                      ),
                      // Add button
                      _buildActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: l10n.add,
                        onPressed: _addNextFreeNote,
                        backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        foregroundColor: theme.colorScheme.primary,
                        isSmallScreen: isSmallScreen,
                      ),

                      // Time editor buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTimeButton(
                            icon: Icons.remove_rounded,
                            label: '-30m',
                            onPressed: () => _adjustTime(selectedNote, -30),
                            theme: theme,
                            isSmallScreen: isSmallScreen,
                          ),
                          AppSpacing.horizontalXs,
                          _buildTimeButton(
                            icon: Icons.add_rounded,
                            label: '+30m',
                            onPressed: () => _adjustTime(selectedNote, 30),
                            theme: theme,
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Extra padding at the bottom for keyboard space
              SizedBox(height: isKeyboardVisible ? 100 : 20),
            ],
          ),
        ),
      ),
    );
  }

  // Show template selector
  void _showTemplateSelector() {
    showDialog(
      context: context,
      builder: (context) => TemplateSelectorWidget(
        onTemplateSelected: (template) {
          _createNoteFromTemplate(template);
        },
      ),
    );
  }

  // Create note from template
  void _createNoteFromTemplate(NoteTemplate template) {
    final l10n = AppLocalizations.of(context);
    LogWrapper.logger.d('Creating note from template: ${template.title}');
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

      LogWrapper.logger.d('Creating new note with ID: ${newNote.id}');
      // Add to database
      ref.read(notesLocalDataProvider.notifier).addElement(newNote);

      // Select the new note
      ref.read(selectedWizardNoteProvider.notifier).selectNote(newNote);

      // Show feedback to user
      AppSnackBar.success(context, message: l10n.addedTemplateAtTime(template.title, Utils.toTime(newNote.from)));
    } catch (e) {
      LogWrapper.logger.e('Error creating note from template: $e');
    }
  }

  // Compact controls for small screens
  Widget _buildCompactControls(Note note, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoryLocalDataProvider);
    // Ensure the note's category exists in the dropdown items
    final effectiveCategory = categories.contains(note.noteCategory)
        ? note.noteCategory
        : (categories.isNotEmpty ? categories.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category dropdown
        DropdownButtonFormField<NoteCategory>(
          value: effectiveCategory,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.category,
            labelStyle: TextStyle(color: theme.colorScheme.primary),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          dropdownColor: theme.colorScheme.surface,
          items: ref.watch(categoryLocalDataProvider).map((category) {
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
                  AppSpacing.horizontalXs,
                  Text(category.title),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && value != note.noteCategory) {
              _updateNote(
                Note(
                  id: note.id,
                  title: note.title,
                  description: note.description,
                  from: note.from,
                  to: note.to,
                  noteCategory: value,
                  isAllDay: note.isAllDay,
                ),
              );
            }
          },
        ),
        AppSpacing.verticalSm,

        // Time buttons in a row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(context, note, true),
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(
                  l10n.fromTime(Utils.toTime(note.from)),
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: AppSpacing.paddingVerticalXs,
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
            ),
            AppSpacing.horizontalXs,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(context, note, false),
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(
                  l10n.toTime(Utils.toTime(note.to)),
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: AppSpacing.paddingVerticalXs,
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSm,
      ],
    );
  }

  // Full controls for larger screens
  Widget _buildFullControls(Note note, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoryLocalDataProvider);
    // Ensure the note's category exists in the dropdown items
    final effectiveCategory = categories.contains(note.noteCategory)
        ? note.noteCategory
        : (categories.isNotEmpty ? categories.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category dropdown
        DropdownButtonFormField<NoteCategory>(
          value: effectiveCategory,
          decoration: InputDecoration(
            labelText: l10n.category,
            labelStyle: TextStyle(color: theme.colorScheme.primary),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          dropdownColor: theme.colorScheme.surface,
          items: ref.watch(categoryLocalDataProvider).map((category) {
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
                  AppSpacing.horizontalXs,
                  Text(category.title),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && value != note.noteCategory) {
              _updateNote(
                Note(
                  id: note.id,
                  title: note.title,
                  description: note.description,
                  from: note.from,
                  to: note.to,
                  noteCategory: value,
                  isAllDay: note.isAllDay,
                ),
              );
            }
          },
        ),
        AppSpacing.verticalSm,

        // Time pickers row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(context, note, true),
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(l10n.fromTime(Utils.toTime(note.from))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
            ),
            AppSpacing.horizontalXs,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(context, note, false),
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(l10n.toTime(Utils.toTime(note.to))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSm,
      ],
    );
  }

  Widget _buildEmptyNoteView(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    // Check if we're on a small screen to adapt layout
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    return AppCard.elevated(
      margin: AppSpacing.paddingAllXs,
      color: theme.colorScheme.secondaryContainer,
      borderRadius: AppRadius.borderRadiusMd,
      child: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingAllMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_add,
                size: isSmallScreen ? 36 : 48,
                color: theme.colorScheme.primary,
              ),
              AppSpacing.verticalMd,
              Text(
                l10n.noNoteSelected,
                style: theme.textTheme.titleLarge!.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalXs,
              Text(
                l10n.clickExistingOrCreateNew,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              AppSpacing.verticalXl,
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addNextFreeNote,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.createNote),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 24,
                        vertical: isSmallScreen ? 8 : 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showTemplateSelector,
                    icon: const Icon(Icons.note_alt_outlined, size: 18),
                    label: Text(l10n.fromTemplate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 24,
                        vertical: isSmallScreen ? 8 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, Note note, bool isFromTime) async {
    final theme = ref.read(themeProvider);
    final currentTime = isFromTime ? note.from : note.to;

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
      builder: (context, child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (timeOfDay != null) {
      final newDateTime = DateTime(
        note.from.year,
        note.from.month,
        note.from.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      if (isFromTime) {
        // Ensure end time is at least 15 minutes after start time
        final endTime = note.to.isBefore(newDateTime.add(const Duration(minutes: 15))) ? newDateTime.add(const Duration(minutes: 15)) : note.to;

        _updateNote(
          Note(
            id: note.id,
            title: note.title,
            description: note.description,
            from: newDateTime,
            to: endTime,
            noteCategory: note.noteCategory,
            isAllDay: note.isAllDay,
          ),
        );
      } else {
        // Ensure end time is after start time
        if (newDateTime.isAfter(note.from)) {
          _updateNote(
            Note(
              id: note.id,
              title: note.title,
              description: note.description,
              from: note.from,
              to: newDateTime,
              noteCategory: note.noteCategory,
              isAllDay: note.isAllDay,
            ),
          );
        } else {
          AppSnackBar.error(context, message: AppLocalizations.of(context).endTimeAfterStartTime);
        }
      }
    }
  }

  void _updateNote(Note updatedNote) {
    final originalNote = ref.read(selectedWizardNoteProvider);
    if (originalNote != null) {
      // Update in database
      ref.read(notesLocalDataProvider.notifier).editElement(
            updatedNote,
            originalNote,
          );

      // Update selected note
      ref.read(selectedWizardNoteProvider.notifier).updateNote(originalNote, updatedNote);
    }
  }

  void _deleteNote(Note note) {
    final l10n = AppLocalizations.of(context);
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.confirmDeleteNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Delete from database
              ref.read(notesLocalDataProvider.notifier).deleteElement(note);
              // Clear selection
              ref.read(selectedWizardNoteProvider.notifier).clearSelection();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _addNextFreeNote() {
    LogWrapper.logger.d('Adding next free note');
    try {
      // Get the next empty note from provider
      final newNote = ref.read(createEmptyNoteProvider);

      LogWrapper.logger.d('Creating new note with ID: ${newNote.id}');
      // Add to database
      ref.read(notesLocalDataProvider.notifier).addElement(newNote);

      // Select the new note
      ref.read(selectedWizardNoteProvider.notifier).selectNote(newNote);

      // Show feedback to user
      AppSnackBar.success(context, message: AppLocalizations.of(context).addedNoteAtTime(Utils.toTime(newNote.from)));
    } catch (e) {
      LogWrapper.logger.e('Error adding new note: $e');
    }
  }

  Future<void> _startListening() async {
    if (_supportsPlatformSpeechRecognition()) {
      FocusScope.of(context).unfocus();
      _oldText = _descriptionController.text;
      await _speechToText.listen(
        onResult: _onSpeechToTextResult,
        listenFor: const Duration(minutes: 2),
        listenOptions: SpeechListenOptions(
          partialResults: false,
          listenMode: ListenMode.dictation,
        ),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _stopListening() async {
    if (_supportsPlatformSpeechRecognition()) {
      await _speechToText.stop();
      setState(() {
        _descriptionController.text = _descriptionController.text.replaceAll(RegExp(r'Notiz Ende'), '');
        _isListening = false;
      });

      // Update the note with the new description
      final selectedNote = ref.read(selectedWizardNoteProvider);
      if (selectedNote != null) {
        _updateNote(
          Note(
            id: selectedNote.id,
            title: selectedNote.title,
            description: _descriptionController.text,
            from: selectedNote.from,
            to: selectedNote.to,
            noteCategory: selectedNote.noteCategory,
            isAllDay: selectedNote.isAllDay,
          ),
        );
      }
    }
  }

  Future<void> _onSpeechToTextResult(SpeechRecognitionResult result) async {
    var text = result.recognizedWords;
    if (_oldText.isNotEmpty) {
      text = "$_oldText $text";
    }

    // Replace common speech patterns
    text = text.replaceAll(RegExp('%unkt'), '. ');
    text = text.replaceAll(RegExp('%omma'), ', ');

    setState(() {
      if (text.contains('Notiz Ende')) {
        _stopListening();
      }
      _descriptionController.text = text;
    });

    // Update the note with the new description
    final selectedNote = ref.read(selectedWizardNoteProvider);
    if (selectedNote != null) {
      _updateNote(
        Note(
          id: selectedNote.id,
          title: selectedNote.title,
          description: text,
          from: selectedNote.from,
          to: selectedNote.to,
          noteCategory: selectedNote.noteCategory,
          isAllDay: selectedNote.isAllDay,
        ),
      );
    }

    if (_speechToText.isNotListening) {
      _startListening();
    }
  }

  void _adjustTime(Note note, int minutes) {
    final newDateTime = DateTime(
      note.from.year,
      note.from.month,
      note.from.day,
      note.from.hour + (note.from.minute + minutes) ~/ 60,
      (note.from.minute + minutes) % 60,
    );

    if (newDateTime.isAfter(note.to) || newDateTime.isAtSameMomentAs(note.to)) {
      AppSnackBar.error(context, message: AppLocalizations.of(context).endTimeAfterStartTime);
      return;
    }

    _updateNote(
      Note(
        id: note.id,
        title: note.title,
        description: note.description,
        from: newDateTime,
        to: note.to,
        noteCategory: note.noteCategory,
        isAllDay: note.isAllDay,
      ),
    );
  }

  // Modern action button builder
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: foregroundColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.borderRadiusMd,
          child: Padding(
            padding: isSmallScreen
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isSmallScreen ? 18 : 20,
                  color: foregroundColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern time adjustment button builder
  Widget _buildTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.borderRadiusMd,
          child: Padding(
            padding: isSmallScreen
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isSmallScreen ? 16 : 18,
                  color: theme.colorScheme.primary,
                ),
                AppSpacing.horizontalXxs,
                Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
