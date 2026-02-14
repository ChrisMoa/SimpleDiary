import 'package:day_tracker/core/navigation/drawer_item.dart';
import 'package:day_tracker/features/about/presentation/pages/about_page.dart';
import 'package:day_tracker/features/app/presentation/pages/settings_page.dart';
import 'package:day_tracker/features/calendar/presentation/pages/calendar_page.dart';
import 'package:day_tracker/features/dashboard/presentation/pages/new_dashboard_page.dart';
import 'package:day_tracker/features/day_rating/presentation/pages/diary_day_wizard_page.dart';
import 'package:day_tracker/features/notes/presentation/pages/notes_overview_page.dart';
import 'package:day_tracker/features/note_templates/presentation/pages/note_template_page.dart';
import 'package:day_tracker/features/synchronization/presentation/pages/synchronize_page.dart';
import 'package:flutter/material.dart';
import 'package:day_tracker/l10n/app_localizations.dart';

class DrawerItemProvider {
  // Build drawer items with localized titles from BuildContext
  List<DrawerItem> getDrawerItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DrawerItem(l10n.drawerHome, Icons.home),
      DrawerItem(l10n.drawerSettings, Icons.settings),
      DrawerItem(l10n.drawerCalendar, Icons.calendar_month),
      DrawerItem(l10n.drawerDiaryWizard, Icons.add_to_photos_rounded),
      DrawerItem(l10n.drawerNotesOverview, Icons.account_balance_wallet_sharp),
      DrawerItem(l10n.drawerTemplates, Icons.note_alt_outlined),
      DrawerItem(l10n.drawerSync, Icons.cloud_upload),
      DrawerItem(l10n.drawerAbout, Icons.info_outline),
    ];
  }

  // Funktion, um die Haupt-Inhaltsseite basierend auf dem ausgewählten Eintrag anzuzeigen
  Widget getDrawerItemWidget(int index, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return const NewDashboardPage();
      case 1:
        return const SettingsPage();
      case 2:
        return const CalendarPage();
      case 3:
        return const DiaryDayWizardPage();
      case 4:
        return const NotesOverViewPage();
      case 5:
        return const NoteTemplatePage();
      case 6:
        return const SynchronizePage();
      case 7:
        return const AboutPage();

      default:
        return Text(l10n.drawerErrorInvalidEntry);
    }
  }
}
