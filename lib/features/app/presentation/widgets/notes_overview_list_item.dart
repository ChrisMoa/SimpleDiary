import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:flutter/material.dart';

class NotesOverviewListItem extends StatelessWidget {
  const NotesOverviewListItem(
      {super.key, required this.note, required this.onSelectNote});

  final Note note;
  final void Function(Note note) onSelectNote;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.paddingAllXs,
      color: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusSm,
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
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                        ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    Utils.printMonth(note.from),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.secondary,
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
