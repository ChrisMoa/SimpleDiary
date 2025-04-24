// lib/features/day_rating/presentation/widgets/note_detail_widget.dart
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

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

  // Track if keyboard is active to manage UI layout
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeechToText() async {
    if (_supportsPlatformSpeechRecognition()) {
      await _speechToText.initialize(
        finalTimeout: const Duration(minutes: 1),
      );
    }
  }

  bool _supportsPlatformSpeechRecognition() {
    return activePlatform.platform == ActivePlatform.android ||
        activePlatform.platform == ActivePlatform.ios;
  }

  @override
  Widget build(BuildContext context) {
    final selectedNote = ref.watch(selectedWizardNoteProvider);
    final theme = ref.watch(themeProvider);

    // Check if keyboard is visible to adapt UI
    _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

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
    return _buildNoteDetailView(theme, selectedNote);
  }

  Widget _buildEmptyNoteView(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_add,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'No note selected',
                style: theme.textTheme.titleLarge!.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click on an existing note or create a new one',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _addNextFreeNote,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteDetailView(ThemeData theme, Note selectedNote) {
    // Create a responsive layout that adapts to keyboard visibility
    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with time info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Note Details',
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedNote.noteCategory.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: selectedNote.noteCategory.color,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${Utils.toTime(selectedNote.from)} - ${Utils.toTime(selectedNote.to)}',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: theme.colorScheme.primary),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
              style: theme.textTheme.titleMedium,
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
            const SizedBox(height: 12),

            // Time and category row - disappears when keyboard is visible to save space
            if (!_isKeyboardVisible) ...[
              // Category dropdown
              DropdownButtonFormField<NoteCategory>(
                value: selectedNote.noteCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: theme.colorScheme.primary),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                items: availableNoteCategories.map((category) {
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
                  if (value != null && value != selectedNote.noteCategory) {
                    _updateNote(
                      Note(
                        id: selectedNote.id,
                        title: selectedNote.title,
                        description: selectedNote.description,
                        from: selectedNote.from,
                        to: selectedNote.to,
                        noteCategory: value,
                        isAllDay: selectedNote.isAllDay,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              // Time pickers row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(context, selectedNote, true),
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text('From: ${Utils.toTime(selectedNote.from)}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _selectTime(context, selectedNote, false),
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text('To: ${Utils.toTime(selectedNote.to)}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Description label
            Text(
              'Description',
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Description field - expands to fill available space
            Expanded(
              child: TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Add description...',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: theme.textTheme.bodyMedium,
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
            ),

            // Bottom buttons area - adapts based on keyboard visibility
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Voice input button (only for supported platforms)
                  if (_supportsPlatformSpeechRecognition())
                    TextButton.icon(
                      onPressed: () {
                        if (_speechToText.isListening) {
                          _stopListeningNow();
                        } else {
                          _startListeningNow();
                        }
                      },
                      icon: _isListening
                          ? LoadingAnimationWidget.beat(
                              size: 16,
                              color: theme.colorScheme.primary,
                            )
                          : const Icon(Icons.mic, size: 16),
                      label: Text(_isListening ? 'Stop' : 'Voice'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        backgroundColor: _isListening
                            ? theme.colorScheme.error.withOpacity(0.1)
                            : theme.colorScheme.primaryContainer
                                .withOpacity(0.3),
                      ),
                    ),

                  // Delete button
                  TextButton.icon(
                    onPressed: () => _deleteNote(selectedNote),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, Note note, bool isFromTime) async {
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
        final endTime =
            note.to.isBefore(newDateTime.add(const Duration(minutes: 15)))
                ? newDateTime.add(const Duration(minutes: 15))
                : note.to;

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time'),
              duration: Duration(seconds: 2),
            ),
          );
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
      ref
          .read(selectedWizardNoteProvider.notifier)
          .updateNote(originalNote, updatedNote);
    }
  }

  void _deleteNote(Note note) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Delete from database
              ref.read(notesLocalDataProvider.notifier).deleteElement(note);
              // Clear selection
              ref.read(selectedWizardNoteProvider.notifier).clearSelection();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNextFreeNote() {
    // Get the next available time slot
    final nextStartTime = ref.read(nextAvailableTimeSlotProvider);

    // Create a new note with 30-minute duration
    final newNote = Note(
      id: const Uuid().v4(),
      title: '',
      description: '',
      from: nextStartTime,
      to: nextStartTime.add(const Duration(minutes: 30)),
      noteCategory: availableNoteCategories.first,
    );

    // Add to database
    ref.read(notesLocalDataProvider.notifier).addElement(newNote);

    // Select the new note
    ref.read(selectedWizardNoteProvider.notifier).selectNote(newNote);

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added new note at ${Utils.toTime(nextStartTime)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _startListeningNow() async {
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

  Future<void> _stopListeningNow() async {
    if (_supportsPlatformSpeechRecognition()) {
      await _speechToText.stop();
      setState(() {
        _descriptionController.text =
            _descriptionController.text.replaceAll(RegExp(r'Notiz Ende'), '');
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
        _stopListeningNow();
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
      _startListeningNow();
    }
  }
}
