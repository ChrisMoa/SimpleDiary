import 'package:SimpleDiary/model/notes/note.dart';
import 'package:flutter/material.dart';

class DiaryDayNotesOverviewListItem extends StatelessWidget {
  const DiaryDayNotesOverviewListItem(
      {super.key, required this.note, required this.onSelectNote});

  final Note note;
  final void Function(Note note) onSelectNote;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            note.description.isNotEmpty ? note.description : 'no description',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
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
