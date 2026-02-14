import 'package:day_tracker/features/app/presentation/widgets/notes__overview_list.dart';
import 'package:day_tracker/features/notes/presentation/widgets/note_search_bar.dart';
import 'package:flutter/material.dart';

class NotesOverViewPage extends StatelessWidget {
  const NotesOverViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding:
          const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 0),
      child: Column(
        children: [
          const NoteSearchBar(),
          _buildNotesOverviewList(),
        ],
      ),
    );
  }

  Widget _buildNotesOverviewList() {
    return const Expanded(
      flex: 2,
      child: NotesOverviewList(),
    );
  }
}
