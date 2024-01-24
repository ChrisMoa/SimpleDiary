import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/note_selected_date_provider.dart';
import 'package:SimpleDiary/utils.dart';
import 'package:SimpleDiary/widgets/diary_day_editing_wizard_widget.dart';
import 'package:SimpleDiary/widgets/notes_day_view_widget.dart';
import 'package:SimpleDiary/widgets/notes_editing_wizard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteWizardPage extends ConsumerStatefulWidget {
  const NoteWizardPage({super.key});

  @override
  ConsumerState<NoteWizardPage> createState() => _NoteWizardPageState();
}

enum WizardState { editNotes, editDiaryDay, finished }

class _NoteWizardPageState extends ConsumerState<NoteWizardPage> {
  DateTime _selectedDate = DateTime.now();
  WizardState wizardState = WizardState.editNotes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget wizardWidget;
    if (!isNotesOfSelectedDayFinished()) {
      wizardWidget = buildEditNotes();
    } else if (!isDiaryDayOfSelectedDayComplete()) {
      wizardWidget = buildEditDiaryDay();
    } else {
      wizardWidget = buildWizardFinished();
    }
    ref.read(notesLocalDataProvider.notifier).readObjectsFromDatabase();
    _selectedDate = ref.watch(noteSelectedDateProvider);

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          buildSelectDateDropdown(context),
          const SizedBox(height: 15),
          buildNotesOfDayOverview(context),
          const SizedBox(height: 15),
          wizardWidget,
        ],
      ),
    );
  }

  Widget buildWizardFinished() {
    return Center(
      child: Text(
        'No further notes for the selected date',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  Widget buildEditNotes() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 50,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(25),
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onBackground,
            Theme.of(context).colorScheme.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: NoteEditingWizardWidget(
        navigateBack: false,
        key: widget.key,
        addAdditionalSaveButton: true,
        editNote: false,
      ),
    );
  }

  Widget buildEditDiaryDay() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 50,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(25),
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onBackground,
            Theme.of(context).colorScheme.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const DiaryDayEditingWizardWidget(),
    );
  }

  buildNotesOfDayOverview(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onBackground,
            Theme.of(context).colorScheme.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 5,
      ),
      child: const SizedBox(
        height: 140,
        child: NotesViewDayWidget(),
      ),
    );
  }

  Widget buildSelectDateDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onBackground,
            Theme.of(context).colorScheme.background,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(50),
        ),
      ),
      child: ListTile(
        title: Text(
          Utils.toDate(_selectedDate),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2015),
            lastDate: DateTime(2101),
            locale: const Locale("de", "DE"),
          );
          if (date != null) {
            setState(() {
              _selectedDate = date;
              ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(date);
            });
          }
        },
      ),
    );
  }

  bool isNotesOfSelectedDayFinished() {
    final selectedDate = ref.watch(noteSelectedDateProvider);
    final notesOfDay = ref.watch(notesOfSelecteDayProvider);

    LogWrapper.logger.t('updates day finished provider for day ${Utils.toDateTime(selectedDate)}');

    final dayBegin = selectedDate.copyWith(hour: 7, minute: 0, second: 0);
    final dayEnd = selectedDate.copyWith(hour: 22, minute: 0, second: 0);

    var timeIncrease = 15; // check 15minute chunks

    for (var curTime = dayBegin; curTime.isBefore(dayEnd); curTime = curTime.add(Duration(minutes: timeIncrease))) {
      bool found = false;
      for (final note in notesOfDay) {
        if (Utils.isDateTimeWithinTimeSpan(curTime, note.from, note.to)) {
          found = true;
          break;
        }
      }
      // time chunk not found -> can break
      if (!found) {
        return false;
      }
    }

    // all chunks are found -> return true
    return true;
  }

  bool isDiaryDayOfSelectedDayComplete() {
    final complete = ref.watch(isDiaryOfDayCompleteProvider);
    if (complete == null) {
      return false;
    } else {
      return complete;
    }
  }
}
