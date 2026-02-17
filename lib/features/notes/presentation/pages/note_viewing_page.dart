import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_attachments_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_editing_page.dart';
import 'package:day_tracker/features/notes/presentation/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteViewingPage extends ConsumerStatefulWidget {
  const NoteViewingPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteViewingPageState();
}

class _NoteViewingPageState extends ConsumerState<NoteViewingPage> {
  @override
  Widget build(BuildContext context) {
    final note = ref.watch(noteEditingPageProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: buildViewingActions(context, note),
      ),
      body: ListView(
          padding: const EdgeInsets.all(32),
          children: <Widget>[
            Text(
              note.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 32),
            buildDateTime(note),
            const SizedBox(height: 24),
            buildCategory(note),
            const SizedBox(height: 24),
            Text(
              note.description,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 24),
            ImagePickerWidget(noteId: note.id!, readOnly: true),
          ],
      ),
    );
  }

  Widget buildCategory(Note note) => Row(
        children: [
          Container(
            width: 25,
            height: 25,
            color: note.noteCategory.color,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            note.noteCategory.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      );

  buildDateTime(Note event) {
    return Column(
      children: [
        buildDate(event.isAllDay ? 'All-day' : 'From', event.from),
        if (!event.isAllDay) buildDate('To', event.to),
      ],
    );
  }

  buildDate(String title, DateTime date) {
    return Row(
      children: [
        Expanded(
          flex: 1, // gets 2/3 of width as space
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        Expanded(
          flex: 1, // gets 2/3 of width as space
          child: Text(
            Utils.toDate(date),
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        Expanded(
          flex: 1, // gets 2/3 of width as space
          child: Text(
            Utils.toTime(date),
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }

  List<Widget> buildViewingActions(BuildContext context, Note note) => [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            ref.read(noteEditingPageProvider.notifier).updateNote(note);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NoteEditingPage(
                  editNote: true,
                  navigateBack: true,
                ),
              ),
            );
          },
        ),
        IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await ref
                  .read(noteAttachmentsProvider.notifier)
                  .removeAllForNote(note.id!);
              await ref
                  .read(notesLocalDataProvider.notifier)
                  .deleteElement(note);
              if (context.mounted) Navigator.of(context).pop();
            }),
      ];
}
