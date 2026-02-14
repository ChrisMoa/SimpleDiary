// ignore_for_file: unused_local_variable

import 'package:day_tracker/core/provider/theme_provider.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_wizard_providers.dart';
import 'package:day_tracker/features/day_rating/presentation/widgets/date_selector_widget.dart';
import 'package:day_tracker/features/note_templates/presentation/widgets/floating_template_button.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/data/models/note_data_source.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:day_tracker/core/log/logger_instance.dart';

class NotesCalendarWidget extends ConsumerStatefulWidget {
  const NotesCalendarWidget({super.key});

  @override
  ConsumerState<NotesCalendarWidget> createState() => _NotesCalendarWidgetState();
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
    final l10n = AppLocalizations.of(context);
    final selectedDate = ref.watch(wizardSelectedDateProvider);
    final isFullyScheduled = ref.watch(isDayFullyScheduledProvider);

    // Get screen size information for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;

    // Update calendar date when provider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarController.displayDate?.day != selectedDate.day || _calendarController.displayDate?.month != selectedDate.month || _calendarController.displayDate?.year != selectedDate.year) {
        _calendarController.displayDate = selectedDate;
      }
    });

    // Create appointments from notes
    final dataSource = NoteDataSource(notes);

    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: const DateSelectorWidget(),
              ),

              // Header with action buttons
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Schedule',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Status indicator
                    if (isFullyScheduled)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
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
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.fillInYourCompleteDay,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Calendar - Adapted to different screen sizes
              Expanded(
                child: SfCalendar(
                  controller: _calendarController,
                  view: CalendarView.day,
                  dataSource: dataSource,
                  timeSlotViewSettings: TimeSlotViewSettings(
                    // Adjust time interval for better visibility on small screens
                    timeInterval: Duration(minutes: isSmallScreen ? 60 : 30),
                    // Adjust height based on screen size
                    timeIntervalHeight: isSmallScreen ? 50 : 60,
                    timeFormat: 'HH:mm',
                    startHour: 7,
                    endHour: 22,
                    timeTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                  headerHeight: 0, // Hide header since we have our own date selector
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

              // Legend for categories - Wrap it for small screens
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ref.watch(categoryLocalDataProvider).map((category) => _buildCategoryChip(category, theme)).toList(),
                ),
              ),
            ],
          ),
          // Add FloatingTemplateButton only when keyboard is not visible
          if (!isKeyboardVisible) const FloatingTemplateButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(NoteCategory category, ThemeData theme) {
    // Make chips more compact on small screens
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 360;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8, vertical: isSmallScreen ? 2 : 4),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.color.withValues(alpha: 0.5),
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
          SizedBox(width: isSmallScreen ? 2 : 4),
          Text(
            category.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customAppointmentBuilder(BuildContext context, CalendarAppointmentDetails details) {
    final note = details.appointments.first as Note;
    final theme = ref.watch(themeProvider);
    final isSelected = ref.read(selectedWizardNoteProvider)?.id == note.id;
    final isEmpty = note.title.isEmpty && note.description.isEmpty;

    // Adjust text sizes based on available space
    final bool isSmallAppointment = details.bounds.height < 30;

    return Container(
      decoration: BoxDecoration(
        color: note.noteCategory.color.withValues(alpha: isEmpty ? 0.3 : 0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : note.noteCategory.color,
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
                      fontSize: isSmallAppointment ? 9 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isSmallAppointment)
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
    // Handle appointment tap
    if (details.targetElement == CalendarElement.appointment && details.appointments != null && details.appointments!.isNotEmpty) {
      // Select existing note
      final note = details.appointments!.first as Note;
      ref.read(selectedWizardNoteProvider.notifier).selectNote(note);
    }
  }

  void _handleDragEnd(AppointmentDragEndDetails details) {
    try {
      LogWrapper.logger.d('Note drag ended: ${details.appointment}');
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
        LogWrapper.logger.w('Dropping time was null in drag end event');
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

      LogWrapper.logger.d('Updating note after drag: ${updatedNote.id}');
      // Update in database
      ref.read(notesLocalDataProvider.notifier).editElement(updatedNote, note);

      // Update selected note if it's the one being edited
      final selectedNote = ref.read(selectedWizardNoteProvider);
      if (selectedNote?.id == note.id) {
        ref.read(selectedWizardNoteProvider.notifier).updateNote(note, updatedNote);
      }
    } catch (e) {
      // Log error but don't crash the app
      LogWrapper.logger.e('Error during drag end: $e');
    }
  }

  void _handleResizeEnd(AppointmentResizeEndDetails details) {
    try {
      LogWrapper.logger.d('Note resize ended: ${details.appointment}');
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

      LogWrapper.logger.d('Updating note after resize: ${updatedNote.id}');
      // Update in database
      ref.read(notesLocalDataProvider.notifier).editElement(updatedNote, note);

      // Update selected note if it's the one being edited
      final selectedNote = ref.read(selectedWizardNoteProvider);
      if (selectedNote?.id == note.id) {
        ref.read(selectedWizardNoteProvider.notifier).updateNote(note, updatedNote);
      }
    } catch (e) {
      // Log error but don't crash the app
      LogWrapper.logger.e('Error during resize end: $e');
    }
  }
}
