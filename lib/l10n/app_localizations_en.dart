// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Simple Diary';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerCalendar => 'Calendar';

  @override
  String get drawerDiaryWizard => 'Diary Wizard';

  @override
  String get drawerNotesOverview => 'Notes Overview';

  @override
  String get drawerTemplates => 'Templates';

  @override
  String get drawerSync => 'Datasynchronization';

  @override
  String get drawerAbout => 'About';

  @override
  String get drawerErrorInvalidEntry => 'Error: Invalid entry';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully';

  @override
  String errorSavingSettings(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get noteCategories => 'Note Categories';

  @override
  String get manageCategoriesAndTags => 'Manage your note categories and tags';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get customizeAppearance =>
      'Customize the appearance of your diary application.';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get clickColorToChange => 'Click this color to change it in a dialog';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get toggleDarkMode =>
      'Toggle this button to switch between dark and light theme';

  @override
  String get selectColor => 'Select color';

  @override
  String get selectColorShade => 'Select color shade';

  @override
  String get selectedColorAndShades => 'Selected color and its shades';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get languageDescription =>
      'Choose the language for the application interface.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get email => 'Email';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get createAccount => 'Create an account';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get remoteAccount => 'Remote Account?';

  @override
  String get pleaseEnterUsername => 'Please enter a username';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get authenticationError => 'Authentication Error';

  @override
  String get invalidUsernameOrPassword =>
      'Invalid username or password. Please try again.';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get enterPasswordToContinue => 'Enter your password to continue';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get switchUser => 'Switch User';

  @override
  String get accountSettings => 'Account settings';

  @override
  String get save => 'Save';

  @override
  String get logout => 'Logout';

  @override
  String get doYouWantToLogout => 'Do you want to logout?';

  @override
  String get doYouWantToOverwriteUserdata =>
      'Do you want to overwrite your userdata?';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutMessage => 'Are you sure that you want to logout?';

  @override
  String get stayHere => 'stay here';

  @override
  String get today => 'Today';

  @override
  String get recorded => 'Recorded';

  @override
  String get pending => 'Pending';

  @override
  String get recordToday => 'Record today';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get weeklyAverage => 'Weekly Average';

  @override
  String get status => 'Status';

  @override
  String get newEntry => 'New Entry';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get sevenDayOverview => '7-Day Overview';

  @override
  String get ratingTrend => 'Rating Trend';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get insightsAndAchievements => 'Insights & Achievements';

  @override
  String errorLoadingInsights(String error) {
    return 'Error loading insights: $error';
  }

  @override
  String weekNumber(int number) {
    return 'Week $number';
  }

  @override
  String get milestoneReached => 'You have reached an important milestone!';

  @override
  String get perfectWeek => 'Perfect Week!';

  @override
  String get perfectWeekDescription => 'You logged all days this week!';

  @override
  String get notRecordedToday => 'Not recorded today';

  @override
  String get rememberToRate => 'Don\'t forget to rate your day today!';

  @override
  String get bestCategory => 'Best Category';

  @override
  String bestCategoryDescription(String category) {
    return 'Your best category this week: $category!';
  }

  @override
  String dayDetail(String date) {
    return 'Day Detail: $date';
  }

  @override
  String get noDiaryEntryForDay => 'No diary entry for this day';

  @override
  String errorLoadingNotes(String error) {
    return 'Error loading notes: $error';
  }

  @override
  String errorLoadingDiaryDay(String error) {
    return 'Error loading diary day: $error';
  }

  @override
  String get addANote => 'Add a note';

  @override
  String get daySummary => 'Day Summary';

  @override
  String get notesAndActivities => 'Notes & Activities';

  @override
  String nEntries(int count) {
    return '$count entries';
  }

  @override
  String get noNotesForDay => 'No notes for this day';

  @override
  String get addThoughtsActivitiesMemories =>
      'Add your thoughts, activities or memories';

  @override
  String get editNote => 'Edit note';

  @override
  String get allDay => 'All day';

  @override
  String overallMood(String mood) {
    return 'Overall Mood: $mood';
  }

  @override
  String get deleteDiaryEntry => 'Delete Diary Entry';

  @override
  String get confirmDeleteDiaryEntry =>
      'Are you sure you want to delete this diary entry? This will remove both the day rating and all associated notes.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get ratingPoor => 'Poor';

  @override
  String get ratingFair => 'Fair';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingGreat => 'Great';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get moodToughDay => 'Tough Day';

  @override
  String get moodCouldBeBetter => 'Could Be Better';

  @override
  String get moodPrettyGood => 'Pretty Good';

  @override
  String get moodGreatDay => 'Great Day';

  @override
  String get moodPerfectDay => 'Perfect Day';

  @override
  String get noDiaryEntriesYet => 'No diary entries yet';

  @override
  String get startTrackingDescription =>
      'Start tracking your day by adding notes\nand completing daily evaluations';

  @override
  String get startTodaysJournal => 'Start Today\'s Journal';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get confirmDeleteDiaryEntryShort =>
      'Are you sure you want to delete this diary entry?';

  @override
  String get diaryEntryDeleted => 'Diary entry deleted';

  @override
  String get undo => 'Undo';

  @override
  String get loadingDayData => 'Loading your day data...';

  @override
  String get calendar => 'Calendar';

  @override
  String get noteDetails => 'Note Details';

  @override
  String get dayRating => 'Day Rating';

  @override
  String get howWasYourDay =>
      'How was your day? Rate the different aspects of your experience.';

  @override
  String get saveDayRating => 'Save Day Rating';

  @override
  String get dayRatingSaved => 'Day rating saved successfully!';

  @override
  String get notRated => 'Not Rated';

  @override
  String get ratingSocialDescription =>
      'How were your social interactions and relationships today?';

  @override
  String get ratingProductivityDescription =>
      'How productive were you in your work or daily tasks?';

  @override
  String get ratingSportDescription =>
      'How was your physical activity and exercise today?';

  @override
  String get ratingFoodDescription =>
      'How healthy and satisfying was your diet today?';

  @override
  String get tapToChangeDate => 'Tap to change date';

  @override
  String get previousDay => 'Previous day';

  @override
  String get selectDate => 'Select date';

  @override
  String get nextDay => 'Next day';

  @override
  String get addTitle => 'Add Title';

  @override
  String get addNote => 'Add note';

  @override
  String get description => 'Description';

  @override
  String get allDayQuestion => 'AllDay?';

  @override
  String get from => 'FROM';

  @override
  String get to => 'To';

  @override
  String get saveUpperCase => 'SAVE';

  @override
  String get saveWord => 'save';

  @override
  String get reload => 'reload';

  @override
  String get noteUpdateError => 'Was not able to update note';

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get organizeCategoriesDescription =>
      'Organize your notes with custom categories';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get createCategoriesToOrganize =>
      'Create categories to organize your notes';

  @override
  String get createCategory => 'Create Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryColor => 'Category Color';

  @override
  String get preview => 'Preview';

  @override
  String get pleaseEnterCategoryName => 'Please enter a category name';

  @override
  String get categoryAlreadyExists =>
      'A category with this name already exists';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryCreated => 'Category created';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get cannotDeleteCategory => 'Cannot Delete Category';

  @override
  String categoryInUse(String title) {
    return 'The category \"$title\" is currently used by one or more notes. Please reassign or delete those notes first.';
  }

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String confirmDeleteCategory(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get editCategoryTooltip => 'Edit category';

  @override
  String get deleteCategoryTooltip => 'Delete category';

  @override
  String get defaultCategoryWork => 'Work';

  @override
  String get defaultCategoryLeisure => 'Leisure';

  @override
  String get defaultCategoryFood => 'Food';

  @override
  String get defaultCategoryGym => 'Gym';

  @override
  String get defaultCategorySleep => 'Sleep';

  @override
  String get noteTemplates => 'Note Templates';

  @override
  String get selectTemplate => 'Select Template';

  @override
  String get noTemplatesAvailable => 'No templates available';

  @override
  String get noTemplatesYet => 'No templates yet';

  @override
  String get createTemplatesToQuicklyAdd =>
      'Create templates to quickly add notes';

  @override
  String get createTemplate => 'Create Template';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get templateName => 'Template Name';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get category => 'Category';

  @override
  String get pleaseEnterTemplateName => 'Please enter a template name';

  @override
  String get pleaseEnterDuration => 'Please enter duration';

  @override
  String get pleaseEnterValidDuration => 'Please enter a valid duration';

  @override
  String get simple => 'Simple';

  @override
  String get sections => 'Sections';

  @override
  String get addSection => 'Add Section';

  @override
  String get sectionTitle => 'Section Title';

  @override
  String get hintOptional => 'Hint (optional)';

  @override
  String get removeSection => 'Remove section';

  @override
  String get templateUpdatedSuccessfully => 'Template updated successfully';

  @override
  String get templateCreatedSuccessfully => 'Template created successfully';

  @override
  String get deleteTemplate => 'Delete Template';

  @override
  String confirmDeleteTemplate(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get templateDeleted => 'Template deleted';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get descriptionSections => 'Description Sections:';

  @override
  String get descriptionLabel => 'Description:';

  @override
  String addedTemplateAtTime(String title, String time) {
    return 'Added \"$title\" at $time';
  }

  @override
  String errorCreatingNote(String error) {
    return 'Error creating note: $error';
  }

  @override
  String get fileSynchronization => 'File Synchronization';

  @override
  String get fileSyncDescription =>
      'Import and export your diary data to JSON or ICS calendar files with optional encryption.';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get saveYourDiaryData => 'Save your diary data to a file';

  @override
  String get importFromJson => 'Import from JSON';

  @override
  String get loadDiaryData => 'Load diary data from a file';

  @override
  String get exportToIcsCalendar => 'Export to ICS Calendar';

  @override
  String get saveNotesAsCalendarEvents =>
      'Save notes as calendar events (.ics)';

  @override
  String get importFromIcsCalendar => 'Import from ICS Calendar';

  @override
  String get loadCalendarEvents => 'Load calendar events from .ics file';

  @override
  String get exportRange => 'Export Range';

  @override
  String get whichEntriesToExport => 'Which entries do you want to export?';

  @override
  String get customRange => 'Custom Range';

  @override
  String get all => 'All';

  @override
  String get encryptJsonExport => 'Encrypt JSON Export (Optional)';

  @override
  String get decryptJsonImport => 'Decrypt JSON Import';

  @override
  String get encryptIcsExport => 'Encrypt ICS Export (Optional)';

  @override
  String get decryptIcsImport => 'Decrypt ICS Import';

  @override
  String get passwordOptional => 'Password (Optional)';

  @override
  String get leaveEmptyForNoEncryption => 'Leave empty for no encryption';

  @override
  String get saveJsonExportFile => 'Save JSON Export File';

  @override
  String get selectJsonFileToImport => 'Select JSON File to Import';

  @override
  String get saveIcsCalendarFile => 'Save ICS Calendar File';

  @override
  String get selectIcsFileToImport => 'Select ICS Calendar File to Import';

  @override
  String get operationCompletedSuccessfully =>
      'Operation completed successfully';

  @override
  String importedDaysWithNotes(int days, int notes) {
    return 'Imported $days days with $notes notes';
  }

  @override
  String importedNotesFromIcs(int count) {
    return 'Imported $count notes from ICS calendar';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get oldEncryptionFormatError =>
      'This file uses the old encryption format and cannot be imported.\nPlease export your data again with the new version.';

  @override
  String get passwordRequiredForEncryptedFile =>
      'Password required for encrypted file';

  @override
  String get passwordRequiredForEncryptedIcsFile =>
      'Password required for encrypted ICS file';

  @override
  String get cannotReadIcsFile =>
      'Cannot read ICS file. File may be corrupted.';

  @override
  String get pleaseEnterAllFields => 'Please fill in all fields';

  @override
  String get fillInYourCompleteDay => 'Fill in your complete day';

  @override
  String get testingConnection => 'Testing connection...';

  @override
  String get connectionSuccessful => 'Connection successful!';

  @override
  String get connectionFailedAuth => 'Connection failed: Authentication error';

  @override
  String connectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get synchronization => 'Synchronization';

  @override
  String get supabaseSynchronization => 'Supabase Synchronization';

  @override
  String get supabaseSyncDescription =>
      'Sync your diary data with Supabase cloud storage for backup and cross-device access.';

  @override
  String get uploadToSupabase => 'Upload to Supabase';

  @override
  String get saveYourDiaryDataToCloud => 'Save your diary data to the cloud';

  @override
  String get downloadFromSupabase => 'Download from Supabase';

  @override
  String get loadDiaryDataFromCloud => 'Load diary data from the cloud';

  @override
  String get supabaseSettings => 'Supabase Settings';

  @override
  String get supabaseDescription =>
      'Configure your Supabase cloud storage settings for backup and cross-device access.';

  @override
  String get supabaseUrl => 'Supabase URL';

  @override
  String get anonKey => 'Anon Key';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get about => 'About';

  @override
  String get dayTracker => 'Day Tracker';

  @override
  String version(String version) {
    return 'Version: $version';
  }

  @override
  String get developer => 'Developer';

  @override
  String get contact => 'Contact';

  @override
  String get features => 'Features';

  @override
  String get licenses => 'Licenses';

  @override
  String get viewLicenses => 'View Licenses';

  @override
  String get appDescription =>
      'Day Tracker is a personal diary and productivity app that helps you track your daily activities and rate different aspects of your day.';

  @override
  String get featureTrackActivities =>
      'Track daily activities and appointments';

  @override
  String get featureRateDay => 'Rate different aspects of your day';

  @override
  String get featureCalendar => 'View your schedule in a calendar';

  @override
  String get featureEncryption => 'Secure data with encryption';

  @override
  String get featureSync => 'Sync data across devices with Supabase';

  @override
  String get featureExportImport => 'Export and import data';

  @override
  String copyright(int year) {
    return '© $year Your Company';
  }

  @override
  String score(int score) {
    return 'Score: $score';
  }

  @override
  String get createNote => 'Create Note';

  @override
  String get fromTemplate => 'From Template';

  @override
  String get noNoteSelected => 'No note selected';

  @override
  String get clickExistingOrCreateNew =>
      'Click on an existing note or create a new one';

  @override
  String get title => 'Title';

  @override
  String get stopDictation => 'Stop dictation';

  @override
  String get dictateDescription => 'Dictate description';

  @override
  String get addDetailsAboutNote => 'Add details about this note...';

  @override
  String get listening => 'Listening...';

  @override
  String get template => 'Template';

  @override
  String get add => 'Add';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get confirmDeleteNote => 'Are you sure you want to delete this note?';

  @override
  String get endTimeAfterStartTime => 'End time must be after start time';

  @override
  String addedNoteAtTime(String time) {
    return 'Added new note at $time';
  }

  @override
  String get dailySchedule => 'Daily Schedule';

  @override
  String get scheduleComplete => 'Schedule complete';

  @override
  String get newNote => 'New Note';

  @override
  String fromTime(String time) {
    return 'From: $time';
  }

  @override
  String toTime(String time) {
    return 'To: $time';
  }

  @override
  String get searchNotes => 'Search notes...';

  @override
  String get searchNotesPlaceholder => 'Search by title or description';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get dateFrom => 'From date';

  @override
  String get dateTo => 'To date';

  @override
  String get selectCategory => 'Select category';

  @override
  String get allCategories => 'All categories';

  @override
  String get noNotesMatchSearch => 'No notes match your search';

  @override
  String get tryDifferentSearch => 'Try adjusting your search criteria';

  @override
  String nResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get favoriteDays => 'Favorite Days';

  @override
  String get favoriteNotes => 'Favorite Notes';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noFavoriteDays => 'No favorite days';

  @override
  String get noFavoriteNotes => 'No favorite notes';

  @override
  String get markAsFavorite => 'Mark as favorite';

  @override
  String get unmarkAsFavorite => 'Unmark as favorite';
}
