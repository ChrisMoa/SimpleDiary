import 'package:SimpleDiary/pages/drawer/about_page.dart';
import 'package:SimpleDiary/pages/drawer/notes_overview_page.dart';
import 'package:SimpleDiary/pages/drawer/note_wizard_page.dart';
import 'package:SimpleDiary/pages/drawer/synchronize_page.dart';
import 'package:flutter/material.dart';
import 'package:SimpleDiary/model/DrawerItem.dart';
import 'package:SimpleDiary/pages/drawer/calendar_page.dart';
import 'package:SimpleDiary/pages/drawer/home_page.dart';
import 'package:SimpleDiary/pages/drawer/settings_page.dart';

class DrawerItemProvider {
  // Liste der Drawer-Einträge
  final List<DrawerItem> _drawerItems = [
    DrawerItem("Home", Icons.home),
    DrawerItem("Settings", Icons.settings),
    DrawerItem("Calendar", Icons.calendar_month),
    DrawerItem("Wizard", Icons.add_to_photos_rounded),
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
        return const NoteWizardPage();
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
