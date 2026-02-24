import 'package:day_tracker/features/dashboard/presentation/widgets/diary_day_overview_list.dart';
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
            _buildNotesOverviewList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesOverviewList(BuildContext context) {
    return const Expanded(
      flex: 2,
      child: DiaryDayOverviewList(),
    );
  }
}
