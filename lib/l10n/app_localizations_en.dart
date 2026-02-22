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
  String get moodPatterns => 'Mood Patterns';

  @override
  String get patternInsight => 'Pattern';

  @override
  String get trendInsight => 'Trend';

  @override
  String get weeklyInsight => 'Weekly';

  @override
  String get tipInsight => 'Tip';

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
  String get ratingSocial => 'Social';

  @override
  String get ratingProductivity => 'Productivity';

  @override
  String get ratingSport => 'Sport';

  @override
  String get ratingFood => 'Food';

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
  String get pdfExport => 'PDF Export';

  @override
  String get pdfExportDescription =>
      'Generate printable PDF reports with your diary entries, ratings, and statistics.';

  @override
  String get quickExport => 'Quick Export';

  @override
  String get lastWeek => 'Last 7 Days';

  @override
  String get lastMonth => 'Last 30 Days';

  @override
  String get currentMonth => 'This Month';

  @override
  String get selectDateRangeForReport =>
      'Select a custom date range for your report';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get selectSpecificMonth => 'Choose a specific month to export';

  @override
  String get exportAllData => 'Export All Data';

  @override
  String get generatePdfWithAllData => 'Generate PDF report with all your data';

  @override
  String get selectDateRange => 'Select date range for report';

  @override
  String get export => 'Export';

  @override
  String get pdfExportSuccess => 'PDF report generated successfully';

  @override
  String pdfExportError(String error) {
    return 'Failed to generate PDF: $error';
  }

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

  @override
  String get viewAll => 'View All';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsDescription =>
      'Configure reminders and notifications for your diary entries.';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get enableNotificationsDescription =>
      'Turn on daily reminders to write in your diary';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get reminderTimeDescription => 'Choose when you want to be reminded';

  @override
  String get smartReminders => 'Smart Reminders';

  @override
  String get smartRemindersDescription =>
      'Only remind if you haven\'t written today\'s entry';

  @override
  String get streakWarnings => 'Streak Warnings';

  @override
  String get streakWarningsDescription =>
      'Get notified when your writing streak is at risk';

  @override
  String get notificationPermissionDenied =>
      'Notification permission was denied. Please enable it in settings.';

  @override
  String get selectReminderTime => 'Select reminder time';

  @override
  String get goalsSectionTitle => 'Goals';

  @override
  String get goalCreateNew => 'Create Goal';

  @override
  String get goalCreate => 'Create';

  @override
  String get goalSelectCategory => 'Which area do you want to improve?';

  @override
  String get goalSelectTimeframe => 'Choose your timeframe';

  @override
  String get goalSetTarget => 'Set your target';

  @override
  String goalTargetHint(String category) {
    return 'What average $category score do you want to achieve?';
  }

  @override
  String get goalWeekly => 'Weekly';

  @override
  String get goalMonthly => 'Monthly';

  @override
  String get goalDaysLeft => 'days left';

  @override
  String get goalDaysRemaining => 'Days Left';

  @override
  String get goalCurrentAverage => 'Current';

  @override
  String get goalTarget => 'Target';

  @override
  String get goalTargetLabel => 'Target Score';

  @override
  String goalSuggestedTarget(String target) {
    return 'Based on your history, we suggest $target';
  }

  @override
  String get goalUseSuggestion => 'Use';

  @override
  String get goalEmptyTitle => 'No active goals';

  @override
  String get goalEmptySubtitle =>
      'Set a goal to track your progress and stay motivated';

  @override
  String get goalSetFirst => 'Set Your First Goal';

  @override
  String get goalStatusOnTrack => 'On track';

  @override
  String get goalStatusBehind => 'Needs attention';

  @override
  String get goalStatusAhead => 'Exceeding target!';

  @override
  String get goalStatusCompleted => 'Goal achieved!';

  @override
  String get goalStatusFailed => 'Goal not met';

  @override
  String get goalStreak => 'Goal Streak';

  @override
  String get goalHistory => 'Goal History';

  @override
  String get goalSuccessRate => 'Success Rate';

  @override
  String get days => 'days';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get photos => 'Photos';

  @override
  String get noPhotos => 'No photos attached';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get deletePhotoConfirm =>
      'Are you sure you want to delete this photo?';

  @override
  String get imageNotFound => 'Image not found';

  @override
  String get drawerHabits => 'Habits';

  @override
  String get habitsTitle => 'Habits';

  @override
  String get habitsToday => 'Today';

  @override
  String get habitsGrid => 'Grid';

  @override
  String get habitsStats => 'Stats';

  @override
  String get habitName => 'Habit Name';

  @override
  String get habitNameRequired => 'Please enter a habit name';

  @override
  String get habitDescription => 'Description';

  @override
  String get habitIconAndColor => 'Tap to change icon or color';

  @override
  String get habitFrequency => 'Frequency';

  @override
  String get habitFrequencyDaily => 'Daily';

  @override
  String get habitFrequencyWeekdays => 'Weekdays';

  @override
  String get habitFrequencyWeekends => 'Weekends';

  @override
  String get habitFrequencySpecificDays => 'Specific Days';

  @override
  String get habitFrequencyTimesPerWeek => 'Times/Week';

  @override
  String get habitTargetCount => 'Target Count';

  @override
  String get habitTimesPerWeekLabel => 'Times per week';

  @override
  String get habitCreateNew => 'New Habit';

  @override
  String get habitEdit => 'Edit Habit';

  @override
  String get habitArchive => 'Archive Habit';

  @override
  String get habitUnarchive => 'Unarchive Habit';

  @override
  String get habitNoHabits => 'No habits yet';

  @override
  String get habitNoHabitsDescription =>
      'Create habits to track your daily routines';

  @override
  String get habitCreateFirst => 'Create Your First Habit';

  @override
  String get habitCompleted => 'Completed';

  @override
  String get habitProgress => 'Progress';

  @override
  String get habitDueToday => 'Due Today';

  @override
  String get habitCurrentStreak => 'Current Streak';

  @override
  String get habitBestStreak => 'Best Streak';

  @override
  String get habitCompletionRate => 'Completion Rate';

  @override
  String get habitLast7Days => 'Last 7 days';

  @override
  String get habitLast30Days => 'Last 30 days';

  @override
  String get habitAllTime => 'All time';

  @override
  String get habitTotalCompletions => 'Total Completions';

  @override
  String get habitSelectIcon => 'Select Icon';

  @override
  String get habitSelectColor => 'Select Color';

  @override
  String get habitSelectAtLeastOneDay => 'Please select at least one day';

  @override
  String get habitDayMon => 'Mon';

  @override
  String get habitDayTue => 'Tue';

  @override
  String get habitDayWed => 'Wed';

  @override
  String get habitDayThu => 'Thu';

  @override
  String get habitDayFri => 'Fri';

  @override
  String get habitDaySat => 'Sat';

  @override
  String get habitDaySun => 'Sun';

  @override
  String get habitDeleteConfirm =>
      'Are you sure you want to delete this habit and all its entries?';

  @override
  String get habitDeleteTitle => 'Delete Habit';

  @override
  String get habitTodayProgress => 'Today\'s Progress';

  @override
  String get habitAllHabitsCompleted => 'All habits completed!';

  @override
  String get habitContributionGrid => 'Contribution Grid';

  @override
  String get habitLess => 'Less';

  @override
  String get habitMore => 'More';

  @override
  String get biometricSettings => 'Biometric Login';

  @override
  String get biometricSettingsDescription =>
      'Use fingerprint or face recognition to unlock the app';

  @override
  String get enableBiometric => 'Enable biometric login';

  @override
  String get enableBiometricDescription =>
      'Unlock the app with your fingerprint or face';

  @override
  String get biometricLockOnResume => 'Lock on app switch';

  @override
  String get biometricLockOnResumeDescription =>
      'Require biometric when returning to app';

  @override
  String get biometricLockTimeout => 'Lock timeout';

  @override
  String get biometricLockTimeoutDescription =>
      'Time before requiring re-authentication';

  @override
  String get biometricImmediately => 'Immediately';

  @override
  String biometricMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get biometricTestButton => 'Test biometric';

  @override
  String get biometricTestSuccess => 'Biometric authentication successful';

  @override
  String get biometricTestFailed => 'Biometric authentication failed';

  @override
  String get biometricNotAvailable =>
      'Biometric authentication not available on this device';

  @override
  String get biometricNotEnrolled => 'No biometrics enrolled on this device';

  @override
  String get biometricUnlockPrompt => 'Unlock SimpleDiary';

  @override
  String get biometricTapToUnlock => 'Tap to unlock with biometrics';

  @override
  String get usePasswordInstead => 'Use password instead';

  @override
  String get biometricRetry => 'Try again';

  @override
  String get biometricEnrollSuccess => 'Biometric login enabled successfully';

  @override
  String get biometricEnrollFailed => 'Could not enable biometric login';

  @override
  String get backupSettings => 'Automatic Backups';

  @override
  String get backupSettingsDescription =>
      'Configure automatic backups to protect your diary data.';

  @override
  String get enableAutoBackup => 'Enable Automatic Backups';

  @override
  String get enableAutoBackupDescription =>
      'Automatically back up your data on a regular schedule';

  @override
  String get backupFrequency => 'Backup Frequency';

  @override
  String get backupFrequencyDescription =>
      'How often should automatic backups run';

  @override
  String get backupFrequencyDaily => 'Daily';

  @override
  String get backupFrequencyWeekly => 'Weekly';

  @override
  String get backupFrequencyMonthly => 'Monthly';

  @override
  String get backupPreferredTime => 'Preferred Time';

  @override
  String get backupPreferredTimeDescription =>
      'When to run the automatic backup';

  @override
  String get backupWifiOnly => 'WiFi Only';

  @override
  String get backupWifiOnlyDescription =>
      'Only run backups when connected to WiFi (Android)';

  @override
  String get backupMaxCount => 'Keep Backups';

  @override
  String get backupMaxCountDescription => 'Maximum number of backups to keep';

  @override
  String backupMaxCountValue(int count) {
    return '$count backups';
  }

  @override
  String get backupNow => 'Backup Now';

  @override
  String get backupNowDescription => 'Create a manual backup immediately';

  @override
  String get backupHistory => 'Backup History';

  @override
  String get backupHistoryDescription => 'View and manage your backups';

  @override
  String lastBackup(String time) {
    return 'Last backup: $time';
  }

  @override
  String get lastBackupNever => 'Last backup: Never';

  @override
  String get backupCreating => 'Creating backup...';

  @override
  String get backupSuccess => 'Backup created successfully';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupRestoring => 'Restoring backup...';

  @override
  String get backupRestoreSuccess =>
      'Backup restored successfully. Please restart the app.';

  @override
  String backupRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get backupRestoreConfirm => 'Restore Backup';

  @override
  String backupRestoreConfirmMessage(String date) {
    return 'This will replace all current data with the backup from $date. A safety backup will be created first. Continue?';
  }

  @override
  String get backupDeleteConfirm => 'Delete Backup';

  @override
  String get backupDeleteConfirmMessage =>
      'Are you sure you want to delete this backup?';

  @override
  String get backupDeleted => 'Backup deleted';

  @override
  String backupStorageUsed(String size) {
    return 'Storage used: $size';
  }

  @override
  String backupEntries(int days, int notes, int habits) {
    return '$days days, $notes notes, $habits habits';
  }

  @override
  String get backupTypeManual => 'Manual';

  @override
  String get backupTypeScheduled => 'Scheduled';

  @override
  String get backupTypePreRestore => 'Pre-restore';

  @override
  String get backupNoBackups => 'No backups yet';

  @override
  String get backupNoBackupsDescription =>
      'Enable automatic backups or create a manual backup to protect your data';

  @override
  String get backupOverdue => 'Backup overdue';

  @override
  String get backupDestination => 'Backup Destination';

  @override
  String get backupDestinationDescription =>
      'Choose where your backups should be stored';

  @override
  String get backupDestinationRequiresSupabase =>
      'Configure Supabase settings first to enable cloud storage';

  @override
  String get backupDestinationLocal => 'Local';

  @override
  String get backupDestinationCloud => 'Cloud';

  @override
  String get backupDestinationBoth => 'Both';

  @override
  String get backupUploadToCloud => 'Upload';

  @override
  String get backupUploadSuccess => 'Backup uploaded to cloud';

  @override
  String backupUploadFailed(String error) {
    return 'Cloud upload failed: $error';
  }

  @override
  String get backupCloudBackups => 'Cloud Backups';

  @override
  String get backupDownloadFromCloud => 'Download';

  @override
  String get backupDownloadSuccess => 'Backup downloaded from cloud';

  @override
  String backupDownloadFailed(String error) {
    return 'Cloud download failed: $error';
  }

  @override
  String get backupCloudDeleteConfirm => 'Delete from Cloud';

  @override
  String get backupCloudDeleteConfirmMessage =>
      'Are you sure you want to delete this backup from cloud storage?';

  @override
  String get backupCloudDeleted => 'Backup deleted from cloud';

  @override
  String get backupCloudNoBackups => 'No cloud backups found';

  @override
  String get backupLocation => 'Backup Location';

  @override
  String get backupLocationDescription =>
      'Choose where local backups are stored on this device';

  @override
  String backupLocationDefault(String path) {
    return 'Default ($path)';
  }

  @override
  String backupLocationCustom(String path) {
    return 'Custom: $path';
  }

  @override
  String get backupLocationChange => 'Change';

  @override
  String get backupLocationReset => 'Reset to Default';

  @override
  String get onboardingWelcomeTitle => 'Welcome to SimpleDiary';

  @override
  String get onboardingWelcomeDescription =>
      'Your personal daily reflection companion.\nTrack your days, discover patterns, and grow every week.';

  @override
  String get onboardingRatingsTitle => 'Rate Your Day';

  @override
  String get onboardingRatingsDescription =>
      'Score four key areas every day:\nSocial · Productivity · Sport · Food.\nSee at a glance how balanced your life is.';

  @override
  String get onboardingNotesTitle => 'Add Activities';

  @override
  String get onboardingNotesDescription =>
      'Log notes and events with categories like Work, Gym, Leisure and more.\nEverything appears on your personal calendar.';

  @override
  String get onboardingInsightsTitle => 'Discover Patterns';

  @override
  String get onboardingInsightsDescription =>
      'The dashboard shows streaks, weekly stats and insights.\nFind out which activities boost your mood the most.';

  @override
  String get onboardingGetStartedTitle => 'Ready to Start?';

  @override
  String get onboardingGetStartedDescription =>
      'Explore with sample data first, or jump straight in and create your account.';

  @override
  String get onboardingExploreDemo => 'Explore with Demo Data';

  @override
  String get onboardingCreateAccount => 'Create Account';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get setupWizardTitle => 'Quick Setup';

  @override
  String get setupWizardThemeTitle => 'Choose Your Theme';

  @override
  String get setupWizardThemeHint => 'You can change this anytime in Settings.';

  @override
  String get setupWizardThemeLight => 'Light';

  @override
  String get setupWizardThemeDark => 'Dark';

  @override
  String get setupWizardLanguageTitle => 'Choose Your Language';

  @override
  String get setupWizardLanguageHint =>
      'You can change this anytime in Settings.';

  @override
  String get setupWizardNext => 'Next';

  @override
  String get setupWizardDone => 'Done';

  @override
  String get demoModeBannerText => 'Exploring with demo data';

  @override
  String get demoModeCreateAccount => 'Create Account';
}
