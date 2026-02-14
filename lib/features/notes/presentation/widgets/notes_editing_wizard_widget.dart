import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/utils/platform_utils.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_selected_date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class NoteEditingWizardWidget extends ConsumerStatefulWidget {
  final bool navigateBack;
  final bool addAdditionalSaveButton;
  final bool editNote;
  final void Function(Note note) onSavedNote;

  const NoteEditingWizardWidget({
    super.key,
    navigateBack,
    addAdditionalSaveButton,
    editNote,
    onSaveNote,
  })  : navigateBack = navigateBack ?? true,
        addAdditionalSaveButton = addAdditionalSaveButton ?? false,
        editNote = editNote ?? false,
        onSavedNote = onSaveNote ?? _onSaveNote;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteEditingwizardWidgetState();

  static void _onSaveNote(Note note) {}
}

class _NoteEditingwizardWidgetState extends ConsumerState<NoteEditingWizardWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _oldText = '';
  final SpeechToText speechToTextInstance = SpeechToText();
  DateTime selectedDate = DateTime.now().copyWith(hour: 0, second: 0, minute: 0);
  bool _calculateNewNote = true;
  bool _isListening = false;

  Note note = Note.fromEmpty();

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

  @override
  Widget build(BuildContext contex) {
    selectedDate = ref.watch(noteSelectedDateProvider);
    if (_calculateNewNote) {
      calculateNextFreeNoteOfDay();
    }
    return buildScaffoldBody();
  }

  Widget buildScaffoldBody() => Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTitle(),
              const SizedBox(
                height: 20,
              ),
              buildDate(),
              buildTimePickers(),
              const SizedBox(
                height: 20,
              ),
              buildDescription(),
              buildMicrophone(),
              const SizedBox(
                height: 20,
              ),
              buildCategory(),
              const SizedBox(
                height: 20,
              ),
              buildButtons(),
            ],
          ),
        ),
      );

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
        },
        initialValue: note.title,
      );

  buildDate() => Container(
        alignment: Alignment.centerLeft,
        child: Text(
          'Date: ${Utils.toDate(note.from)}',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );

  Widget buildTimePickers() => Row(
        children: [
          Text(
            'from',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          Expanded(
            flex: 2,
            child: buildDropdownField(
              text: Utils.toTime(note.from),
              onClicked: () => pickTime(selectToTime: false),
            ),
          ),
          const SizedBox(
            width: 40,
          ),
          Text(
            'To',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          Expanded(
            flex: 2,
            child: buildDropdownField(
              text: Utils.toTime(note.to),
              onClicked: () => pickTime(selectToTime: true),
            ),
          ),
        ],
      );

  Widget buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: reloadForm,
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            label: const Text('reload'),
            icon: const Icon(Icons.sync),
          ),
          TextButton.icon(
            onPressed: saveForm,
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            label: const Text('save'),
            icon: const Icon(Icons.save),
          ),
        ],
      );

  Widget buildCategory() {
    final categories = ref.watch(categoryLocalDataProvider);

    // Ensure the current category exists in the list (matched by title via ==)
    if (categories.isNotEmpty && !categories.contains(note.noteCategory)) {
      note.noteCategory = categories.first;
    }

    return DropdownButtonFormField(
        value: categories.isEmpty ? null : note.noteCategory,
        items: [
          // entries is the iterable object in the map
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
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              note.noteCategory = value;
              _calculateNewNote = false;
            });
          }
        },
      );
  }

  Widget buildDescription() => buildHeader(
        header: 'Description',
        child: SizedBox(
          height: 240,
          child: TextField(
            maxLines: 10,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Add note',
            ),
            controller: _descriptionController,
          ),
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
        titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
      );

  Widget buildHeader({
    required String header,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary)),
          child,
        ],
      );

  Widget buildMicrophone() => Center(
        child: InkWell(
          onTap: () {
            LogWrapper.logger.d('Microphone button clicked');
            if (!_supportsPlatformSpeechRecognition()) {
              LogWrapper.logger.w('Speech recognition not supported on this platform');
              return;
            }
            if (speechToTextInstance.isListening) {
              LogWrapper.logger.d('Stopping speech recognition');
              _stopListeningNow();
            } else {
              LogWrapper.logger.d('Starting speech recognition');
              _startListeningNow();
            }
          },
          child: _isListening
              ? Center(
                  child: LoadingAnimationWidget.beat(
                    size: 30,
                    color: _isListening ? Colors.deepPurple : Colors.deepPurple[200]!,
                  ),
                )
              : Image.asset(
                  "assets/images/assistant_icon.png",
                  height: 30,
                  width: 30,
                ),
        ),
      );

  Future pickTime({required bool selectToTime}) async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectToTime ? TimeOfDay.fromDateTime(note.from.add(const Duration(minutes: 30))) : TimeOfDay.fromDateTime(note.from),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container(),
        );
      },
    );

    if (timeOfDay == null) {
      return null;
    }

    final date = DateTime(note.from.year, note.from.month, note.from.day, timeOfDay.hour, timeOfDay.minute);

    setState(() {
      selectToTime ? note.to = date : note.from = date;
      _calculateNewNote = false;
    });
  }

  void saveForm() {
    LogWrapper.logger.t('saves now the note ${note.title} to database');
    _formKey.currentState!.validate();
    _formKey.currentState!.save();

    // load the missing note parts
    note.description = _descriptionController.text;

    /// save the note
    try {
      ref.read(noteEditingPageProvider.notifier).updateNote(note);
      if (widget.editNote) {
        ref.read(notesLocalDataProvider.notifier).editElement(note, note);
      } else {
        ref.read(notesLocalDataProvider.notifier).addElement(note);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('was not be able to update note'),
        ),
      );
    }

    /// update ui
    if (widget.navigateBack) {
      Navigator.of(context).pop();
    }
    _formKey.currentState!.reset();

    setState(() {
      _descriptionController.text = "";
      _calculateNewNote = true;
    });
  }

  void reloadForm() {
    setState(() {
      _calculateNewNote = true;
      _descriptionController.text = "";
    });
  }

  bool _supportsPlatformSpeechRecognition() {
    return activePlatform.platform == (ActivePlatform.android) || activePlatform.platform == (ActivePlatform.ios);
  }

  Future<void> _initializeSpeechToText() async {
    if (_supportsPlatformSpeechRecognition()) {
      try {
        final initialized = await speechToTextInstance.initialize(
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
        }
      } catch (e) {
        LogWrapper.logger.w('Speech recognition initialization error: $e');
      }
    }
  }

  Future<void> _startListeningNow() async {
    LogWrapper.logger.d('Initializing speech recognition');
    if (_supportsPlatformSpeechRecognition()) {
      FocusScope.of(context).unfocus();
      _oldText = _descriptionController.text;
      await speechToTextInstance.listen(
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
    LogWrapper.logger.d('Stopping speech recognition');
    if (_supportsPlatformSpeechRecognition()) {
      await speechToTextInstance.stop();
      setState(() {
        _descriptionController.text = _descriptionController.text.replaceAll(RegExp(r'Notiz Ende'), '');
        _isListening = false;
      });
    }
  }

  Future<void> _onSpeechToTextResult(SpeechRecognitionResult recognitionResult) async {
    LogWrapper.logger.d('Speech recognition result received');
    var text = recognitionResult.recognizedWords;
    if (_oldText.isNotEmpty) {
      text = "$_oldText $text";
    }
    text.replaceAll(RegExp('%unkt'), '. ');
    text.replaceAll(RegExp('%omma'), ', ');
    setState(() {
      if (text.contains('Notiz Ende')) {
        LogWrapper.logger.d('End command detected, stopping speech recognition');
        _stopListeningNow();
      }
      _descriptionController.text = text;
      note.description = text;
      _calculateNewNote = false;
    });
    if (speechToTextInstance.isNotListening) {
      LogWrapper.logger.d('Speech recognition stopped, restarting');
      _startListeningNow();
    }
  }

  void calculateNextFreeNoteOfDay() {
    final selectedDate = ref.read(noteSelectedDateProvider);
    final notesOfDay = ref.read(notesOfSelecteDayProvider);
    final defaultCategory = ref.read(defaultCategoryProvider);
    LogWrapper.logger.t('updates notes of day ${Utils.toDate(selectedDate)}');

    final dayBegin = selectedDate.copyWith(hour: 7, minute: 0, second: 0);
    final dayEnd = selectedDate.copyWith(hour: 22, minute: 0, second: 0);

    var timeIncrease = 15; // check 15minute chunks
    var curTime = dayBegin;
    var stop = notesOfDay.isEmpty;
    for (; curTime.isBefore(dayEnd) && !stop; curTime = curTime.add(Duration(minutes: timeIncrease))) {
      int timeSlotAtIndex = -1;
      for (final note in notesOfDay) {
        if (Utils.isDateTimeWithinTimeSpan(curTime, note.from, note.to)) {
          timeSlotAtIndex = notesOfDay.indexOf(note);
        }
      }
      if (timeSlotAtIndex == -1) {
        curTime = curTime.add(Duration(minutes: -timeIncrease));
        break;
      } else {
        curTime = notesOfDay[timeSlotAtIndex].to;
      }
    }
    if (curTime.isBefore(dayBegin)) {
      curTime = dayBegin;
    }

    // Use default category if available, otherwise create a temporary one
    final noteCategory = defaultCategory ?? NoteCategory(
      title: 'Default',
      color: Colors.blue,
    );

    note = Note(
      title: '',
      description: '',
      from: curTime,
      to: curTime.add(const Duration(minutes: 30)),
      noteCategory: noteCategory,
    );
  }
}
