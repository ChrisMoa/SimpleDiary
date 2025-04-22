import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
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
  final _uuid = const Uuid();

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

    // Update calendar date when provider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarController.displayDate?.day != selectedDate.day ||
          _calendarController.displayDate?.month != selectedDate.month ||
          _calendarController.displayDate?.year != selectedDate.year) {
        _calendarController.displayDate = selectedDate;
        _calendarController.selectedDate = selectedDate;
      }
    });

    // Create appointments from notes
    final appointments = notes
        .map((note) => Appointment(
              id: note.id,
              subject: note.title.isEmpty ? 'New Note' : note.title,
              notes: note.description,
              startTime: note.from,
              endTime: note.to,
              color: note.noteCategory.color,
            ))
        .toList();

    final dataSource = _AppointmentDataSource(appointments);

    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Schedule',
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addNextFreeNote,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SfCalendar(
                controller: _calendarController,
                view: CalendarView.day,
                dataSource: dataSource,
                timeSlotViewSettings: TimeSlotViewSettings(
                  timeInterval: const Duration(minutes: 15),
                  timeIntervalHeight: 50,
                  timeFormat: 'HH:mm',
                  startHour: 7,
                  endHour: 22,
                ),
                initialDisplayDate: selectedDate,
                initialSelectedDate: selectedDate,
                onTap: _handleCalendarTap,
                appointmentBuilder: _customAppointmentBuilder,
                allowDragAndDrop: true,
                allowAppointmentResize: true,
                onDragEnd: _handleDragEnd,
                onAppointmentResizeEnd: _handleResizeEnd,
                onViewChanged: (ViewChangedDetails details) {
                  if (details.visibleDates.isNotEmpty) {
                    final midDate =
                        details.visibleDates[details.visibleDates.length ~/ 2];
                    final newDate = DateTime(midDate.year, midDate.month,
                        midDate.day, selectedDate.hour, selectedDate.minute);

                    if (newDate.day != selectedDate.day ||
                        newDate.month != selectedDate.month ||
                        newDate.year != selectedDate.year) {
                      ref
                          .read(wizardSelectedDateProvider.notifier)
                          .updateSelectedDate(newDate);
                      LogWrapper.logger.d(
                          'Calendar date changed to: ${Utils.toDate(newDate)}');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customAppointmentBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    final appointment = details.appointments.first as Appointment;

    bool isEmpty = appointment.subject == 'New Note' &&
        (appointment.notes == null || appointment.notes!.isEmpty);

    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
        color: isEmpty
            ? appointment.color.withOpacity(0.3)
            : appointment.color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: appointment.color,
          width: isEmpty ? 1 : 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.subject,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (details.bounds.height > 30 &&
                appointment.notes != null &&
                appointment.notes!.isNotEmpty)
              Expanded(
                child: Text(
                  appointment.notes!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                  maxLines: (details.bounds.height / 15).floor() - 1,
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
      final appointment = details.appointments!.first as Appointment;
      final noteId = appointment.id.toString();

      // Find and select the note
      final notes = ref.read(wizardDayNotesProvider);
      final tappedNote = notes.firstWhere(
        (note) => note.id == noteId,
        orElse: () => Note.fromEmpty(),
      );

      if (tappedNote.id != null) {
        ref.read(selectedWizardNoteProvider.notifier).selectNote(tappedNote);
        LogWrapper.logger.d('Selected note: ${tappedNote.id}');
      }
    }
  }

  void _addNextFreeNote() {
    // Get the next available time slot
    final nextStartTime = ref.read(nextAvailableTimeSlotProvider);

    // Create a new note with 30-minute duration
    final newNote = Note(
      id: _uuid.v4(),
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

    LogWrapper.logger.d(
      'Created new note: ${newNote.id} at ${Utils.toDateTime(nextStartTime)}',
    );

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added new note at ${Utils.toTime(nextStartTime)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDragEnd(AppointmentDragEndDetails details) {
    try {
      final appointment = details.appointment as Appointment;
      final noteId = appointment.id.toString();

      // Find the note
      final notes = ref.read(wizardDayNotesProvider);
      final noteToUpdate = notes.firstWhere(
        (note) => note.id == noteId,
        orElse: () => Note.fromEmpty(),
      );

      if (noteToUpdate.id != null) {
        // Create updated note with new times
        final updatedNote = Note(
          id: noteToUpdate.id,
          title: noteToUpdate.title,
          description: noteToUpdate.description,
          from: appointment.startTime,
          to: appointment.endTime,
          noteCategory: noteToUpdate.noteCategory,
          isAllDay: noteToUpdate.isAllDay,
        );

        // Update in database
        ref
            .read(notesLocalDataProvider.notifier)
            .editElement(updatedNote, noteToUpdate);

        // Update selected note if it's the one being edited
        final selectedNote = ref.read(selectedWizardNoteProvider);
        if (selectedNote?.id == noteId) {
          ref
              .read(selectedWizardNoteProvider.notifier)
              .updateNote(noteToUpdate, updatedNote);
        }

        LogWrapper.logger.d(
          'Note moved: ${noteToUpdate.id} to ${Utils.toDateTime(updatedNote.from)}-${Utils.toTime(updatedNote.to)}',
        );
      }
    } catch (e) {
      LogWrapper.logger.e('Error during drag end: $e');
    }
  }

  void _handleResizeEnd(AppointmentResizeEndDetails details) {
    try {
      final appointment = details.appointment as Appointment;
      final noteId = appointment.id.toString();

      // Find the note
      final notes = ref.read(wizardDayNotesProvider);
      final noteToUpdate = notes.firstWhere(
        (note) => note.id == noteId,
        orElse: () => Note.fromEmpty(),
      );

      if (noteToUpdate.id != null) {
        // Create updated note with new times
        final updatedNote = Note(
          id: noteToUpdate.id,
          title: noteToUpdate.title,
          description: noteToUpdate.description,
          from: details.startTime ?? appointment.startTime,
          to: details.endTime ?? appointment.endTime,
          noteCategory: noteToUpdate.noteCategory,
          isAllDay: noteToUpdate.isAllDay,
        );

        // Update in database
        ref
            .read(notesLocalDataProvider.notifier)
            .editElement(updatedNote, noteToUpdate);

        // Update selected note if it's the one being edited
        final selectedNote = ref.read(selectedWizardNoteProvider);
        if (selectedNote?.id == noteId) {
          ref
              .read(selectedWizardNoteProvider.notifier)
              .updateNote(noteToUpdate, updatedNote);
        }

        LogWrapper.logger.d(
          'Note resized: ${noteToUpdate.id} to ${Utils.toDateTime(updatedNote.from)}-${Utils.toTime(updatedNote.to)}',
        );
      }
    } catch (e) {
      LogWrapper.logger.e('Error during resize end: $e');
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
