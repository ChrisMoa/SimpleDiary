import 'package:day_tracker/core/utils/responsive_breakpoints.dart';
import 'package:day_tracker/features/dashboard/domain/providers/dashboard_stats_provider.dart';
import 'package:day_tracker/features/dashboard/presentation/sections/insights_section.dart';
import 'package:day_tracker/features/dashboard/presentation/sections/statistics_section.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/favorites_section_widget.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/quick_stats_header.dart';
import 'package:day_tracker/features/dashboard/presentation/widgets/week_overview_widget.dart';
import 'package:day_tracker/features/day_rating/presentation/pages/diary_day_wizard_page.dart';
import 'package:day_tracker/features/goals/presentation/widgets/goals_section.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// New dashboard page with modern UI and statistics
class NewDashboardPage extends ConsumerStatefulWidget {
  const NewDashboardPage({super.key});

  @override
  ConsumerState<NewDashboardPage> createState() => _NewDashboardPageState();
}

class _NewDashboardPageState extends ConsumerState<NewDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Initial load
    Future.microtask(() => ref.refresh(dashboardStatsProvider));
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme to rebuild on theme changes
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= ResponsiveBreakpoints.tablet;
          final isTablet = constraints.maxWidth >= ResponsiveBreakpoints.mobile &&
              constraints.maxWidth < ResponsiveBreakpoints.tablet;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: isDesktop
                ? _buildDesktopLayout()
                : isTablet
                    ? _buildTabletLayout()
                    : _buildMobileLayout(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DiaryDayWizardPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newEntry),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: QuickStatsHeader()),
        const SliverToBoxAdapter(child: GoalsSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: WeekOverviewWidget()),
        const SliverToBoxAdapter(child: FavoritesSectionWidget()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: StatisticsSection()),
        const SliverToBoxAdapter(child: InsightsSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
      ],
    );
  }

  Widget _buildTabletLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: QuickStatsHeader()),
              const Expanded(child: WeekOverviewWidget()),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: GoalsSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: FavoritesSectionWidget()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: StatisticsSection()),
        const SliverToBoxAdapter(child: InsightsSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate sidebar width based on available space
        final sidebarWidth = constraints.maxWidth > 1400 ? 350.0 : 300.0;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Expanded(
              flex: 3,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: QuickStatsHeader()),
                  const SliverToBoxAdapter(child: GoalsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(child: WeekOverviewWidget()),
                  const SliverToBoxAdapter(child: FavoritesSectionWidget()),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(child: StatisticsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
                ],
              ),
            ),

            // Sidebar
            Container(
              width: sidebarWidth,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: const CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: InsightsSection()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
