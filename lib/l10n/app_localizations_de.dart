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
  String get moodPatterns => 'Stimmungsmuster';

  @override
  String get patternInsight => 'Muster';

  @override
  String get trendInsight => 'Trend';

  @override
  String get weeklyInsight => 'Wöchentlich';

  @override
  String get tipInsight => 'Tipp';

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
  String get ratingSocial => 'Soziales';

  @override
  String get ratingProductivity => 'Produktivität';

  @override
  String get ratingSport => 'Sport';

  @override
  String get ratingFood => 'Essen';

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
  String get pdfExport => 'PDF-Export';

  @override
  String get pdfExportDescription =>
      'Erstelle druckbare PDF-Berichte mit deinen Tagebucheinträgen, Bewertungen und Statistiken.';

  @override
  String get quickExport => 'Schnellexport';

  @override
  String get lastWeek => 'Letzte 7 Tage';

  @override
  String get lastMonth => 'Letzte 30 Tage';

  @override
  String get currentMonth => 'Dieser Monat';

  @override
  String get selectDateRangeForReport =>
      'Wähle einen benutzerdefinierten Zeitraum für deinen Bericht';

  @override
  String get selectMonth => 'Monat auswählen';

  @override
  String get selectSpecificMonth =>
      'Wähle einen bestimmten Monat zum Exportieren';

  @override
  String get exportAllData => 'Alle Daten exportieren';

  @override
  String get generatePdfWithAllData =>
      'Erstelle PDF-Bericht mit allen deinen Daten';

  @override
  String get selectDateRange => 'Zeitraum für Bericht auswählen';

  @override
  String get export => 'Exportieren';

  @override
  String get pdfExportSuccess => 'PDF-Bericht erfolgreich erstellt';

  @override
  String pdfExportError(String error) {
    return 'PDF-Erstellung fehlgeschlagen: $error';
  }

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

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get notificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get notificationSettingsDescription =>
      'Konfiguriere Erinnerungen und Benachrichtigungen für deine Tagebucheinträge.';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get enableNotificationsDescription =>
      'Aktiviere tägliche Erinnerungen zum Schreiben in dein Tagebuch';

  @override
  String get reminderTime => 'Erinnerungszeit';

  @override
  String get reminderTimeDescription =>
      'Wähle, wann du erinnert werden möchtest';

  @override
  String get smartReminders => 'Intelligente Erinnerungen';

  @override
  String get smartRemindersDescription =>
      'Nur erinnern, wenn du den heutigen Eintrag noch nicht geschrieben hast';

  @override
  String get streakWarnings => 'Streak-Warnungen';

  @override
  String get streakWarningsDescription =>
      'Werde benachrichtigt, wenn deine Schreibsträhne gefährdet ist';

  @override
  String get notificationPermissionDenied =>
      'Benachrichtigungsberechtigung wurde verweigert. Bitte aktiviere sie in den Einstellungen.';

  @override
  String get selectReminderTime => 'Erinnerungszeit auswählen';

  @override
  String get goalsSectionTitle => 'Ziele';

  @override
  String get goalCreateNew => 'Ziel erstellen';

  @override
  String get goalCreate => 'Erstellen';

  @override
  String get goalSelectCategory => 'Welchen Bereich möchtest du verbessern?';

  @override
  String get goalSelectTimeframe => 'Wähle deinen Zeitrahmen';

  @override
  String get goalSetTarget => 'Setze dein Ziel';

  @override
  String goalTargetHint(String category) {
    return 'Welchen Durchschnitt für $category möchtest du erreichen?';
  }

  @override
  String get goalWeekly => 'Wöchentlich';

  @override
  String get goalMonthly => 'Monatlich';

  @override
  String get goalDaysLeft => 'Tage übrig';

  @override
  String get goalDaysRemaining => 'Tage übrig';

  @override
  String get goalCurrentAverage => 'Aktuell';

  @override
  String get goalTarget => 'Ziel';

  @override
  String get goalTargetLabel => 'Zielpunktzahl';

  @override
  String goalSuggestedTarget(String target) {
    return 'Basierend auf deiner Historie empfehlen wir $target';
  }

  @override
  String get goalUseSuggestion => 'Nutzen';

  @override
  String get goalEmptyTitle => 'Keine aktiven Ziele';

  @override
  String get goalEmptySubtitle =>
      'Setze ein Ziel um deinen Fortschritt zu verfolgen und motiviert zu bleiben';

  @override
  String get goalSetFirst => 'Erstes Ziel setzen';

  @override
  String get goalStatusOnTrack => 'Auf Kurs';

  @override
  String get goalStatusBehind => 'Braucht Aufmerksamkeit';

  @override
  String get goalStatusAhead => 'Übertrifft Ziel!';

  @override
  String get goalStatusCompleted => 'Ziel erreicht!';

  @override
  String get goalStatusFailed => 'Ziel nicht erreicht';

  @override
  String get goalStreak => 'Ziel-Serie';

  @override
  String get goalHistory => 'Ziel-Verlauf';

  @override
  String get goalSuccessRate => 'Erfolgsrate';

  @override
  String get days => 'Tage';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get photos => 'Fotos';

  @override
  String get noPhotos => 'Keine Fotos angehängt';

  @override
  String get deletePhoto => 'Foto löschen';

  @override
  String get deletePhotoConfirm => 'Möchten Sie dieses Foto wirklich löschen?';

  @override
  String get imageNotFound => 'Bild nicht gefunden';

  @override
  String get drawerHabits => 'Gewohnheiten';

  @override
  String get habitsTitle => 'Gewohnheiten';

  @override
  String get habitsToday => 'Heute';

  @override
  String get habitsGrid => 'Raster';

  @override
  String get habitsStats => 'Statistik';

  @override
  String get habitName => 'Gewohnheitsname';

  @override
  String get habitNameRequired => 'Bitte einen Namen eingeben';

  @override
  String get habitDescription => 'Beschreibung';

  @override
  String get habitIconAndColor => 'Tippe, um Symbol oder Farbe zu ändern';

  @override
  String get habitFrequency => 'Häufigkeit';

  @override
  String get habitFrequencyDaily => 'Täglich';

  @override
  String get habitFrequencyWeekdays => 'Werktags';

  @override
  String get habitFrequencyWeekends => 'Wochenende';

  @override
  String get habitFrequencySpecificDays => 'Bestimmte Tage';

  @override
  String get habitFrequencyTimesPerWeek => 'Mal/Woche';

  @override
  String get habitTargetCount => 'Zielanzahl';

  @override
  String get habitTimesPerWeekLabel => 'Mal pro Woche';

  @override
  String get habitCreateNew => 'Neue Gewohnheit';

  @override
  String get habitEdit => 'Gewohnheit bearbeiten';

  @override
  String get habitArchive => 'Gewohnheit archivieren';

  @override
  String get habitUnarchive => 'Gewohnheit wiederherstellen';

  @override
  String get habitNoHabits => 'Noch keine Gewohnheiten';

  @override
  String get habitNoHabitsDescription =>
      'Erstelle Gewohnheiten, um deine täglichen Routinen zu verfolgen';

  @override
  String get habitCreateFirst => 'Erste Gewohnheit erstellen';

  @override
  String get habitCompleted => 'Erledigt';

  @override
  String get habitProgress => 'Fortschritt';

  @override
  String get habitDueToday => 'Heute fällig';

  @override
  String get habitCurrentStreak => 'Aktuelle Serie';

  @override
  String get habitBestStreak => 'Beste Serie';

  @override
  String get habitCompletionRate => 'Erledigungsrate';

  @override
  String get habitLast7Days => 'Letzte 7 Tage';

  @override
  String get habitLast30Days => 'Letzte 30 Tage';

  @override
  String get habitAllTime => 'Gesamt';

  @override
  String get habitTotalCompletions => 'Gesamt erledigt';

  @override
  String get habitSelectIcon => 'Symbol wählen';

  @override
  String get habitSelectColor => 'Farbe wählen';

  @override
  String get habitSelectAtLeastOneDay => 'Bitte wähle mindestens einen Tag';

  @override
  String get habitDayMon => 'Mo';

  @override
  String get habitDayTue => 'Di';

  @override
  String get habitDayWed => 'Mi';

  @override
  String get habitDayThu => 'Do';

  @override
  String get habitDayFri => 'Fr';

  @override
  String get habitDaySat => 'Sa';

  @override
  String get habitDaySun => 'So';

  @override
  String get habitDeleteConfirm =>
      'Bist du sicher, dass du diese Gewohnheit und alle Einträge löschen möchtest?';

  @override
  String get habitDeleteTitle => 'Gewohnheit löschen';

  @override
  String get habitTodayProgress => 'Heutiger Fortschritt';

  @override
  String get habitAllHabitsCompleted => 'Alle Gewohnheiten erledigt!';

  @override
  String get habitContributionGrid => 'Beitragsraster';

  @override
  String get habitLess => 'Weniger';

  @override
  String get habitMore => 'Mehr';

  @override
  String get biometricSettings => 'Biometrische Anmeldung';

  @override
  String get biometricSettingsDescription =>
      'Fingerabdruck oder Gesichtserkennung zum Entsperren verwenden';

  @override
  String get enableBiometric => 'Biometrische Anmeldung aktivieren';

  @override
  String get enableBiometricDescription =>
      'App mit Fingerabdruck oder Gesicht entsperren';

  @override
  String get biometricLockOnResume => 'Bei App-Wechsel sperren';

  @override
  String get biometricLockOnResumeDescription =>
      'Biometrie beim Zurückkehren zur App verlangen';

  @override
  String get biometricLockTimeout => 'Sperr-Timeout';

  @override
  String get biometricLockTimeoutDescription =>
      'Zeit bis zur erneuten Authentifizierung';

  @override
  String get biometricImmediately => 'Sofort';

  @override
  String biometricMinutes(int count) {
    return '$count Minuten';
  }

  @override
  String get biometricTestButton => 'Biometrie testen';

  @override
  String get biometricTestSuccess =>
      'Biometrische Authentifizierung erfolgreich';

  @override
  String get biometricTestFailed =>
      'Biometrische Authentifizierung fehlgeschlagen';

  @override
  String get biometricNotAvailable =>
      'Biometrische Authentifizierung auf diesem Gerät nicht verfügbar';

  @override
  String get biometricNotEnrolled =>
      'Keine Biometrie auf diesem Gerät eingerichtet';

  @override
  String get biometricUnlockPrompt => 'SimpleDiary entsperren';

  @override
  String get biometricTapToUnlock => 'Tippen zum biometrischen Entsperren';

  @override
  String get usePasswordInstead => 'Stattdessen Passwort verwenden';

  @override
  String get biometricRetry => 'Erneut versuchen';

  @override
  String get biometricEnrollSuccess =>
      'Biometrische Anmeldung erfolgreich aktiviert';

  @override
  String get biometricEnrollFailed =>
      'Biometrische Anmeldung konnte nicht aktiviert werden';

  @override
  String get backupSettings => 'Automatische Backups';

  @override
  String get backupSettingsDescription =>
      'Konfiguriere automatische Backups zum Schutz deiner Tagebuchdaten.';

  @override
  String get enableAutoBackup => 'Automatische Backups aktivieren';

  @override
  String get enableAutoBackupDescription =>
      'Sichere deine Daten automatisch nach einem regelmäßigen Zeitplan';

  @override
  String get backupFrequency => 'Backup-Häufigkeit';

  @override
  String get backupFrequencyDescription =>
      'Wie oft sollen automatische Backups erstellt werden';

  @override
  String get backupFrequencyDaily => 'Täglich';

  @override
  String get backupFrequencyWeekly => 'Wöchentlich';

  @override
  String get backupFrequencyMonthly => 'Monatlich';

  @override
  String get backupPreferredTime => 'Bevorzugte Zeit';

  @override
  String get backupPreferredTimeDescription =>
      'Wann das automatische Backup ausgeführt werden soll';

  @override
  String get backupWifiOnly => 'Nur WLAN';

  @override
  String get backupWifiOnlyDescription =>
      'Backups nur bei WLAN-Verbindung erstellen (Android)';

  @override
  String get backupMaxCount => 'Backups behalten';

  @override
  String get backupMaxCountDescription =>
      'Maximale Anzahl aufzubewahrender Backups';

  @override
  String backupMaxCountValue(int count) {
    return '$count Backups';
  }

  @override
  String get backupNow => 'Jetzt sichern';

  @override
  String get backupNowDescription => 'Sofort ein manuelles Backup erstellen';

  @override
  String get backupHistory => 'Backup-Verlauf';

  @override
  String get backupHistoryDescription => 'Backups anzeigen und verwalten';

  @override
  String lastBackup(String time) {
    return 'Letztes Backup: $time';
  }

  @override
  String get lastBackupNever => 'Letztes Backup: Nie';

  @override
  String get backupCreating => 'Backup wird erstellt...';

  @override
  String get backupSuccess => 'Backup erfolgreich erstellt';

  @override
  String backupFailed(String error) {
    return 'Backup fehlgeschlagen: $error';
  }

  @override
  String get backupRestoring => 'Backup wird wiederhergestellt...';

  @override
  String get backupRestoreSuccess =>
      'Backup erfolgreich wiederhergestellt. Bitte starte die App neu.';

  @override
  String backupRestoreFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get backupRestoreConfirm => 'Backup wiederherstellen';

  @override
  String backupRestoreConfirmMessage(String date) {
    return 'Dies ersetzt alle aktuellen Daten mit dem Backup vom $date. Vorher wird ein Sicherheits-Backup erstellt. Fortfahren?';
  }

  @override
  String get backupDeleteConfirm => 'Backup löschen';

  @override
  String get backupDeleteConfirmMessage =>
      'Bist du sicher, dass du dieses Backup löschen möchtest?';

  @override
  String get backupDeleted => 'Backup gelöscht';

  @override
  String backupStorageUsed(String size) {
    return 'Speicherverbrauch: $size';
  }

  @override
  String backupEntries(int days, int notes, int habits) {
    return '$days Tage, $notes Notizen, $habits Gewohnheiten';
  }

  @override
  String get backupTypeManual => 'Manuell';

  @override
  String get backupTypeScheduled => 'Geplant';

  @override
  String get backupTypePreRestore => 'Vor Wiederherstellung';

  @override
  String get backupNoBackups => 'Noch keine Backups';

  @override
  String get backupNoBackupsDescription =>
      'Aktiviere automatische Backups oder erstelle ein manuelles Backup zum Schutz deiner Daten';

  @override
  String get backupOverdue => 'Backup überfällig';

  @override
  String get backupDestination => 'Backup-Speicherort';

  @override
  String get backupDestinationDescription =>
      'Wähle, wo deine Backups gespeichert werden sollen';

  @override
  String get backupDestinationRequiresSupabase =>
      'Konfiguriere zuerst die Supabase-Einstellungen, um den Cloud-Speicher zu aktivieren';

  @override
  String get backupDestinationLocal => 'Lokal';

  @override
  String get backupDestinationCloud => 'Cloud';

  @override
  String get backupDestinationBoth => 'Beides';

  @override
  String get backupUploadToCloud => 'Hochladen';

  @override
  String get backupUploadSuccess => 'Backup in die Cloud hochgeladen';

  @override
  String backupUploadFailed(String error) {
    return 'Cloud-Upload fehlgeschlagen: $error';
  }

  @override
  String get backupCloudBackups => 'Cloud-Backups';

  @override
  String get backupDownloadFromCloud => 'Herunterladen';

  @override
  String get backupDownloadSuccess => 'Backup aus der Cloud heruntergeladen';

  @override
  String backupDownloadFailed(String error) {
    return 'Cloud-Download fehlgeschlagen: $error';
  }

  @override
  String get backupCloudDeleteConfirm => 'Aus Cloud löschen';

  @override
  String get backupCloudDeleteConfirmMessage =>
      'Möchtest du dieses Backup wirklich aus dem Cloud-Speicher löschen?';

  @override
  String get backupCloudDeleted => 'Backup aus der Cloud gelöscht';

  @override
  String get backupCloudNoBackups => 'Keine Cloud-Backups gefunden';

  @override
  String get backupLocation => 'Speicherort';

  @override
  String get backupLocationDescription =>
      'Wähle, wo lokale Backups auf diesem Gerät gespeichert werden';

  @override
  String backupLocationDefault(String path) {
    return 'Standard ($path)';
  }

  @override
  String backupLocationCustom(String path) {
    return 'Benutzerdefiniert: $path';
  }

  @override
  String get backupLocationChange => 'Ändern';

  @override
  String get backupLocationReset => 'Auf Standard zurücksetzen';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei SimpleDiary';

  @override
  String get onboardingWelcomeDescription =>
      'Dein persönlicher täglicher Begleiter zur Selbstreflexion.\nVerfolge deine Tage, entdecke Muster und wachse jede Woche.';

  @override
  String get onboardingRatingsTitle => 'Bewerte deinen Tag';

  @override
  String get onboardingRatingsDescription =>
      'Bewerte täglich vier Bereiche:\nSoziales · Produktivität · Sport · Ernährung.\nSieh auf einen Blick, wie ausgewogen dein Leben ist.';

  @override
  String get onboardingNotesTitle => 'Aktivitäten hinzufügen';

  @override
  String get onboardingNotesDescription =>
      'Erfasse Notizen und Ereignisse mit Kategorien wie Arbeit, Gym, Freizeit und mehr.\nAlles erscheint in deinem persönlichen Kalender.';

  @override
  String get onboardingInsightsTitle => 'Muster entdecken';

  @override
  String get onboardingInsightsDescription =>
      'Das Dashboard zeigt Streaks, Wochenstatistiken und Einblicke.\nFinde heraus, welche Aktivitäten deine Stimmung am meisten steigern.';

  @override
  String get onboardingGetStartedTitle => 'Bereit loszulegen?';

  @override
  String get onboardingGetStartedDescription =>
      'Erkunde zuerst mit Beispieldaten oder erstelle direkt dein Konto.';

  @override
  String get onboardingExploreDemo => 'Mit Beispieldaten erkunden';

  @override
  String get onboardingCreateAccount => 'Konto erstellen';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get setupWizardTitle => 'Schnelleinrichtung';

  @override
  String get setupWizardThemeTitle => 'Design wählen';

  @override
  String get setupWizardThemeHint =>
      'Du kannst dies jederzeit in den Einstellungen ändern.';

  @override
  String get setupWizardThemeLight => 'Hell';

  @override
  String get setupWizardThemeDark => 'Dunkel';

  @override
  String get setupWizardLanguageTitle => 'Sprache wählen';

  @override
  String get setupWizardLanguageHint =>
      'Du kannst dies jederzeit in den Einstellungen ändern.';

  @override
  String get setupWizardNext => 'Weiter';

  @override
  String get setupWizardDone => 'Fertig';

  @override
  String get demoModeBannerText => 'Du erkundest mit Beispieldaten';

  @override
  String get demoModeCreateAccount => 'Konto erstellen';

  @override
  String get quickMoodCheck => 'Schnelle Stimmungsprüfung';

  @override
  String get tapWhereYouAre =>
      'Tippe auf der Stimmungskarte, wo du dich befindest';

  @override
  String get highEnergy => 'Hohe Energie';

  @override
  String get lowEnergy => 'Niedrige Energie';

  @override
  String get pleasant => 'Angenehm';

  @override
  String get unpleasant => 'Unangenehm';

  @override
  String get wellbeingDimensions => 'Wohlbefindens-Dimensionen';

  @override
  String get permaPlusDescription =>
      'PERMA+-Modell – bewerte jeden Bereich deines Tages';

  @override
  String get overallMoodDimension => 'Stimmung';

  @override
  String get howDidYouFeel => 'Wie hast du dich heute emotional gefühlt?';

  @override
  String get energyDimension => 'Energie';

  @override
  String get physicalVitality => 'Deine körperliche Vitalität und Wachheit';

  @override
  String get connectionDimension => 'Verbundenheit';

  @override
  String get socialConnections => 'Qualität sozialer Interaktionen';

  @override
  String get purposeDimension => 'Sinn';

  @override
  String get meaningAndPurpose => 'Gefühl von Bedeutung und Richtung';

  @override
  String get achievementDimension => 'Leistung';

  @override
  String get accomplishments => 'Fortschritt bei Zielen und Aufgaben';

  @override
  String get engagementDimension => 'Engagement';

  @override
  String get flowAndAbsorption => 'In angenehmen Aktivitäten vertieft';

  @override
  String get selectEmotions => 'Emotionen auswählen';

  @override
  String get howAreYouFeeling =>
      'Wie fühlst du dich? (alles Zutreffende auswählen)';

  @override
  String get positiveEmotions => 'Positiv';

  @override
  String get negativeEmotions => 'Negativ';

  @override
  String get neutralEmotions => 'Neutral / Gemischt';

  @override
  String get intensityMild => 'Leicht';

  @override
  String get intensityModerate => 'Mäßig';

  @override
  String get intensityStrong => 'Stark';

  @override
  String get contextFactors => 'Kontextfaktoren';

  @override
  String get contextFactorsDescription =>
      'Optionaler Kontext, der deine Stimmung beeinflussen könnte';

  @override
  String get sleepHours => 'Schlafstunden';

  @override
  String get sleepQuality => 'Schlafqualität';

  @override
  String get exercisedToday => 'Heute Sport getrieben';

  @override
  String get stressLevel => 'Stresslevel';

  @override
  String get addTagHint => 'Tag hinzufügen (z.B. Reise, krank, Date)';

  @override
  String get ratingModeLabel => 'Bewertungsmodus';

  @override
  String get quickMode => 'Schnell (10 Sek.)';

  @override
  String get balancedMode => 'Ausgewogen (30 Sek.)';

  @override
  String get detailedMode => 'Detailliert (60 Sek.)';

  @override
  String get customMode => 'Benutzerdefiniert';

  @override
  String get switchToEnhancedMode => 'Zum erweiterten Modus wechseln';

  @override
  String get switchToSimpleMode => 'Zum einfachen Modus wechseln';

  @override
  String get rateWellbeingDimensions =>
      'Bewerte dein Wohlbefinden in wichtigen Bereichen';

  @override
  String get showQuickMood => 'Schnelle Stimmungskarte anzeigen';

  @override
  String get showEmotionWheel => 'Emotionsrad anzeigen';

  @override
  String get showContextFactors => 'Kontextfaktoren anzeigen';

  @override
  String get useLegacyRating => 'Einfache Bewertung verwenden (4 Kategorien)';
}
