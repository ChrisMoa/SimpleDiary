import 'package:SimpleDiary/widgets/home_widgets/diary_day_overview_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Builder(
              builder: (context) {
                return const SizedBox(
                  height: 0,
                  width: 0,
                );
              },
            ),
            _buildNotesOverviewList(context),
            const SizedBox(
              height: 20,
            ),
            // const Expanded(
            //     flex: 1, child: Text("Only a placeholder for the charts")),
          ],
        ),
      ),
      // floatingActionButton: _buildActionButton(context), // todo:
    );
  }

  Widget _buildNotesOverviewList(BuildContext context) {
    return const Expanded(
      flex: 2,
      child: DiaryDayOverviewList(),
    );
  }
}
