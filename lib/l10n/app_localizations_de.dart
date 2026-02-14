// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Simple Diary';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerSettings => 'Einstellungen';

  @override
  String get drawerCalendar => 'Kalender';

  @override
  String get drawerDiaryWizard => 'Tagebuch-Assistent';

  @override
  String get drawerNotesOverview => 'Notizenübersicht';

  @override
  String get drawerTemplates => 'Vorlagen';

  @override
  String get drawerSync => 'Datensynchronisation';

  @override
  String get drawerAbout => 'Über';

  @override
  String get drawerErrorInvalidEntry => 'Fehler: Ungültiger Eintrag';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get saveSettings => 'Einstellungen speichern';

  @override
  String get settingsSavedSuccessfully =>
      'Einstellungen erfolgreich gespeichert';

  @override
  String errorSavingSettings(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get noteCategories => 'Notiz-Kategorien';

  @override
  String get manageCategoriesAndTags =>
      'Verwalte deine Notiz-Kategorien und Tags';

  @override
  String get manageCategories => 'Kategorien verwalten';

  @override
  String get themeSettings => 'Design-Einstellungen';

  @override
  String get customizeAppearance =>
      'Passe das Erscheinungsbild deiner Tagebuch-App an.';

  @override
  String get themeColor => 'Designfarbe';

  @override
  String get clickColorToChange => 'Klicke auf diese Farbe, um sie zu ändern';

  @override
  String get themeMode => 'Designmodus';

  @override
  String get toggleDarkMode => 'Schalte zwischen dunklem und hellem Design um';

  @override
  String get selectColor => 'Farbe wählen';

  @override
  String get selectColorShade => 'Farbton wählen';

  @override
  String get selectedColorAndShades =>
      'Ausgewählte Farbe und ihre Schattierungen';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get languageDescription =>
      'Wähle die Sprache für die Benutzeroberfläche.';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get email => 'E-Mail';

  @override
  String get emailOptional => 'E-Mail (optional)';

  @override
  String get login => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get signIn => 'Anmelden';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get alreadyHaveAccount => 'Ich habe bereits ein Konto';

  @override
  String get remoteAccount => 'Remote-Konto?';

  @override
  String get pleaseEnterUsername => 'Bitte Benutzernamen eingeben';

  @override
  String get pleaseEnterPassword => 'Bitte Passwort eingeben';

  @override
  String get pleaseEnterYourPassword => 'Bitte gib dein Passwort ein';

  @override
  String get passwordMinLength =>
      'Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get pleaseEnterValidEmail =>
      'Bitte eine gültige E-Mail-Adresse eingeben';

  @override
  String get authenticationError => 'Authentifizierungsfehler';

  @override
  String get invalidUsernameOrPassword =>
      'Ungültiger Benutzername oder Passwort. Bitte versuche es erneut.';

  @override
  String unexpectedError(String error) {
    return 'Ein unerwarteter Fehler ist aufgetreten: $error';
  }

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get enterPasswordToContinue =>
      'Gib dein Passwort ein, um fortzufahren';

  @override
  String get incorrectPassword => 'Falsches Passwort';

  @override
  String get switchUser => 'Benutzer wechseln';

  @override
  String get accountSettings => 'Kontoeinstellungen';

  @override
  String get save => 'Speichern';

  @override
  String get logout => 'Abmelden';

  @override
  String get doYouWantToLogout => 'Möchtest du dich abmelden?';

  @override
  String get doYouWantToOverwriteUserdata =>
      'Möchtest du deine Benutzerdaten überschreiben?';

  @override
  String get logoutTitle => 'Abmelden';

  @override
  String get logoutMessage => 'Bist du sicher, dass du dich abmelden möchtest?';

  @override
  String get stayHere => 'Hier bleiben';

  @override
  String get today => 'Heute';

  @override
  String get recorded => 'Eingetragen';

  @override
  String get pending => 'Ausstehend';

  @override
  String get recordToday => 'Heute eintragen';

  @override
  String get dayStreak => 'Tage Streak';

  @override
  String get weeklyAverage => 'Wochendurchschnitt';

  @override
  String get status => 'Status';

  @override
  String get newEntry => 'Neuer Eintrag';

  @override
  String errorWithMessage(String error) {
    return 'Fehler: $error';
  }

  @override
  String get sevenDayOverview => '7-Tage-Übersicht';

  @override
  String get ratingTrend => 'Bewertungstrend';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get insightsAndAchievements => 'Insights & Erfolge';

  @override
  String errorLoadingInsights(String error) {
    return 'Fehler beim Laden der Insights: $error';
  }

  @override
  String weekNumber(int number) {
    return 'Woche $number';
  }

  @override
  String get milestoneReached =>
      'Du hast einen wichtigen Meilenstein erreicht!';

  @override
  String get perfectWeek => 'Perfekte Woche!';

  @override
  String get perfectWeekDescription =>
      'Du hast alle Tage diese Woche eingetragen!';

  @override
  String get notRecordedToday => 'Heute noch nicht eingetragen';

  @override
  String get rememberToRate =>
      'Vergiss nicht, deinen heutigen Tag zu bewerten!';

  @override
  String get bestCategory => 'Beste Kategorie';

  @override
  String bestCategoryDescription(String category) {
    return 'Deine beste Kategorie diese Woche: $category!';
  }

  @override
  String dayDetail(String date) {
    return 'Tagesdetail: $date';
  }

  @override
  String get noDiaryEntryForDay => 'Kein Tagebucheintrag für diesen Tag';

  @override
  String errorLoadingNotes(String error) {
    return 'Fehler beim Laden der Notizen: $error';
  }

  @override
  String errorLoadingDiaryDay(String error) {
    return 'Fehler beim Laden des Tagebucheintrags: $error';
  }

  @override
  String get addANote => 'Notiz hinzufügen';

  @override
  String get daySummary => 'Tageszusammenfassung';

  @override
  String get notesAndActivities => 'Notizen & Aktivitäten';

  @override
  String nEntries(int count) {
    return '$count Einträge';
  }

  @override
  String get noNotesForDay => 'Keine Notizen für diesen Tag';

  @override
  String get addThoughtsActivitiesMemories =>
      'Füge deine Gedanken, Aktivitäten oder Erinnerungen hinzu';

  @override
  String get editNote => 'Notiz bearbeiten';

  @override
  String get allDay => 'Ganztägig';

  @override
  String overallMood(String mood) {
    return 'Gesamtstimmung: $mood';
  }

  @override
  String get deleteDiaryEntry => 'Tagebucheintrag löschen';

  @override
  String get confirmDeleteDiaryEntry =>
      'Bist du sicher, dass du diesen Tagebucheintrag löschen möchtest? Dies entfernt sowohl die Tagesbewertung als auch alle zugehörigen Notizen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get create => 'Erstellen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get ratingPoor => 'Schlecht';

  @override
  String get ratingFair => 'Mäßig';

  @override
  String get ratingGood => 'Gut';

  @override
  String get ratingGreat => 'Sehr gut';

  @override
  String get ratingExcellent => 'Ausgezeichnet';

  @override
  String get moodToughDay => 'Schwieriger Tag';

  @override
  String get moodCouldBeBetter => 'Könnte besser sein';

  @override
  String get moodPrettyGood => 'Ziemlich gut';

  @override
  String get moodGreatDay => 'Toller Tag';

  @override
  String get moodPerfectDay => 'Perfekter Tag';

  @override
  String get noDiaryEntriesYet => 'Noch keine Tagebucheinträge';

  @override
  String get startTrackingDescription =>
      'Beginne deinen Tag zu verfolgen, indem du Notizen\nhinzufügst und tägliche Bewertungen abschließt';

  @override
  String get startTodaysJournal => 'Heutiges Tagebuch starten';

  @override
  String get confirmDeletion => 'Löschung bestätigen';

  @override
  String get confirmDeleteDiaryEntryShort =>
      'Bist du sicher, dass du diesen Tagebucheintrag löschen möchtest?';

  @override
  String get diaryEntryDeleted => 'Tagebucheintrag gelöscht';

  @override
  String get undo => 'Rückgängig';

  @override
  String get loadingDayData => 'Lade deine Tagesdaten...';

  @override
  String get calendar => 'Kalender';

  @override
  String get noteDetails => 'Notizdetails';

  @override
  String get dayRating => 'Tagesbewertung';

  @override
  String get howWasYourDay =>
      'Wie war dein Tag? Bewerte die verschiedenen Aspekte deines Erlebens.';

  @override
  String get saveDayRating => 'Tagesbewertung speichern';

  @override
  String get dayRatingSaved => 'Tagesbewertung erfolgreich gespeichert!';

  @override
  String get notRated => 'Nicht bewertet';

  @override
  String get ratingSocialDescription =>
      'Wie waren deine sozialen Interaktionen und Beziehungen heute?';

  @override
  String get ratingProductivityDescription =>
      'Wie produktiv warst du bei deiner Arbeit oder deinen täglichen Aufgaben?';

  @override
  String get ratingSportDescription =>
      'Wie war deine körperliche Aktivität und Bewegung heute?';

  @override
  String get ratingFoodDescription =>
      'Wie gesund und zufriedenstellend war deine Ernährung heute?';

  @override
  String get tapToChangeDate => 'Tippe, um das Datum zu ändern';

  @override
  String get previousDay => 'Vorheriger Tag';

  @override
  String get selectDate => 'Datum wählen';

  @override
  String get nextDay => 'Nächster Tag';

  @override
  String get addTitle => 'Titel hinzufügen';

  @override
  String get addNote => 'Notiz hinzufügen';

  @override
  String get description => 'Beschreibung';

  @override
  String get allDayQuestion => 'Ganztägig?';

  @override
  String get from => 'VON';

  @override
  String get to => 'Bis';

  @override
  String get saveUpperCase => 'SPEICHERN';

  @override
  String get saveWord => 'speichern';

  @override
  String get reload => 'neu laden';

  @override
  String get noteUpdateError => 'Notiz konnte nicht aktualisiert werden';

  @override
  String dateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get organizeCategoriesDescription =>
      'Organisiere deine Notizen mit eigenen Kategorien';

  @override
  String get noCategoriesYet => 'Noch keine Kategorien';

  @override
  String get createCategoriesToOrganize =>
      'Erstelle Kategorien, um deine Notizen zu organisieren';

  @override
  String get createCategory => 'Kategorie erstellen';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get categoryName => 'Kategoriename';

  @override
  String get categoryColor => 'Kategoriefarbe';

  @override
  String get preview => 'Vorschau';

  @override
  String get pleaseEnterCategoryName => 'Bitte einen Kategorienamen eingeben';

  @override
  String get categoryAlreadyExists =>
      'Eine Kategorie mit diesem Namen existiert bereits';

  @override
  String get categoryUpdated => 'Kategorie aktualisiert';

  @override
  String get categoryCreated => 'Kategorie erstellt';

  @override
  String get categoryDeleted => 'Kategorie gelöscht';

  @override
  String get cannotDeleteCategory => 'Kategorie kann nicht gelöscht werden';

  @override
  String categoryInUse(String title) {
    return 'Die Kategorie \"$title\" wird von einer oder mehreren Notizen verwendet. Bitte weise diese Notizen zuerst neu zu oder lösche sie.';
  }

  @override
  String get deleteCategory => 'Kategorie löschen';

  @override
  String confirmDeleteCategory(String title) {
    return 'Bist du sicher, dass du \"$title\" löschen möchtest?';
  }

  @override
  String get editCategoryTooltip => 'Kategorie bearbeiten';

  @override
  String get deleteCategoryTooltip => 'Kategorie löschen';

  @override
  String get defaultCategoryWork => 'Arbeit';

  @override
  String get defaultCategoryLeisure => 'Freizeit';

  @override
  String get defaultCategoryFood => 'Essen';

  @override
  String get defaultCategoryGym => 'Gym';

  @override
  String get defaultCategorySleep => 'Schlafen';

  @override
  String get noteTemplates => 'Notiz-Vorlagen';

  @override
  String get selectTemplate => 'Vorlage auswählen';

  @override
  String get noTemplatesAvailable => 'Keine Vorlagen verfügbar';

  @override
  String get noTemplatesYet => 'Noch keine Vorlagen';

  @override
  String get createTemplatesToQuicklyAdd =>
      'Erstelle Vorlagen, um schnell Notizen hinzuzufügen';

  @override
  String get createTemplate => 'Vorlage erstellen';

  @override
  String get editTemplate => 'Vorlage bearbeiten';

  @override
  String get templateName => 'Vorlagenname';

  @override
  String get durationMinutes => 'Dauer (Minuten)';

  @override
  String get category => 'Kategorie';

  @override
  String get pleaseEnterTemplateName => 'Bitte einen Vorlagennamen eingeben';

  @override
  String get pleaseEnterDuration => 'Bitte Dauer eingeben';

  @override
  String get pleaseEnterValidDuration => 'Bitte eine gültige Dauer eingeben';

  @override
  String get simple => 'Einfach';

  @override
  String get sections => 'Abschnitte';

  @override
  String get addSection => 'Abschnitt hinzufügen';

  @override
  String get sectionTitle => 'Abschnittstitel';

  @override
  String get hintOptional => 'Hinweis (optional)';

  @override
  String get removeSection => 'Abschnitt entfernen';

  @override
  String get templateUpdatedSuccessfully => 'Vorlage erfolgreich aktualisiert';

  @override
  String get templateCreatedSuccessfully => 'Vorlage erfolgreich erstellt';

  @override
  String get deleteTemplate => 'Vorlage löschen';

  @override
  String confirmDeleteTemplate(String title) {
    return 'Bist du sicher, dass du \"$title\" löschen möchtest?';
  }

  @override
  String get templateDeleted => 'Vorlage gelöscht';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get descriptionSections => 'Beschreibungsabschnitte:';

  @override
  String get descriptionLabel => 'Beschreibung:';

  @override
  String addedTemplateAtTime(String title, String time) {
    return '\"$title\" um $time hinzugefügt';
  }

  @override
  String errorCreatingNote(String error) {
    return 'Fehler beim Erstellen der Notiz: $error';
  }

  @override
  String get fileSynchronization => 'Dateisynchronisation';

  @override
  String get fileSyncDescription =>
      'Importiere und exportiere deine Tagebuchdaten als JSON- oder ICS-Kalenderdateien mit optionaler Verschlüsselung.';

  @override
  String get exportToJson => 'Nach JSON exportieren';

  @override
  String get saveYourDiaryData => 'Speichere deine Tagebuchdaten in eine Datei';

  @override
  String get importFromJson => 'Aus JSON importieren';

  @override
  String get loadDiaryData => 'Lade Tagebuchdaten aus einer Datei';

  @override
  String get exportToIcsCalendar => 'Als ICS-Kalender exportieren';

  @override
  String get saveNotesAsCalendarEvents =>
      'Speichere Notizen als Kalendereinträge (.ics)';

  @override
  String get importFromIcsCalendar => 'Aus ICS-Kalender importieren';

  @override
  String get loadCalendarEvents => 'Lade Kalendereinträge aus .ics-Datei';

  @override
  String get exportRange => 'Exportbereich';

  @override
  String get whichEntriesToExport => 'Welche Einträge möchtest du exportieren?';

  @override
  String get customRange => 'Eigener Bereich';

  @override
  String get all => 'Alle';

  @override
  String get encryptJsonExport => 'JSON-Export verschlüsseln (Optional)';

  @override
  String get decryptJsonImport => 'JSON-Import entschlüsseln';

  @override
  String get encryptIcsExport => 'ICS-Export verschlüsseln (Optional)';

  @override
  String get decryptIcsImport => 'ICS-Import entschlüsseln';

  @override
  String get passwordOptional => 'Passwort (Optional)';

  @override
  String get leaveEmptyForNoEncryption =>
      'Leer lassen für keine Verschlüsselung';

  @override
  String get saveJsonExportFile => 'JSON-Exportdatei speichern';

  @override
  String get selectJsonFileToImport => 'JSON-Datei zum Importieren wählen';

  @override
  String get saveIcsCalendarFile => 'ICS-Kalenderdatei speichern';

  @override
  String get selectIcsFileToImport =>
      'ICS-Kalenderdatei zum Importieren wählen';

  @override
  String get operationCompletedSuccessfully =>
      'Vorgang erfolgreich abgeschlossen';

  @override
  String importedDaysWithNotes(int days, int notes) {
    return '$days Tage mit $notes Notizen importiert';
  }

  @override
  String importedNotesFromIcs(int count) {
    return '$count Notizen aus ICS-Kalender importiert';
  }

  @override
  String errorPrefix(String error) {
    return 'Fehler: $error';
  }

  @override
  String get oldEncryptionFormatError =>
      'Diese Datei verwendet das alte Verschlüsselungsformat und kann nicht importiert werden.\nBitte exportiere deine Daten erneut mit der neuen Version.';

  @override
  String get passwordRequiredForEncryptedFile =>
      'Passwort für verschlüsselte Datei erforderlich';

  @override
  String get passwordRequiredForEncryptedIcsFile =>
      'Passwort für verschlüsselte ICS-Datei erforderlich';

  @override
  String get cannotReadIcsFile =>
      'ICS-Datei kann nicht gelesen werden. Datei ist möglicherweise beschädigt.';

  @override
  String get pleaseEnterAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get fillInYourCompleteDay => 'Fülle deinen ganzen Tag aus';

  @override
  String get testingConnection => 'Verbindung wird getestet...';

  @override
  String get connectionSuccessful => 'Verbindung erfolgreich!';

  @override
  String get connectionFailedAuth =>
      'Verbindung fehlgeschlagen: Authentifizierungsfehler';

  @override
  String connectionFailed(String error) {
    return 'Verbindung fehlgeschlagen: $error';
  }

  @override
  String get synchronization => 'Synchronisation';

  @override
  String get supabaseSynchronization => 'Supabase-Synchronisation';

  @override
  String get supabaseSyncDescription =>
      'Synchronisiere deine Tagebuchdaten mit Supabase Cloud-Speicher für Backup und geräteübergreifenden Zugriff.';

  @override
  String get uploadToSupabase => 'Zu Supabase hochladen';

  @override
  String get saveYourDiaryDataToCloud =>
      'Speichere deine Tagebuchdaten in der Cloud';

  @override
  String get downloadFromSupabase => 'Von Supabase herunterladen';

  @override
  String get loadDiaryDataFromCloud => 'Lade Tagebuchdaten aus der Cloud';

  @override
  String get supabaseSettings => 'Supabase-Einstellungen';

  @override
  String get supabaseDescription =>
      'Konfiguriere deine Supabase-Cloud-Speicher-Einstellungen für Backup und geräteübergreifenden Zugriff.';

  @override
  String get supabaseUrl => 'Supabase-URL';

  @override
  String get anonKey => 'Anon Key';

  @override
  String get testConnection => 'Verbindung testen';

  @override
  String get about => 'Über';

  @override
  String get dayTracker => 'Day Tracker';

  @override
  String version(String version) {
    return 'Version: $version';
  }

  @override
  String get developer => 'Entwickler';

  @override
  String get contact => 'Kontakt';

  @override
  String get features => 'Funktionen';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get viewLicenses => 'Lizenzen anzeigen';

  @override
  String get appDescription =>
      'Day Tracker ist eine persönliche Tagebuch- und Produktivitäts-App, die dir hilft, deine täglichen Aktivitäten zu verfolgen und verschiedene Aspekte deines Tages zu bewerten.';

  @override
  String get featureTrackActivities =>
      'Verfolge tägliche Aktivitäten und Termine';

  @override
  String get featureRateDay => 'Bewerte verschiedene Aspekte deines Tages';

  @override
  String get featureCalendar => 'Sieh deinen Zeitplan im Kalender';

  @override
  String get featureEncryption => 'Sichere Daten mit Verschlüsselung';

  @override
  String get featureSync => 'Synchronisiere Daten über Geräte mit Supabase';

  @override
  String get featureExportImport => 'Exportiere und importiere Daten';

  @override
  String copyright(int year) {
    return '© $year Your Company';
  }

  @override
  String score(int score) {
    return 'Punkte: $score';
  }

  @override
  String get createNote => 'Notiz erstellen';

  @override
  String get fromTemplate => 'Aus Vorlage';

  @override
  String get noNoteSelected => 'Keine Notiz ausgewählt';

  @override
  String get clickExistingOrCreateNew =>
      'Klicke auf eine bestehende Notiz oder erstelle eine neue';

  @override
  String get title => 'Titel';

  @override
  String get stopDictation => 'Diktat stoppen';

  @override
  String get dictateDescription => 'Beschreibung diktieren';

  @override
  String get addDetailsAboutNote => 'Füge Details zu dieser Notiz hinzu...';

  @override
  String get listening => 'Hört zu...';

  @override
  String get template => 'Vorlage';

  @override
  String get add => 'Hinzufügen';

  @override
  String get deleteNote => 'Notiz löschen';

  @override
  String get confirmDeleteNote =>
      'Bist du sicher, dass du diese Notiz löschen möchtest?';

  @override
  String get endTimeAfterStartTime => 'Endzeit muss nach der Startzeit liegen';

  @override
  String addedNoteAtTime(String time) {
    return 'Neue Notiz um $time hinzugefügt';
  }

  @override
  String get dailySchedule => 'Tagesplan';

  @override
  String get scheduleComplete => 'Tagesplan vollständig';

  @override
  String get newNote => 'Neue Notiz';

  @override
  String fromTime(String time) {
    return 'Von: $time';
  }

  @override
  String toTime(String time) {
    return 'Bis: $time';
  }

  @override
  String get searchNotes => 'Notizen durchsuchen...';

  @override
  String get searchNotesPlaceholder => 'Suche nach Titel oder Beschreibung';

  @override
  String get filterByCategory => 'Nach Kategorie filtern';

  @override
  String get filterByDate => 'Nach Datum filtern';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get dateFrom => 'Von Datum';

  @override
  String get dateTo => 'Bis Datum';

  @override
  String get selectCategory => 'Kategorie auswählen';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get noNotesMatchSearch => 'Keine Notizen entsprechen deiner Suche';

  @override
  String get tryDifferentSearch => 'Versuche, deine Suchkriterien anzupassen';

  @override
  String nResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '1 Ergebnis',
      zero: 'Keine Ergebnisse',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoriten';

  @override
  String get favoriteDays => 'Lieblings-Tage';

  @override
  String get favoriteNotes => 'Lieblings-Notizen';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get noFavorites => 'Noch keine Favoriten';

  @override
  String get noFavoriteDays => 'Keine Lieblings-Tage';

  @override
  String get noFavoriteNotes => 'Keine Lieblings-Notizen';

  @override
  String get markAsFavorite => 'Als Favorit markieren';

  @override
  String get unmarkAsFavorite => 'Favorit aufheben';
}
