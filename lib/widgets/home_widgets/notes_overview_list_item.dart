import 'package:SimpleDiary/model/notes/note.dart';
import 'package:SimpleDiary/utils.dart';
import 'package:flutter/material.dart';

class NotesOverviewListItem extends StatelessWidget {
  const NotesOverviewListItem(
      {super.key, required this.note, required this.onSelectNote});

  final Note note;
  final void Function(Note note) onSelectNote;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.onBackground,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () {
          onSelectNote(note);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${note.from.day}',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                        ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    Utils.printMonth(note.from),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: note.noteCategory.color,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Text(
                note.description.isNotEmpty
                    ? note.description
                    : 'no description',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// child: ListTile(
//             title: Text(
//               note.title,
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge!
//                   .copyWith(color: Theme.of(context).colorScheme.primary),
//             ),
//             leading: const Icon(Icons.note),
//             trailing: Text(note.description),
            
//           ),
