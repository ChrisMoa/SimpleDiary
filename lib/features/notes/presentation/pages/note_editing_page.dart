import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteEditingPage extends ConsumerStatefulWidget {
  final bool navigateBack;
  final bool addAdditionalSaveButton;
  final bool editNote;
  final void Function(Note note) onSavedNote;

  const NoteEditingPage({
    Key? key,
    navigateBack,
    addAdditionalSaveButton,
    editNote,
    onSaveNote,
  })  : navigateBack = navigateBack ?? true,
        addAdditionalSaveButton = addAdditionalSaveButton ?? false,
        editNote = editNote ?? false,
        onSavedNote = onSaveNote ?? _onSaveNote,
        super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteEditingPageState();

  static void _onSaveNote(Note note) {}
}

class _NoteEditingPageState extends ConsumerState<NoteEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  Note note = Note.fromEmpty();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contex) {
    note = ref.watch(noteEditingPageProvider);
    if (!widget.navigateBack) {
      return buildScaffoldBody(context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: buildEditingActions(),
      ),
      body: buildScaffoldBody(context),
    );
  }

  Widget buildScaffoldBody(BuildContext context) => Form(
        key: _formKey,
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              buildTitle(),
              const SizedBox(
                height: 20,
              ),
              buildDateTimePickers(),
              const SizedBox(
                height: 20,
              ),
              buildAllDayCheckbox(),
              const SizedBox(
                height: 20,
              ),
              buildDescription(),
              const SizedBox(
                height: 20,
              ),
              buildCategory(),
              const SizedBox(
                height: 20,
              ),
              if (widget.addAdditionalSaveButton)
                Row(
                  children: [
                    TextButton(
                      onPressed: saveForm,
                      child: const Text('save'),
                    ),
                    TextButton(
                      onPressed: reloadForm,
                      child: const Text('reload'),
                    ),
                  ],
                )
            ],
          ),
        ),
      );

  List<Widget> buildEditingActions() => [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          onPressed: saveForm,
          icon: const Icon(Icons.done),
          label: const Text('SAVE'),
        ),
      ];

  buildTitle() => TextFormField(
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onSaved: (newValue) {
          if (newValue == null || newValue == '') {
            throw ('title is empty');
          }
          note.title = newValue;
          ref.read(noteEditingPageProvider.notifier).updateNote(note);
        },
        initialValue: note.title,
        // validator: (title) =>
        //     title != null && title.isEmpty ? 'Title cannot be empty' : null,
        // controller: titleController,
      );

  Widget buildDateTimePickers() => Column(
        children: [
          buildFrom(),
          buildTo(),
        ],
      );

  Widget buildCategory() {
    final categories = ref.watch(categoryLocalDataProvider);

    // Ensure the note's category exists in the dropdown items
    if (categories.isNotEmpty && !categories.contains(note.noteCategory)) {
      note.noteCategory = categories.first;
    }

    return DropdownButtonFormField(
        value: categories.isEmpty ? null : note.noteCategory,
        items: [
          for (final category in categories)
            DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: category.color,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    category.title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              note.noteCategory = value;
              ref.read(noteEditingPageProvider.notifier).updateNote(note);
            });
          }
        },
      );
  }

  Widget buildDescription() => buildHeader(
        header: 'Description',
        child: SizedBox(
          height: 240,
          child: TextFormField(
            maxLines: 10,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Add note',
            ),
            initialValue: note.description,
            onSaved: (newValue) {
              if (newValue == null || newValue == '') {
                throw ('description is empty');
              }
              note.description = newValue;
              ref.read(noteEditingPageProvider.notifier).updateNote(note);
            },
            // controller: descriptionController,
            // validator: (value) => null, // always true
          ),
        ),
      );

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.primaryContainer;
  }

  Widget buildAllDayCheckbox() => Row(children: [
        Text(
          'AllDay?',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        Checkbox(
          value: note.isAllDay,
          checkColor: Theme.of(context).colorScheme.onPrimary,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          onChanged: (bool? value) {
            setState(() {
              note.isAllDay = value!;
              ref.read(noteEditingPageProvider.notifier).updateNote(note);
            });
          },
        ),
      ]);

  Widget buildFrom() => buildHeader(
        header: 'FROM',
        child: Row(
          children: [
            Expanded(
              flex: 2, // gets 2/3 of width as space
              child: buildDropdownField(
                text: Utils.toDate(note.from),
                onClicked: () => pickFromDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                text: Utils.toTime(note.from),
                onClicked: () => pickFromDateTime(pickDate: false),
              ),
            ),
          ],
        ),
      );

  Widget buildTo() => buildHeader(
        header: 'To',
        child: Row(
          children: [
            Expanded(
              flex: 2, // gets 2/3 of width as space
              child: buildDropdownField(
                text: Utils.toDate(note.to),
                onClicked: () => pickToDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                text: Utils.toTime(note.to),
                onClicked: () => pickToDateTime(pickDate: false),
              ),
            ),
          ],
        ),
      );

  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: onClicked,
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Theme.of(context).colorScheme.secondary),
      );

  Widget buildHeader({
    required String header,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary)),
          child,
        ],
      );

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(
      note.from,
      pickDate: pickDate,
    );
    if (date == null) {
      return;
    }

    if (date.isAfter(note.to)) {
      note.to = date.add(const Duration(hours: 1));
    }
    setState(() {
      note.from = date;
      ref.read(noteEditingPageProvider.notifier).updateNote(note);
    });
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(
      note.to,
      pickDate: pickDate,
      firstDate: pickDate ? note.from : null,
    );
    if (date == null) {
      return;
    }
    setState(() {
      note.to = date;
      ref.read(noteEditingPageProvider.notifier).updateNote(note);
    });
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      // pick date
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2015, 8),
        lastDate: DateTime(2101),
        locale: const Locale("de", "DE"),
      );
      if (date == null) {
        return null;
      } else {
        return date.add(
            Duration(hours: initialDate.hour, minutes: initialDate.minute));
      }
    } else {
      // pick time

      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? Container(),
          );
        },
      );

      if (timeOfDay == null) {
        return null;
      } else {
        final date =
            DateTime(initialDate.year, initialDate.month, initialDate.day);
        final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
        return date.add(time);
      }
    }
  }

  void saveForm() {
    LogWrapper.logger.t('saves now the note ${note.title} to database');
    _formKey.currentState!.validate();
    _formKey.currentState!.save();

    /// save the note
    if (widget.editNote) {
      ref.read(notesLocalDataProvider.notifier).editElement(note, note);
    } else {
      ref.read(notesLocalDataProvider.notifier).addElement(note);
    }

    /// update ui
    if (widget.navigateBack) {
      Navigator.of(context).pop();
    } else {
      reloadForm();
    }
  }

  void reloadForm() {
    note = ref.read(nextFreeNoteOfSelectedDateProvider);
    ref.read(noteSelectedDateProvider.notifier).updateSelectedDate(note.to);
    ref.read(noteEditingPageProvider.notifier).updateNote(note);
    _formKey.currentState!.reset();
  }
}
