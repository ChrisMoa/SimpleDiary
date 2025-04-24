import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/data/models/note_data_source.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';

class NotesCalendarWidget extends ConsumerStatefulWidget {
  const NotesCalendarWidget({super.key});

  @override
  ConsumerState<NotesCalendarWidget> createState() =>
      _NotesCalendarWidgetState();
}

class _NotesCalendarWidgetState extends ConsumerState<NotesCalendarWidget> {
  final _calendarController = CalendarController();

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(wizardDayNotesProvider);
    final theme = ref.watch(themeProvider);
    final selectedDate = ref.watch(wizardSelectedDateProvider);
    final isFullyScheduled = ref.watch(isDayFullyScheduledProvider);

    // Update calendar date when provider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarController.displayDate?.day != selectedDate.day ||
          _calendarController.displayDate?.month != selectedDate.month ||
          _calendarController.displayDate?.year != selectedDate.year) {
        _calendarController.displayDate = selectedDate;
      }
    });

    // Create appointments from notes
    final dataSource = NoteDataSource(notes);

    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with action buttons
          SizedBox(
            height: 10,
          ),
          Text(
            'Daily Schedule',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isFullyScheduled)
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Schedule complete',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            Text(
              'Fill in your complete day',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          if (!isFullyScheduled)
            ElevatedButton.icon(
              onPressed: _addNewNote,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),

          // Calendar - Changed to vertical day view
          Expanded(
            child: SfCalendar(
              controller: _calendarController,
              view: CalendarView.day, // Using day view for vertical layout
              dataSource: dataSource,
              timeSlotViewSettings: TimeSlotViewSettings(
                timeInterval: const Duration(minutes: 30),
                timeIntervalHeight:
                    60, // Increased height for better touch targets
                timeFormat: 'HH:mm',
                startHour: 7,
                endHour: 22,
                timeTextStyle: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              headerHeight:
                  0, // Hide header since we have our own date selector
              viewHeaderHeight: 0, // Hide view header for cleaner look
              todayHighlightColor: theme.colorScheme.primary,
              selectionDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              cellBorderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
              initialDisplayDate: selectedDate,
              onTap: _handleCalendarTap,
              appointmentBuilder: _customAppointmentBuilder,
              allowDragAndDrop: true,
              allowAppointmentResize: true,
              onDragEnd: _handleDragEnd,
              onAppointmentResizeEnd: _handleResizeEnd,
            ),
          ),

          // Legend for categories
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableNoteCategories
                  .map((category) => _buildCategoryChip(category, theme))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(NoteCategory category, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            category.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customAppointmentBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    final note = details.appointments.first as Note;
    final theme = ref.watch(themeProvider);
    final isSelected = ref.read(selectedWizardNoteProvider)?.id == note.id;
    final isEmpty = note.title.isEmpty && note.description.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: note.noteCategory.color.withOpacity(isEmpty ? 0.3 : 0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              isSelected ? theme.colorScheme.primary : note.noteCategory.color,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'New Note' : note.title,
                    style: TextStyle(
                      color: theme.colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${Utils.toTime(note.from)} - ${Utils.toTime(note.to)}',
                  style: TextStyle(
                    color: theme.colorScheme.surface,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            if (details.bounds.height > 30 && note.description.isNotEmpty)
              Expanded(
                child: Text(
                  note.description,
                  style: TextStyle(
                    color: theme.colorScheme.surface,
                    fontSize: 10,
                  ),
                  maxLines: (details.bounds.height / 12).floor(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleCalendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment &&
        details.appointments != null &&
        details.appointments!.isNotEmpty) {
      // Select existing note
      final note = details.appointments!.first as Note;
      ref.read(selectedWizardNoteProvider.notifier).selectNote(note);
    }
  }

  void _addNewNote() {
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDragEnd(AppointmentDragEndDetails details) {
    try {
      // The appointment is accessible directly
      final note = details.appointment as Note;

      // Get new start and end times
      final DateTime newStartTime;
      final DateTime newEndTime;

      if (details.droppingTime != null) {
        // Use dropping time for new start time
        newStartTime = details.droppingTime!;

        // Calculate new end time based on original duration
        final duration = note.to.difference(note.from);
        newEndTime = newStartTime.add(duration);
      } else {
        // Fallback if dropping time is null
        debugPrint('Warning: Dropping time was null in drag end event');
        return;
      }

      // Create updated note with new times
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        description: note.description,
        from: newStartTime,
        to: newEndTime,
        noteCategory: note.noteCategory,
        isAllDay: note.isAllDay,
      );

      // Update in database
      ref.read(notesLocalDataProvider.notifier).editElement(updatedNote, note);

      // Update selected note if it's the one being edited
      final selectedNote = ref.read(selectedWizardNoteProvider);
      if (selectedNote?.id == note.id) {
        ref
            .read(selectedWizardNoteProvider.notifier)
            .updateNote(note, updatedNote);
      }
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error during drag end: $e');
    }
  }

  void _handleResizeEnd(AppointmentResizeEndDetails details) {
    try {
      // Get the appointment being resized
      final note = details.appointment as Note;

      // Create updated note with new times
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        description: note.description,
        from: details.startTime ?? note.from,
        to: details.endTime ?? note.to,
        noteCategory: note.noteCategory,
        isAllDay: note.isAllDay,
      );

      // Update in database
      ref.read(notesLocalDataProvider.notifier).editElement(updatedNote, note);

      // Update selected note if it's the one being edited
      final selectedNote = ref.read(selectedWizardNoteProvider);
      if (selectedNote?.id == note.id) {
        ref
            .read(selectedWizardNoteProvider.notifier)
            .updateNote(note, updatedNote);
      }
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error during resize end: $e');
    }
  }
}
