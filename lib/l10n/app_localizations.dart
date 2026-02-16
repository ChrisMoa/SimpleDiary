import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple Diary'**
  String get appTitle;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get drawerCalendar;

  /// No description provided for @drawerDiaryWizard.
  ///
  /// In en, this message translates to:
  /// **'Diary Wizard'**
  String get drawerDiaryWizard;

  /// No description provided for @drawerNotesOverview.
  ///
  /// In en, this message translates to:
  /// **'Notes Overview'**
  String get drawerNotesOverview;

  /// No description provided for @drawerTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get drawerTemplates;

  /// No description provided for @drawerSync.
  ///
  /// In en, this message translates to:
  /// **'Datasynchronization'**
  String get drawerSync;

  /// No description provided for @drawerAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAbout;

  /// No description provided for @drawerErrorInvalidEntry.
  ///
  /// In en, this message translates to:
  /// **'Error: Invalid entry'**
  String get drawerErrorInvalidEntry;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessfully;

  /// No description provided for @errorSavingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings: {error}'**
  String errorSavingSettings(String error);

  /// No description provided for @noteCategories.
  ///
  /// In en, this message translates to:
  /// **'Note Categories'**
  String get noteCategories;

  /// No description provided for @manageCategoriesAndTags.
  ///
  /// In en, this message translates to:
  /// **'Manage your note categories and tags'**
  String get manageCategoriesAndTags;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @customizeAppearance.
  ///
  /// In en, this message translates to:
  /// **'Customize the appearance of your diary application.'**
  String get customizeAppearance;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @clickColorToChange.
  ///
  /// In en, this message translates to:
  /// **'Click this color to change it in a dialog'**
  String get clickColorToChange;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @toggleDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Toggle this button to switch between dark and light theme'**
  String get toggleDarkMode;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get selectColor;

  /// No description provided for @selectColorShade.
  ///
  /// In en, this message translates to:
  /// **'Select color shade'**
  String get selectColorShade;

  /// No description provided for @selectedColorAndShades.
  ///
  /// In en, this message translates to:
  /// **'Selected color and its shades'**
  String get selectedColorAndShades;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the application interface.'**
  String get languageDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @remoteAccount.
  ///
  /// In en, this message translates to:
  /// **'Remote Account?'**
  String get remoteAccount;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authenticationError;

  /// No description provided for @invalidUsernameOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password. Please try again.'**
  String get invalidUsernameOrPassword;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedError(String error);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @enterPasswordToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue'**
  String get enterPasswordToContinue;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @switchUser.
  ///
  /// In en, this message translates to:
  /// **'Switch User'**
  String get switchUser;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettings;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @doYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout?'**
  String get doYouWantToLogout;

  /// No description provided for @doYouWantToOverwriteUserdata.
  ///
  /// In en, this message translates to:
  /// **'Do you want to overwrite your userdata?'**
  String get doYouWantToOverwriteUserdata;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure that you want to logout?'**
  String get logoutMessage;

  /// No description provided for @stayHere.
  ///
  /// In en, this message translates to:
  /// **'stay here'**
  String get stayHere;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @recordToday.
  ///
  /// In en, this message translates to:
  /// **'Record today'**
  String get recordToday;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @weeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get weeklyAverage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @sevenDayOverview.
  ///
  /// In en, this message translates to:
  /// **'7-Day Overview'**
  String get sevenDayOverview;

  /// No description provided for @ratingTrend.
  ///
  /// In en, this message translates to:
  /// **'Rating Trend'**
  String get ratingTrend;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @insightsAndAchievements.
  ///
  /// In en, this message translates to:
  /// **'Insights & Achievements'**
  String get insightsAndAchievements;

  /// No description provided for @errorLoadingInsights.
  ///
  /// In en, this message translates to:
  /// **'Error loading insights: {error}'**
  String errorLoadingInsights(String error);

  /// No description provided for @weekNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String weekNumber(int number);

  /// No description provided for @milestoneReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached an important milestone!'**
  String get milestoneReached;

  /// No description provided for @perfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week!'**
  String get perfectWeek;

  /// No description provided for @perfectWeekDescription.
  ///
  /// In en, this message translates to:
  /// **'You logged all days this week!'**
  String get perfectWeekDescription;

  /// No description provided for @notRecordedToday.
  ///
  /// In en, this message translates to:
  /// **'Not recorded today'**
  String get notRecordedToday;

  /// No description provided for @rememberToRate.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to rate your day today!'**
  String get rememberToRate;

  /// No description provided for @bestCategory.
  ///
  /// In en, this message translates to:
  /// **'Best Category'**
  String get bestCategory;

  /// No description provided for @bestCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your best category this week: {category}!'**
  String bestCategoryDescription(String category);

  /// No description provided for @moodPatterns.
  ///
  /// In en, this message translates to:
  /// **'Mood Patterns'**
  String get moodPatterns;

  /// No description provided for @patternInsight.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get patternInsight;

  /// No description provided for @trendInsight.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendInsight;

  /// No description provided for @weeklyInsight.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyInsight;

  /// No description provided for @tipInsight.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tipInsight;

  /// No description provided for @dayDetail.
  ///
  /// In en, this message translates to:
  /// **'Day Detail: {date}'**
  String dayDetail(String date);

  /// No description provided for @noDiaryEntryForDay.
  ///
  /// In en, this message translates to:
  /// **'No diary entry for this day'**
  String get noDiaryEntryForDay;

  /// No description provided for @errorLoadingNotes.
  ///
  /// In en, this message translates to:
  /// **'Error loading notes: {error}'**
  String errorLoadingNotes(String error);

  /// No description provided for @errorLoadingDiaryDay.
  ///
  /// In en, this message translates to:
  /// **'Error loading diary day: {error}'**
  String errorLoadingDiaryDay(String error);

  /// No description provided for @addANote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addANote;

  /// No description provided for @daySummary.
  ///
  /// In en, this message translates to:
  /// **'Day Summary'**
  String get daySummary;

  /// No description provided for @notesAndActivities.
  ///
  /// In en, this message translates to:
  /// **'Notes & Activities'**
  String get notesAndActivities;

  /// No description provided for @nEntries.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String nEntries(int count);

  /// No description provided for @noNotesForDay.
  ///
  /// In en, this message translates to:
  /// **'No notes for this day'**
  String get noNotesForDay;

  /// No description provided for @addThoughtsActivitiesMemories.
  ///
  /// In en, this message translates to:
  /// **'Add your thoughts, activities or memories'**
  String get addThoughtsActivitiesMemories;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @overallMood.
  ///
  /// In en, this message translates to:
  /// **'Overall Mood: {mood}'**
  String overallMood(String mood);

  /// No description provided for @deleteDiaryEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Diary Entry'**
  String get deleteDiaryEntry;

  /// No description provided for @confirmDeleteDiaryEntry.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this diary entry? This will remove both the day rating and all associated notes.'**
  String get confirmDeleteDiaryEntry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @ratingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get ratingGreat;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingExcellent;

  /// No description provided for @moodToughDay.
  ///
  /// In en, this message translates to:
  /// **'Tough Day'**
  String get moodToughDay;

  /// No description provided for @moodCouldBeBetter.
  ///
  /// In en, this message translates to:
  /// **'Could Be Better'**
  String get moodCouldBeBetter;

  /// No description provided for @moodPrettyGood.
  ///
  /// In en, this message translates to:
  /// **'Pretty Good'**
  String get moodPrettyGood;

  /// No description provided for @moodGreatDay.
  ///
  /// In en, this message translates to:
  /// **'Great Day'**
  String get moodGreatDay;

  /// No description provided for @moodPerfectDay.
  ///
  /// In en, this message translates to:
  /// **'Perfect Day'**
  String get moodPerfectDay;

  /// No description provided for @noDiaryEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No diary entries yet'**
  String get noDiaryEntriesYet;

  /// No description provided for @startTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your day by adding notes\nand completing daily evaluations'**
  String get startTrackingDescription;

  /// No description provided for @startTodaysJournal.
  ///
  /// In en, this message translates to:
  /// **'Start Today\'s Journal'**
  String get startTodaysJournal;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeleteDiaryEntryShort.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this diary entry?'**
  String get confirmDeleteDiaryEntryShort;

  /// No description provided for @diaryEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Diary entry deleted'**
  String get diaryEntryDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @loadingDayData.
  ///
  /// In en, this message translates to:
  /// **'Loading your day data...'**
  String get loadingDayData;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @noteDetails.
  ///
  /// In en, this message translates to:
  /// **'Note Details'**
  String get noteDetails;

  /// No description provided for @dayRating.
  ///
  /// In en, this message translates to:
  /// **'Day Rating'**
  String get dayRating;

  /// No description provided for @howWasYourDay.
  ///
  /// In en, this message translates to:
  /// **'How was your day? Rate the different aspects of your experience.'**
  String get howWasYourDay;

  /// No description provided for @saveDayRating.
  ///
  /// In en, this message translates to:
  /// **'Save Day Rating'**
  String get saveDayRating;

  /// No description provided for @dayRatingSaved.
  ///
  /// In en, this message translates to:
  /// **'Day rating saved successfully!'**
  String get dayRatingSaved;

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'Not Rated'**
  String get notRated;

  /// No description provided for @ratingSocialDescription.
  ///
  /// In en, this message translates to:
  /// **'How were your social interactions and relationships today?'**
  String get ratingSocialDescription;

  /// No description provided for @ratingProductivityDescription.
  ///
  /// In en, this message translates to:
  /// **'How productive were you in your work or daily tasks?'**
  String get ratingProductivityDescription;

  /// No description provided for @ratingSportDescription.
  ///
  /// In en, this message translates to:
  /// **'How was your physical activity and exercise today?'**
  String get ratingSportDescription;

  /// No description provided for @ratingFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'How healthy and satisfying was your diet today?'**
  String get ratingFoodDescription;

  /// No description provided for @tapToChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to change date'**
  String get tapToChangeDate;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Title'**
  String get addTitle;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @allDayQuestion.
  ///
  /// In en, this message translates to:
  /// **'AllDay?'**
  String get allDayQuestion;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @saveUpperCase.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveUpperCase;

  /// No description provided for @saveWord.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get saveWord;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'reload'**
  String get reload;

  /// No description provided for @noteUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Was not able to update note'**
  String get noteUpdateError;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @organizeCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Organize your notes with custom categories'**
  String get organizeCategoriesDescription;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @createCategoriesToOrganize.
  ///
  /// In en, this message translates to:
  /// **'Create categories to organize your notes'**
  String get createCategoriesToOrganize;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryColor.
  ///
  /// In en, this message translates to:
  /// **'Category Color'**
  String get categoryColor;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists'**
  String get categoryAlreadyExists;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get categoryCreated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @cannotDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Cannot Delete Category'**
  String get cannotDeleteCategory;

  /// No description provided for @categoryInUse.
  ///
  /// In en, this message translates to:
  /// **'The category \"{title}\" is currently used by one or more notes. Please reassign or delete those notes first.'**
  String categoryInUse(String title);

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String confirmDeleteCategory(String title);

  /// No description provided for @editCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategoryTooltip;

  /// No description provided for @deleteCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTooltip;

  /// No description provided for @defaultCategoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get defaultCategoryWork;

  /// No description provided for @defaultCategoryLeisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get defaultCategoryLeisure;

  /// No description provided for @defaultCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get defaultCategoryFood;

  /// No description provided for @defaultCategoryGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get defaultCategoryGym;

  /// No description provided for @defaultCategorySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get defaultCategorySleep;

  /// No description provided for @noteTemplates.
  ///
  /// In en, this message translates to:
  /// **'Note Templates'**
  String get noteTemplates;

  /// No description provided for @selectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select Template'**
  String get selectTemplate;

  /// No description provided for @noTemplatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No templates available'**
  String get noTemplatesAvailable;

  /// No description provided for @noTemplatesYet.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplatesYet;

  /// No description provided for @createTemplatesToQuicklyAdd.
  ///
  /// In en, this message translates to:
  /// **'Create templates to quickly add notes'**
  String get createTemplatesToQuicklyAdd;

  /// No description provided for @createTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create Template'**
  String get createTemplate;

  /// No description provided for @editTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get editTemplate;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @pleaseEnterTemplateName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name'**
  String get pleaseEnterTemplateName;

  /// No description provided for @pleaseEnterDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter duration'**
  String get pleaseEnterDuration;

  /// No description provided for @pleaseEnterValidDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid duration'**
  String get pleaseEnterValidDuration;

  /// No description provided for @simple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get simple;

  /// No description provided for @sections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get sections;

  /// No description provided for @addSection.
  ///
  /// In en, this message translates to:
  /// **'Add Section'**
  String get addSection;

  /// No description provided for @sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Section Title'**
  String get sectionTitle;

  /// No description provided for @hintOptional.
  ///
  /// In en, this message translates to:
  /// **'Hint (optional)'**
  String get hintOptional;

  /// No description provided for @removeSection.
  ///
  /// In en, this message translates to:
  /// **'Remove section'**
  String get removeSection;

  /// No description provided for @templateUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Template updated successfully'**
  String get templateUpdatedSuccessfully;

  /// No description provided for @templateCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Template created successfully'**
  String get templateCreatedSuccessfully;

  /// No description provided for @deleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplate;

  /// No description provided for @confirmDeleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String confirmDeleteTemplate(String title);

  /// No description provided for @templateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleted;

  /// No description provided for @durationInMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationInMinutes(int minutes);

  /// No description provided for @descriptionSections.
  ///
  /// In en, this message translates to:
  /// **'Description Sections:'**
  String get descriptionSections;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionLabel;

  /// No description provided for @addedTemplateAtTime.
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\" at {time}'**
  String addedTemplateAtTime(String title, String time);

  /// No description provided for @errorCreatingNote.
  ///
  /// In en, this message translates to:
  /// **'Error creating note: {error}'**
  String errorCreatingNote(String error);

  /// No description provided for @fileSynchronization.
  ///
  /// In en, this message translates to:
  /// **'File Synchronization'**
  String get fileSynchronization;

  /// No description provided for @fileSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Import and export your diary data to JSON or ICS calendar files with optional encryption.'**
  String get fileSyncDescription;

  /// No description provided for @exportToJson.
  ///
  /// In en, this message translates to:
  /// **'Export to JSON'**
  String get exportToJson;

  /// No description provided for @saveYourDiaryData.
  ///
  /// In en, this message translates to:
  /// **'Save your diary data to a file'**
  String get saveYourDiaryData;

  /// No description provided for @importFromJson.
  ///
  /// In en, this message translates to:
  /// **'Import from JSON'**
  String get importFromJson;

  /// No description provided for @loadDiaryData.
  ///
  /// In en, this message translates to:
  /// **'Load diary data from a file'**
  String get loadDiaryData;

  /// No description provided for @exportToIcsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Export to ICS Calendar'**
  String get exportToIcsCalendar;

  /// No description provided for @saveNotesAsCalendarEvents.
  ///
  /// In en, this message translates to:
  /// **'Save notes as calendar events (.ics)'**
  String get saveNotesAsCalendarEvents;

  /// No description provided for @importFromIcsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Import from ICS Calendar'**
  String get importFromIcsCalendar;

  /// No description provided for @loadCalendarEvents.
  ///
  /// In en, this message translates to:
  /// **'Load calendar events from .ics file'**
  String get loadCalendarEvents;

  /// No description provided for @exportRange.
  ///
  /// In en, this message translates to:
  /// **'Export Range'**
  String get exportRange;

  /// No description provided for @whichEntriesToExport.
  ///
  /// In en, this message translates to:
  /// **'Which entries do you want to export?'**
  String get whichEntriesToExport;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @encryptJsonExport.
  ///
  /// In en, this message translates to:
  /// **'Encrypt JSON Export (Optional)'**
  String get encryptJsonExport;

  /// No description provided for @decryptJsonImport.
  ///
  /// In en, this message translates to:
  /// **'Decrypt JSON Import'**
  String get decryptJsonImport;

  /// No description provided for @encryptIcsExport.
  ///
  /// In en, this message translates to:
  /// **'Encrypt ICS Export (Optional)'**
  String get encryptIcsExport;

  /// No description provided for @decryptIcsImport.
  ///
  /// In en, this message translates to:
  /// **'Decrypt ICS Import'**
  String get decryptIcsImport;

  /// No description provided for @passwordOptional.
  ///
  /// In en, this message translates to:
  /// **'Password (Optional)'**
  String get passwordOptional;

  /// No description provided for @leaveEmptyForNoEncryption.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for no encryption'**
  String get leaveEmptyForNoEncryption;

  /// No description provided for @saveJsonExportFile.
  ///
  /// In en, this message translates to:
  /// **'Save JSON Export File'**
  String get saveJsonExportFile;

  /// No description provided for @selectJsonFileToImport.
  ///
  /// In en, this message translates to:
  /// **'Select JSON File to Import'**
  String get selectJsonFileToImport;

  /// No description provided for @saveIcsCalendarFile.
  ///
  /// In en, this message translates to:
  /// **'Save ICS Calendar File'**
  String get saveIcsCalendarFile;

  /// No description provided for @selectIcsFileToImport.
  ///
  /// In en, this message translates to:
  /// **'Select ICS Calendar File to Import'**
  String get selectIcsFileToImport;

  /// No description provided for @operationCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get operationCompletedSuccessfully;

  /// No description provided for @importedDaysWithNotes.
  ///
  /// In en, this message translates to:
  /// **'Imported {days} days with {notes} notes'**
  String importedDaysWithNotes(int days, int notes);

  /// No description provided for @importedNotesFromIcs.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} notes from ICS calendar'**
  String importedNotesFromIcs(int count);

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// No description provided for @oldEncryptionFormatError.
  ///
  /// In en, this message translates to:
  /// **'This file uses the old encryption format and cannot be imported.\nPlease export your data again with the new version.'**
  String get oldEncryptionFormatError;

  /// No description provided for @passwordRequiredForEncryptedFile.
  ///
  /// In en, this message translates to:
  /// **'Password required for encrypted file'**
  String get passwordRequiredForEncryptedFile;

  /// No description provided for @passwordRequiredForEncryptedIcsFile.
  ///
  /// In en, this message translates to:
  /// **'Password required for encrypted ICS file'**
  String get passwordRequiredForEncryptedIcsFile;

  /// No description provided for @cannotReadIcsFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot read ICS file. File may be corrupted.'**
  String get cannotReadIcsFile;

  /// No description provided for @pleaseEnterAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseEnterAllFields;

  /// No description provided for @fillInYourCompleteDay.
  ///
  /// In en, this message translates to:
  /// **'Fill in your complete day'**
  String get fillInYourCompleteDay;

  /// No description provided for @testingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing connection...'**
  String get testingConnection;

  /// No description provided for @connectionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Connection successful!'**
  String get connectionSuccessful;

  /// No description provided for @connectionFailedAuth.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: Authentication error'**
  String get connectionFailedAuth;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {error}'**
  String connectionFailed(String error);

  /// No description provided for @synchronization.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get synchronization;

  /// No description provided for @supabaseSynchronization.
  ///
  /// In en, this message translates to:
  /// **'Supabase Synchronization'**
  String get supabaseSynchronization;

  /// No description provided for @supabaseSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Sync your diary data with Supabase cloud storage for backup and cross-device access.'**
  String get supabaseSyncDescription;

  /// No description provided for @uploadToSupabase.
  ///
  /// In en, this message translates to:
  /// **'Upload to Supabase'**
  String get uploadToSupabase;

  /// No description provided for @saveYourDiaryDataToCloud.
  ///
  /// In en, this message translates to:
  /// **'Save your diary data to the cloud'**
  String get saveYourDiaryDataToCloud;

  /// No description provided for @downloadFromSupabase.
  ///
  /// In en, this message translates to:
  /// **'Download from Supabase'**
  String get downloadFromSupabase;

  /// No description provided for @loadDiaryDataFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Load diary data from the cloud'**
  String get loadDiaryDataFromCloud;

  /// No description provided for @supabaseSettings.
  ///
  /// In en, this message translates to:
  /// **'Supabase Settings'**
  String get supabaseSettings;

  /// No description provided for @supabaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure your Supabase cloud storage settings for backup and cross-device access.'**
  String get supabaseDescription;

  /// No description provided for @supabaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Supabase URL'**
  String get supabaseUrl;

  /// No description provided for @anonKey.
  ///
  /// In en, this message translates to:
  /// **'Anon Key'**
  String get anonKey;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @pdfExport.
  ///
  /// In en, this message translates to:
  /// **'PDF Export'**
  String get pdfExport;

  /// No description provided for @pdfExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate printable PDF reports with your diary entries, ratings, and statistics.'**
  String get pdfExportDescription;

  /// No description provided for @quickExport.
  ///
  /// In en, this message translates to:
  /// **'Quick Export'**
  String get quickExport;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get lastWeek;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get lastMonth;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get currentMonth;

  /// No description provided for @selectDateRangeForReport.
  ///
  /// In en, this message translates to:
  /// **'Select a custom date range for your report'**
  String get selectDateRangeForReport;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @selectSpecificMonth.
  ///
  /// In en, this message translates to:
  /// **'Choose a specific month to export'**
  String get selectSpecificMonth;

  /// No description provided for @exportAllData.
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get exportAllData;

  /// No description provided for @generatePdfWithAllData.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF report with all your data'**
  String get generatePdfWithAllData;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range for report'**
  String get selectDateRange;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @pdfExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF report generated successfully'**
  String get pdfExportSuccess;

  /// No description provided for @pdfExportError.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF: {error}'**
  String pdfExportError(String error);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @dayTracker.
  ///
  /// In en, this message translates to:
  /// **'Day Tracker'**
  String get dayTracker;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version(String version);

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @viewLicenses.
  ///
  /// In en, this message translates to:
  /// **'View Licenses'**
  String get viewLicenses;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Day Tracker is a personal diary and productivity app that helps you track your daily activities and rate different aspects of your day.'**
  String get appDescription;

  /// No description provided for @featureTrackActivities.
  ///
  /// In en, this message translates to:
  /// **'Track daily activities and appointments'**
  String get featureTrackActivities;

  /// No description provided for @featureRateDay.
  ///
  /// In en, this message translates to:
  /// **'Rate different aspects of your day'**
  String get featureRateDay;

  /// No description provided for @featureCalendar.
  ///
  /// In en, this message translates to:
  /// **'View your schedule in a calendar'**
  String get featureCalendar;

  /// No description provided for @featureEncryption.
  ///
  /// In en, this message translates to:
  /// **'Secure data with encryption'**
  String get featureEncryption;

  /// No description provided for @featureSync.
  ///
  /// In en, this message translates to:
  /// **'Sync data across devices with Supabase'**
  String get featureSync;

  /// No description provided for @featureExportImport.
  ///
  /// In en, this message translates to:
  /// **'Export and import data'**
  String get featureExportImport;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Your Company'**
  String copyright(int year);

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String score(int score);

  /// No description provided for @createNote.
  ///
  /// In en, this message translates to:
  /// **'Create Note'**
  String get createNote;

  /// No description provided for @fromTemplate.
  ///
  /// In en, this message translates to:
  /// **'From Template'**
  String get fromTemplate;

  /// No description provided for @noNoteSelected.
  ///
  /// In en, this message translates to:
  /// **'No note selected'**
  String get noNoteSelected;

  /// No description provided for @clickExistingOrCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Click on an existing note or create a new one'**
  String get clickExistingOrCreateNew;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @stopDictation.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get stopDictation;

  /// No description provided for @dictateDescription.
  ///
  /// In en, this message translates to:
  /// **'Dictate description'**
  String get dictateDescription;

  /// No description provided for @addDetailsAboutNote.
  ///
  /// In en, this message translates to:
  /// **'Add details about this note...'**
  String get addDetailsAboutNote;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @confirmDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get confirmDeleteNote;

  /// No description provided for @endTimeAfterStartTime.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endTimeAfterStartTime;

  /// No description provided for @addedNoteAtTime.
  ///
  /// In en, this message translates to:
  /// **'Added new note at {time}'**
  String addedNoteAtTime(String time);

  /// No description provided for @dailySchedule.
  ///
  /// In en, this message translates to:
  /// **'Daily Schedule'**
  String get dailySchedule;

  /// No description provided for @scheduleComplete.
  ///
  /// In en, this message translates to:
  /// **'Schedule complete'**
  String get scheduleComplete;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @fromTime.
  ///
  /// In en, this message translates to:
  /// **'From: {time}'**
  String fromTime(String time);

  /// No description provided for @toTime.
  ///
  /// In en, this message translates to:
  /// **'To: {time}'**
  String toTime(String time);

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotes;

  /// No description provided for @searchNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by title or description'**
  String get searchNotesPlaceholder;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get filterByCategory;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get dateTo;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @noNotesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No notes match your search'**
  String get noNotesMatchSearch;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria'**
  String get tryDifferentSearch;

  /// No description provided for @nResultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String nResultsFound(int count);

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoriteDays.
  ///
  /// In en, this message translates to:
  /// **'Favorite Days'**
  String get favoriteDays;

  /// No description provided for @favoriteNotes.
  ///
  /// In en, this message translates to:
  /// **'Favorite Notes'**
  String get favoriteNotes;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @noFavoriteDays.
  ///
  /// In en, this message translates to:
  /// **'No favorite days'**
  String get noFavoriteDays;

  /// No description provided for @noFavoriteNotes.
  ///
  /// In en, this message translates to:
  /// **'No favorite notes'**
  String get noFavoriteNotes;

  /// No description provided for @markAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite'**
  String get markAsFavorite;

  /// No description provided for @unmarkAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Unmark as favorite'**
  String get unmarkAsFavorite;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @goalsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsSectionTitle;

  /// No description provided for @goalCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get goalCreateNew;

  /// No description provided for @goalCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get goalCreate;

  /// No description provided for @goalSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Which area do you want to improve?'**
  String get goalSelectCategory;

  /// No description provided for @goalSelectTimeframe.
  ///
  /// In en, this message translates to:
  /// **'Choose your timeframe'**
  String get goalSelectTimeframe;

  /// No description provided for @goalSetTarget.
  ///
  /// In en, this message translates to:
  /// **'Set your target'**
  String get goalSetTarget;

  /// No description provided for @goalTargetHint.
  ///
  /// In en, this message translates to:
  /// **'What average {category} score do you want to achieve?'**
  String goalTargetHint(String category);

  /// No description provided for @goalWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get goalWeekly;

  /// No description provided for @goalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get goalMonthly;

  /// No description provided for @goalDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get goalDaysLeft;

  /// No description provided for @goalDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get goalDaysRemaining;

  /// No description provided for @goalCurrentAverage.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get goalCurrentAverage;

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get goalTarget;

  /// No description provided for @goalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Score'**
  String get goalTargetLabel;

  /// No description provided for @goalSuggestedTarget.
  ///
  /// In en, this message translates to:
  /// **'Based on your history, we suggest {target}'**
  String goalSuggestedTarget(String target);

  /// No description provided for @goalUseSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get goalUseSuggestion;

  /// No description provided for @goalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active goals'**
  String get goalEmptyTitle;

  /// No description provided for @goalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a goal to track your progress and stay motivated'**
  String get goalEmptySubtitle;

  /// No description provided for @goalSetFirst.
  ///
  /// In en, this message translates to:
  /// **'Set Your First Goal'**
  String get goalSetFirst;

  /// No description provided for @goalStatusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get goalStatusOnTrack;

  /// No description provided for @goalStatusBehind.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get goalStatusBehind;

  /// No description provided for @goalStatusAhead.
  ///
  /// In en, this message translates to:
  /// **'Exceeding target!'**
  String get goalStatusAhead;

  /// No description provided for @goalStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get goalStatusCompleted;

  /// No description provided for @goalStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Goal not met'**
  String get goalStatusFailed;

  /// No description provided for @goalStreak.
  ///
  /// In en, this message translates to:
  /// **'Goal Streak'**
  String get goalStreak;

  /// No description provided for @goalHistory.
  ///
  /// In en, this message translates to:
  /// **'Goal History'**
  String get goalHistory;

  /// No description provided for @goalSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get goalSuccessRate;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
