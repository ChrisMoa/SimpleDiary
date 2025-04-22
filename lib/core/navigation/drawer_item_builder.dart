import 'package:day_tracker/core/navigation/drawer_item.dart';
import 'package:day_tracker/features/about/presentation/pages/about_page.dart';
import 'package:day_tracker/features/app/presentation/pages/settings_page.dart';
import 'package:day_tracker/features/calendar/presentation/pages/calendar_page.dart';
import 'package:day_tracker/features/dashboard/presentation/pages/home_page.dart';
import 'package:day_tracker/features/day_rating/presentation/pages/diary_day_wizard_page.dart'; // Updated import
import 'package:day_tracker/features/notes/presentation/pages/notes_overview_page.dart';
import 'package:day_tracker/features/synchronization/presentation/pages/synchronize_page.dart';
import 'package:flutter/material.dart';

class DrawerItemProvider {
  // Liste der Drawer-Einträge
  final List<DrawerItem> _drawerItems = [
    DrawerItem("Home", Icons.home),
    DrawerItem("Settings", Icons.settings),
    DrawerItem("Calendar", Icons.calendar_month),
    DrawerItem("Diary Wizard", Icons.add_to_photos_rounded), // Updated name
    DrawerItem("Notes Overview", Icons.account_balance_wallet_sharp),
    DrawerItem("Datasynchronization", Icons.cloud_upload),
    DrawerItem("About", Icons.info_outline),
  ];
  List<DrawerItem> get getDrawerItems => _drawerItems;

  // Funktion, um die Haupt-Inhaltsseite basierend auf dem ausgewählten Eintrag anzuzeigen
  getDrawerItemWidget(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const SettingsPage();
      case 2:
        return const CalendarPage();
      case 3:
        return const DiaryDayWizardPage(); // Updated class name
      case 4:
        return const NotesOverViewPage();
      case 5:
        return const SynchronizePage();
      case 6:
        return const AboutPage();

      default:
        return const Text("Fehler: Ungültiger Eintrag");
    }
  }
}
