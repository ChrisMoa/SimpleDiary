import 'package:SimpleDiary/widgets/home_widgets/notes__overview_list.dart';
import 'package:flutter/material.dart';

class NotesOverViewPage extends StatelessWidget {
  const NotesOverViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 0),
      child: Column(
        children: [
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
