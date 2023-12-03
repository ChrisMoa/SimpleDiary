import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/note_editing_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:SimpleDiary/pages/note_editing_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SimpleDiary/model/notes/note.dart';
import 'package:SimpleDiary/utils.dart';

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.background,
        child: ListView(
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
          ],
        ),
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
            onPressed: () {
              ref.read(notesLocalDataProvider.notifier).deleteElement(note);
              Navigator.of(context).pop();
            }),
      ];
}
