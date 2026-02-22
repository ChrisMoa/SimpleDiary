// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Simple Diary';

  @override
  String get drawerHome => 'Accueil';

  @override
  String get drawerSettings => 'Paramètres';

  @override
  String get drawerCalendar => 'Calendrier';

  @override
  String get drawerDiaryWizard => 'Assistant de Journal';

  @override
  String get drawerNotesOverview => 'Aperçu des Notes';

  @override
  String get drawerTemplates => 'Modèles';

  @override
  String get drawerSync => 'Synchronisation des Données';

  @override
  String get drawerAbout => 'À propos';

  @override
  String get drawerErrorInvalidEntry => 'Erreur : Entrée invalide';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get saveSettings => 'Enregistrer les Paramètres';

  @override
  String get settingsSavedSuccessfully => 'Paramètres enregistrés avec succès';

  @override
  String errorSavingSettings(String error) {
    return 'Erreur lors de l\'enregistrement des paramètres : $error';
  }

  @override
  String get noteCategories => 'Catégories de Notes';

  @override
  String get manageCategoriesAndTags =>
      'Gérez vos catégories et étiquettes de notes';

  @override
  String get manageCategories => 'Gérer les Catégories';

  @override
  String get themeSettings => 'Paramètres de Thème';

  @override
  String get customizeAppearance =>
      'Personnalisez l\'apparence de votre application de journal.';

  @override
  String get themeColor => 'Couleur du Thème';

  @override
  String get clickColorToChange =>
      'Cliquez sur cette couleur pour la modifier dans une boîte de dialogue';

  @override
  String get themeMode => 'Mode de Thème';

  @override
  String get toggleDarkMode =>
      'Basculez ce bouton pour passer entre le thème sombre et clair';

  @override
  String get selectColor => 'Sélectionner la couleur';

  @override
  String get selectColorShade => 'Sélectionner la nuance de couleur';

  @override
  String get selectedColorAndShades => 'Couleur sélectionnée et ses nuances';

  @override
  String get languageSettings => 'Paramètres de Langue';

  @override
  String get languageDescription =>
      'Choisissez la langue pour l\'interface de l\'application.';

  @override
  String get language => 'Langue';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get email => 'E-mail';

  @override
  String get emailOptional => 'E-mail (optionnel)';

  @override
  String get login => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get remoteAccount => 'Compte distant ?';

  @override
  String get pleaseEnterUsername => 'Veuillez entrer un nom d\'utilisateur';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer un mot de passe';

  @override
  String get pleaseEnterYourPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get pleaseEnterValidEmail =>
      'Veuillez entrer une adresse e-mail valide';

  @override
  String get authenticationError => 'Erreur d\'Authentification';

  @override
  String get invalidUsernameOrPassword =>
      'Nom d\'utilisateur ou mot de passe incorrect. Veuillez réessayer.';

  @override
  String unexpectedError(String error) {
    return 'Une erreur inattendue s\'est produite : $error';
  }

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get enterPasswordToContinue =>
      'Entrez votre mot de passe pour continuer';

  @override
  String get incorrectPassword => 'Mot de passe incorrect';

  @override
  String get switchUser => 'Changer d\'Utilisateur';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get save => 'Enregistrer';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get doYouWantToLogout => 'Voulez-vous vous déconnecter ?';

  @override
  String get doYouWantToOverwriteUserdata =>
      'Voulez-vous écraser vos données utilisateur ?';

  @override
  String get logoutTitle => 'Se déconnecter';

  @override
  String get logoutMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get stayHere => 'rester ici';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get recorded => 'Enregistré';

  @override
  String get pending => 'En attente';

  @override
  String get recordToday => 'Enregistrer aujourd\'hui';

  @override
  String get dayStreak => 'Série de Jours';

  @override
  String get weeklyAverage => 'Moyenne Hebdomadaire';

  @override
  String get status => 'Statut';

  @override
  String get newEntry => 'Nouvelle Entrée';

  @override
  String errorWithMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get sevenDayOverview => 'Aperçu de 7 Jours';

  @override
  String get ratingTrend => 'Tendance d\'Évaluation';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get insightsAndAchievements => 'Perspectives et Réalisations';

  @override
  String errorLoadingInsights(String error) {
    return 'Erreur lors du chargement des perspectives : $error';
  }

  @override
  String weekNumber(int number) {
    return 'Semaine $number';
  }

  @override
  String get milestoneReached => 'Vous avez atteint une étape importante !';

  @override
  String get perfectWeek => 'Semaine Parfaite !';

  @override
  String get perfectWeekDescription =>
      'Vous avez enregistré tous les jours cette semaine !';

  @override
  String get notRecordedToday => 'Non enregistré aujourd\'hui';

  @override
  String get rememberToRate =>
      'N\'oubliez pas d\'évaluer votre journée d\'aujourd\'hui !';

  @override
  String get bestCategory => 'Meilleure Catégorie';

  @override
  String bestCategoryDescription(String category) {
    return 'Votre meilleure catégorie cette semaine : $category !';
  }

  @override
  String get moodPatterns => 'Modèles d\'Humeur';

  @override
  String get patternInsight => 'Modèle';

  @override
  String get trendInsight => 'Tendance';

  @override
  String get weeklyInsight => 'Hebdomadaire';

  @override
  String get tipInsight => 'Conseil';

  @override
  String dayDetail(String date) {
    return 'Détail du Jour : $date';
  }

  @override
  String get noDiaryEntryForDay => 'Aucune entrée de journal pour ce jour';

  @override
  String errorLoadingNotes(String error) {
    return 'Erreur lors du chargement des notes : $error';
  }

  @override
  String errorLoadingDiaryDay(String error) {
    return 'Erreur lors du chargement du jour du journal : $error';
  }

  @override
  String get addANote => 'Ajouter une note';

  @override
  String get daySummary => 'Résumé du Jour';

  @override
  String get notesAndActivities => 'Notes et Activités';

  @override
  String nEntries(int count) {
    return '$count entrées';
  }

  @override
  String get noNotesForDay => 'Aucune note pour ce jour';

  @override
  String get addThoughtsActivitiesMemories =>
      'Ajoutez vos pensées, activités ou souvenirs';

  @override
  String get editNote => 'Modifier la note';

  @override
  String get allDay => 'Toute la journée';

  @override
  String overallMood(String mood) {
    return 'Humeur Générale : $mood';
  }

  @override
  String get deleteDiaryEntry => 'Supprimer l\'Entrée de Journal';

  @override
  String get confirmDeleteDiaryEntry =>
      'Êtes-vous sûr de vouloir supprimer cette entrée de journal ? Cela supprimera à la fois l\'évaluation du jour et toutes les notes associées.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Fermer';

  @override
  String get edit => 'Modifier';

  @override
  String get create => 'Créer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get ratingSocial => 'Social';

  @override
  String get ratingProductivity => 'Productivité';

  @override
  String get ratingSport => 'Sport';

  @override
  String get ratingFood => 'Nourriture';

  @override
  String get ratingPoor => 'Faible';

  @override
  String get ratingFair => 'Moyen';

  @override
  String get ratingGood => 'Bon';

  @override
  String get ratingGreat => 'Très Bon';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get moodToughDay => 'Jour Difficile';

  @override
  String get moodCouldBeBetter => 'Pourrait Être Mieux';

  @override
  String get moodPrettyGood => 'Plutôt Bon';

  @override
  String get moodGreatDay => 'Super Journée';

  @override
  String get moodPerfectDay => 'Journée Parfaite';

  @override
  String get noDiaryEntriesYet => 'Aucune entrée de journal pour le moment';

  @override
  String get startTrackingDescription =>
      'Commencez à suivre votre journée en ajoutant des notes\net en complétant les évaluations quotidiennes';

  @override
  String get startTodaysJournal => 'Commencer le Journal d\'Aujourd\'hui';

  @override
  String get confirmDeletion => 'Confirmer la Suppression';

  @override
  String get confirmDeleteDiaryEntryShort =>
      'Êtes-vous sûr de vouloir supprimer cette entrée de journal ?';

  @override
  String get diaryEntryDeleted => 'Entrée de journal supprimée';

  @override
  String get undo => 'Annuler';

  @override
  String get loadingDayData => 'Chargement des données du jour...';

  @override
  String get calendar => 'Calendrier';

  @override
  String get noteDetails => 'Détails de la Note';

  @override
  String get dayRating => 'Évaluation du Jour';

  @override
  String get howWasYourDay =>
      'Comment s\'est passée votre journée ? Évaluez les différents aspects de votre expérience.';

  @override
  String get saveDayRating => 'Enregistrer l\'Évaluation du Jour';

  @override
  String get dayRatingSaved => 'Évaluation du jour enregistrée avec succès !';

  @override
  String get notRated => 'Non Évalué';

  @override
  String get ratingSocialDescription =>
      'Comment se sont passées vos interactions sociales et relations aujourd\'hui ?';

  @override
  String get ratingProductivityDescription =>
      'À quel point avez-vous été productif dans votre travail ou vos tâches quotidiennes ?';

  @override
  String get ratingSportDescription =>
      'Comment s\'est passée votre activité physique et exercice aujourd\'hui ?';

  @override
  String get ratingFoodDescription =>
      'À quel point votre alimentation était-elle saine et satisfaisante aujourd\'hui ?';

  @override
  String get tapToChangeDate => 'Appuyez pour changer la date';

  @override
  String get previousDay => 'Jour précédent';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get nextDay => 'Jour suivant';

  @override
  String get addTitle => 'Ajouter un Titre';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get description => 'Description';

  @override
  String get allDayQuestion => 'Toute la journée ?';

  @override
  String get from => 'DE';

  @override
  String get to => 'À';

  @override
  String get saveUpperCase => 'ENREGISTRER';

  @override
  String get saveWord => 'enregistrer';

  @override
  String get reload => 'recharger';

  @override
  String get noteUpdateError => 'Impossible de mettre à jour la note';

  @override
  String dateLabel(String date) {
    return 'Date : $date';
  }

  @override
  String get organizeCategoriesDescription =>
      'Organisez vos notes avec des catégories personnalisées';

  @override
  String get noCategoriesYet => 'Aucune catégorie pour le moment';

  @override
  String get createCategoriesToOrganize =>
      'Créez des catégories pour organiser vos notes';

  @override
  String get createCategory => 'Créer une Catégorie';

  @override
  String get editCategory => 'Modifier la Catégorie';

  @override
  String get categoryName => 'Nom de Catégorie';

  @override
  String get categoryColor => 'Couleur de Catégorie';

  @override
  String get preview => 'Aperçu';

  @override
  String get pleaseEnterCategoryName => 'Veuillez entrer un nom de catégorie';

  @override
  String get categoryAlreadyExists => 'Une catégorie avec ce nom existe déjà';

  @override
  String get categoryUpdated => 'Catégorie mise à jour';

  @override
  String get categoryCreated => 'Catégorie créée';

  @override
  String get categoryDeleted => 'Catégorie supprimée';

  @override
  String get cannotDeleteCategory => 'Impossible de Supprimer la Catégorie';

  @override
  String categoryInUse(String title) {
    return 'La catégorie \"$title\" est actuellement utilisée par une ou plusieurs notes. Veuillez réattribuer ou supprimer ces notes en premier.';
  }

  @override
  String get deleteCategory => 'Supprimer la Catégorie';

  @override
  String confirmDeleteCategory(String title) {
    return 'Êtes-vous sûr de vouloir supprimer \"$title\" ?';
  }

  @override
  String get editCategoryTooltip => 'Modifier la catégorie';

  @override
  String get deleteCategoryTooltip => 'Supprimer la catégorie';

  @override
  String get defaultCategoryWork => 'Travail';

  @override
  String get defaultCategoryLeisure => 'Loisirs';

  @override
  String get defaultCategoryFood => 'Nourriture';

  @override
  String get defaultCategoryGym => 'Gym';

  @override
  String get defaultCategorySleep => 'Sommeil';

  @override
  String get noteTemplates => 'Modèles de Notes';

  @override
  String get selectTemplate => 'Sélectionner un Modèle';

  @override
  String get noTemplatesAvailable => 'Aucun modèle disponible';

  @override
  String get noTemplatesYet => 'Aucun modèle pour le moment';

  @override
  String get createTemplatesToQuicklyAdd =>
      'Créez des modèles pour ajouter rapidement des notes';

  @override
  String get createTemplate => 'Créer un Modèle';

  @override
  String get editTemplate => 'Modifier le Modèle';

  @override
  String get templateName => 'Nom du Modèle';

  @override
  String get durationMinutes => 'Durée (minutes)';

  @override
  String get category => 'Catégorie';

  @override
  String get pleaseEnterTemplateName => 'Veuillez entrer un nom de modèle';

  @override
  String get pleaseEnterDuration => 'Veuillez entrer la durée';

  @override
  String get pleaseEnterValidDuration => 'Veuillez entrer une durée valide';

  @override
  String get simple => 'Simple';

  @override
  String get sections => 'Sections';

  @override
  String get addSection => 'Ajouter une Section';

  @override
  String get sectionTitle => 'Titre de Section';

  @override
  String get hintOptional => 'Conseil (optionnel)';

  @override
  String get removeSection => 'Supprimer la section';

  @override
  String get templateUpdatedSuccessfully => 'Modèle mis à jour avec succès';

  @override
  String get templateCreatedSuccessfully => 'Modèle créé avec succès';

  @override
  String get deleteTemplate => 'Supprimer le Modèle';

  @override
  String confirmDeleteTemplate(String title) {
    return 'Êtes-vous sûr de vouloir supprimer \"$title\" ?';
  }

  @override
  String get templateDeleted => 'Modèle supprimé';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get descriptionSections => 'Sections de Description :';

  @override
  String get descriptionLabel => 'Description :';

  @override
  String addedTemplateAtTime(String title, String time) {
    return 'Ajouté \"$title\" à $time';
  }

  @override
  String errorCreatingNote(String error) {
    return 'Erreur lors de la création de la note : $error';
  }

  @override
  String get fileSynchronization => 'Synchronisation de Fichiers';

  @override
  String get fileSyncDescription =>
      'Importez et exportez vos données de journal vers des fichiers JSON ou ICS de calendrier avec chiffrement optionnel.';

  @override
  String get exportToJson => 'Exporter vers JSON';

  @override
  String get saveYourDiaryData =>
      'Enregistrez vos données de journal dans un fichier';

  @override
  String get importFromJson => 'Importer depuis JSON';

  @override
  String get loadDiaryData =>
      'Charger les données de journal depuis un fichier';

  @override
  String get exportToIcsCalendar => 'Exporter vers Calendrier ICS';

  @override
  String get saveNotesAsCalendarEvents =>
      'Enregistrer les notes comme événements de calendrier (.ics)';

  @override
  String get importFromIcsCalendar => 'Importer depuis Calendrier ICS';

  @override
  String get loadCalendarEvents =>
      'Charger les événements de calendrier depuis un fichier .ics';

  @override
  String get exportRange => 'Plage d\'Exportation';

  @override
  String get whichEntriesToExport => 'Quelles entrées voulez-vous exporter ?';

  @override
  String get customRange => 'Plage Personnalisée';

  @override
  String get all => 'Toutes';

  @override
  String get encryptJsonExport => 'Chiffrer l\'Exportation JSON (Optionnel)';

  @override
  String get decryptJsonImport => 'Déchiffrer l\'Importation JSON';

  @override
  String get encryptIcsExport => 'Chiffrer l\'Exportation ICS (Optionnel)';

  @override
  String get decryptIcsImport => 'Déchiffrer l\'Importation ICS';

  @override
  String get passwordOptional => 'Mot de passe (Optionnel)';

  @override
  String get leaveEmptyForNoEncryption => 'Laisser vide pour aucun chiffrement';

  @override
  String get saveJsonExportFile => 'Enregistrer le Fichier d\'Exportation JSON';

  @override
  String get selectJsonFileToImport =>
      'Sélectionner le Fichier JSON à Importer';

  @override
  String get saveIcsCalendarFile => 'Enregistrer le Fichier de Calendrier ICS';

  @override
  String get selectIcsFileToImport => 'Sélectionner le Fichier ICS à Importer';

  @override
  String get operationCompletedSuccessfully => 'Opération terminée avec succès';

  @override
  String importedDaysWithNotes(int days, int notes) {
    return 'Importé $days jours avec $notes notes';
  }

  @override
  String importedNotesFromIcs(int count) {
    return 'Importé $count notes depuis le calendrier ICS';
  }

  @override
  String errorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get oldEncryptionFormatError =>
      'Ce fichier utilise l\'ancien format de chiffrement et ne peut pas être importé.\nVeuillez exporter vos données à nouveau avec la nouvelle version.';

  @override
  String get passwordRequiredForEncryptedFile =>
      'Mot de passe requis pour le fichier chiffré';

  @override
  String get passwordRequiredForEncryptedIcsFile =>
      'Mot de passe requis pour le fichier ICS chiffré';

  @override
  String get cannotReadIcsFile =>
      'Impossible de lire le fichier ICS. Le fichier peut être corrompu.';

  @override
  String get pleaseEnterAllFields => 'Veuillez remplir tous les champs';

  @override
  String get fillInYourCompleteDay => 'Remplissez votre journée complète';

  @override
  String get testingConnection => 'Test de connexion...';

  @override
  String get connectionSuccessful => 'Connexion réussie !';

  @override
  String get connectionFailedAuth =>
      'Connexion échouée : Erreur d\'authentification';

  @override
  String connectionFailed(String error) {
    return 'Connexion échouée : $error';
  }

  @override
  String get synchronization => 'Synchronisation';

  @override
  String get supabaseSynchronization => 'Synchronisation Supabase';

  @override
  String get supabaseSyncDescription =>
      'Synchronisez vos données de journal avec le stockage cloud Supabase pour la sauvegarde et l\'accès multi-appareils.';

  @override
  String get uploadToSupabase => 'Envoyer vers Supabase';

  @override
  String get saveYourDiaryDataToCloud =>
      'Sauvegardez vos données de journal dans le cloud';

  @override
  String get downloadFromSupabase => 'Télécharger depuis Supabase';

  @override
  String get loadDiaryDataFromCloud =>
      'Charger les données du journal depuis le cloud';

  @override
  String get supabaseSettings => 'Paramètres Supabase';

  @override
  String get supabaseDescription =>
      'Configurez vos paramètres de stockage cloud Supabase pour la sauvegarde et l\'accès multi-appareils.';

  @override
  String get supabaseUrl => 'URL Supabase';

  @override
  String get anonKey => 'Clé Anonyme';

  @override
  String get testConnection => 'Tester la Connexion';

  @override
  String get pdfExport => 'Export PDF';

  @override
  String get pdfExportDescription =>
      'Générez des rapports PDF imprimables avec vos entrées de journal, évaluations et statistiques.';

  @override
  String get quickExport => 'Export Rapide';

  @override
  String get lastWeek => '7 Derniers Jours';

  @override
  String get lastMonth => '30 Derniers Jours';

  @override
  String get currentMonth => 'Ce Mois';

  @override
  String get selectDateRangeForReport =>
      'Sélectionnez une plage de dates personnalisée pour votre rapport';

  @override
  String get selectMonth => 'Sélectionner un Mois';

  @override
  String get selectSpecificMonth => 'Choisissez un mois spécifique à exporter';

  @override
  String get exportAllData => 'Exporter Toutes les Données';

  @override
  String get generatePdfWithAllData =>
      'Générer un rapport PDF avec toutes vos données';

  @override
  String get selectDateRange =>
      'Sélectionner la plage de dates pour le rapport';

  @override
  String get export => 'Exporter';

  @override
  String get pdfExportSuccess => 'Rapport PDF généré avec succès';

  @override
  String pdfExportError(String error) {
    return 'Échec de la génération du PDF : $error';
  }

  @override
  String get about => 'À propos';

  @override
  String get dayTracker => 'Day Tracker';

  @override
  String version(String version) {
    return 'Version : $version';
  }

  @override
  String get developer => 'Développeur';

  @override
  String get contact => 'Contact';

  @override
  String get features => 'Fonctionnalités';

  @override
  String get licenses => 'Licences';

  @override
  String get viewLicenses => 'Voir les Licences';

  @override
  String get appDescription =>
      'Day Tracker est une application personnelle de journal et de productivité qui vous aide à suivre vos activités quotidiennes et à évaluer différents aspects de votre journée.';

  @override
  String get featureTrackActivities =>
      'Suivez les activités et rendez-vous quotidiens';

  @override
  String get featureRateDay => 'Évaluez différents aspects de votre journée';

  @override
  String get featureCalendar =>
      'Consultez votre emploi du temps dans un calendrier';

  @override
  String get featureEncryption => 'Données sécurisées avec chiffrement';

  @override
  String get featureSync =>
      'Synchronisez les données entre appareils avec Supabase';

  @override
  String get featureExportImport => 'Exportez et importez des données';

  @override
  String copyright(int year) {
    return '© $year Your Company';
  }

  @override
  String score(int score) {
    return 'Score : $score';
  }

  @override
  String get createNote => 'Créer une Note';

  @override
  String get fromTemplate => 'Depuis un Modèle';

  @override
  String get noNoteSelected => 'Aucune note sélectionnée';

  @override
  String get clickExistingOrCreateNew =>
      'Cliquez sur une note existante ou créez-en une nouvelle';

  @override
  String get title => 'Titre';

  @override
  String get stopDictation => 'Arrêter la dictée';

  @override
  String get dictateDescription => 'Dicter la description';

  @override
  String get addDetailsAboutNote => 'Ajoutez des détails sur cette note...';

  @override
  String get listening => 'Écoute en cours...';

  @override
  String get template => 'Modèle';

  @override
  String get add => 'Ajouter';

  @override
  String get deleteNote => 'Supprimer la Note';

  @override
  String get confirmDeleteNote =>
      'Êtes-vous sûr de vouloir supprimer cette note ?';

  @override
  String get endTimeAfterStartTime =>
      'L\'heure de fin doit être postérieure à l\'heure de début';

  @override
  String addedNoteAtTime(String time) {
    return 'Nouvelle note ajoutée à $time';
  }

  @override
  String get dailySchedule => 'Emploi du Jour';

  @override
  String get scheduleComplete => 'Emploi du temps complet';

  @override
  String get newNote => 'Nouvelle Note';

  @override
  String fromTime(String time) {
    return 'De : $time';
  }

  @override
  String toTime(String time) {
    return 'À : $time';
  }

  @override
  String get searchNotes => 'Rechercher des notes...';

  @override
  String get searchNotesPlaceholder => 'Rechercher par titre ou description';

  @override
  String get filterByCategory => 'Filtrer par catégorie';

  @override
  String get filterByDate => 'Filtrer par date';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get dateFrom => 'Depuis la date';

  @override
  String get dateTo => 'Jusqu\'à la date';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get noNotesMatchSearch =>
      'Aucune note ne correspond à votre recherche';

  @override
  String get tryDifferentSearch =>
      'Essayez d\'ajuster vos critères de recherche';

  @override
  String nResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoris';

  @override
  String get favoriteDays => 'Jours Favoris';

  @override
  String get favoriteNotes => 'Notes Favorites';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get noFavorites => 'Pas encore de favoris';

  @override
  String get noFavoriteDays => 'Pas de jours favoris';

  @override
  String get noFavoriteNotes => 'Pas de notes favorites';

  @override
  String get markAsFavorite => 'Marquer comme favori';

  @override
  String get unmarkAsFavorite => 'Retirer le favori';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get notificationSettings => 'Paramètres de notification';

  @override
  String get notificationSettingsDescription =>
      'Configurez les rappels et les notifications pour vos entrées de journal.';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get enableNotificationsDescription =>
      'Activez les rappels quotidiens pour écrire dans votre journal';

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String get reminderTimeDescription =>
      'Choisissez quand vous voulez être rappelé';

  @override
  String get smartReminders => 'Rappels intelligents';

  @override
  String get smartRemindersDescription =>
      'Ne rappeler que si vous n\'avez pas écrit l\'entrée d\'aujourd\'hui';

  @override
  String get streakWarnings => 'Avertissements de série';

  @override
  String get streakWarningsDescription =>
      'Soyez averti lorsque votre série d\'écriture est en danger';

  @override
  String get notificationPermissionDenied =>
      'L\'autorisation de notification a été refusée. Veuillez l\'activer dans les paramètres.';

  @override
  String get selectReminderTime => 'Sélectionner l\'heure du rappel';

  @override
  String get goalsSectionTitle => 'Objectifs';

  @override
  String get goalCreateNew => 'Créer un Objectif';

  @override
  String get goalCreate => 'Créer';

  @override
  String get goalSelectCategory => 'Quel domaine souhaitez-vous améliorer ?';

  @override
  String get goalSelectTimeframe => 'Choisissez votre période';

  @override
  String get goalSetTarget => 'Définissez votre objectif';

  @override
  String goalTargetHint(String category) {
    return 'Quelle moyenne de $category souhaitez-vous atteindre ?';
  }

  @override
  String get goalWeekly => 'Hebdomadaire';

  @override
  String get goalMonthly => 'Mensuel';

  @override
  String get goalDaysLeft => 'jours restants';

  @override
  String get goalDaysRemaining => 'Jours Restants';

  @override
  String get goalCurrentAverage => 'Actuel';

  @override
  String get goalTarget => 'Objectif';

  @override
  String get goalTargetLabel => 'Score Cible';

  @override
  String goalSuggestedTarget(String target) {
    return 'Basé sur votre historique, nous suggérons $target';
  }

  @override
  String get goalUseSuggestion => 'Utiliser';

  @override
  String get goalEmptyTitle => 'Aucun objectif actif';

  @override
  String get goalEmptySubtitle =>
      'Définissez un objectif pour suivre vos progrès et rester motivé';

  @override
  String get goalSetFirst => 'Définir votre Premier Objectif';

  @override
  String get goalStatusOnTrack => 'Sur la bonne voie';

  @override
  String get goalStatusBehind => 'Nécessite attention';

  @override
  String get goalStatusAhead => 'Dépasse l\'objectif !';

  @override
  String get goalStatusCompleted => 'Objectif atteint !';

  @override
  String get goalStatusFailed => 'Objectif non atteint';

  @override
  String get goalStreak => 'Série d\'Objectifs';

  @override
  String get goalHistory => 'Historique des Objectifs';

  @override
  String get goalSuccessRate => 'Taux de Réussite';

  @override
  String get days => 'jours';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get photos => 'Photos';

  @override
  String get noPhotos => 'Aucune photo jointe';

  @override
  String get deletePhoto => 'Supprimer la photo';

  @override
  String get deletePhotoConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette photo ?';

  @override
  String get imageNotFound => 'Image introuvable';

  @override
  String get drawerHabits => 'Habitudes';

  @override
  String get habitsTitle => 'Habitudes';

  @override
  String get habitsToday => 'Aujourd\'hui';

  @override
  String get habitsGrid => 'Grille';

  @override
  String get habitsStats => 'Statistiques';

  @override
  String get habitName => 'Nom de l\'habitude';

  @override
  String get habitNameRequired => 'Veuillez entrer un nom';

  @override
  String get habitDescription => 'Description';

  @override
  String get habitIconAndColor => 'Appuyez pour changer l\'icône ou la couleur';

  @override
  String get habitFrequency => 'Fréquence';

  @override
  String get habitFrequencyDaily => 'Quotidien';

  @override
  String get habitFrequencyWeekdays => 'Jours ouvrés';

  @override
  String get habitFrequencyWeekends => 'Week-end';

  @override
  String get habitFrequencySpecificDays => 'Jours spécifiques';

  @override
  String get habitFrequencyTimesPerWeek => 'Fois/Semaine';

  @override
  String get habitTargetCount => 'Nombre cible';

  @override
  String get habitTimesPerWeekLabel => 'Fois par semaine';

  @override
  String get habitCreateNew => 'Nouvelle Habitude';

  @override
  String get habitEdit => 'Modifier l\'Habitude';

  @override
  String get habitArchive => 'Archiver l\'Habitude';

  @override
  String get habitUnarchive => 'Désarchiver l\'Habitude';

  @override
  String get habitNoHabits => 'Pas encore d\'habitudes';

  @override
  String get habitNoHabitsDescription =>
      'Créez des habitudes pour suivre vos routines quotidiennes';

  @override
  String get habitCreateFirst => 'Créer votre Première Habitude';

  @override
  String get habitCompleted => 'Terminé';

  @override
  String get habitProgress => 'Progrès';

  @override
  String get habitDueToday => 'À faire Aujourd\'hui';

  @override
  String get habitCurrentStreak => 'Série Actuelle';

  @override
  String get habitBestStreak => 'Meilleure Série';

  @override
  String get habitCompletionRate => 'Taux de Complétion';

  @override
  String get habitLast7Days => '7 derniers jours';

  @override
  String get habitLast30Days => '30 derniers jours';

  @override
  String get habitAllTime => 'Total';

  @override
  String get habitTotalCompletions => 'Total Complétés';

  @override
  String get habitSelectIcon => 'Sélectionner une Icône';

  @override
  String get habitSelectColor => 'Sélectionner une Couleur';

  @override
  String get habitSelectAtLeastOneDay =>
      'Veuillez sélectionner au moins un jour';

  @override
  String get habitDayMon => 'Lun';

  @override
  String get habitDayTue => 'Mar';

  @override
  String get habitDayWed => 'Mer';

  @override
  String get habitDayThu => 'Jeu';

  @override
  String get habitDayFri => 'Ven';

  @override
  String get habitDaySat => 'Sam';

  @override
  String get habitDaySun => 'Dim';

  @override
  String get habitDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette habitude et toutes ses entrées ?';

  @override
  String get habitDeleteTitle => 'Supprimer l\'Habitude';

  @override
  String get habitTodayProgress => 'Progrès d\'Aujourd\'hui';

  @override
  String get habitAllHabitsCompleted => 'Toutes les habitudes terminées !';

  @override
  String get habitContributionGrid => 'Grille de Contributions';

  @override
  String get habitLess => 'Moins';

  @override
  String get habitMore => 'Plus';

  @override
  String get biometricSettings => 'Connexion biométrique';

  @override
  String get biometricSettingsDescription =>
      'Utiliser l\'empreinte digitale ou la reconnaissance faciale pour déverrouiller l\'application';

  @override
  String get enableBiometric => 'Activer la connexion biométrique';

  @override
  String get enableBiometricDescription =>
      'Déverrouiller l\'application avec votre empreinte digitale ou votre visage';

  @override
  String get biometricLockOnResume => 'Verrouiller lors du changement d\'app';

  @override
  String get biometricLockOnResumeDescription =>
      'Exiger la biométrie lors du retour à l\'application';

  @override
  String get biometricLockTimeout => 'Délai de verrouillage';

  @override
  String get biometricLockTimeoutDescription =>
      'Temps avant de nécessiter une ré-authentification';

  @override
  String get biometricImmediately => 'Immédiatement';

  @override
  String biometricMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get biometricTestButton => 'Tester la biométrie';

  @override
  String get biometricTestSuccess => 'Authentification biométrique réussie';

  @override
  String get biometricTestFailed => 'Authentification biométrique échouée';

  @override
  String get biometricNotAvailable =>
      'Authentification biométrique non disponible sur cet appareil';

  @override
  String get biometricNotEnrolled =>
      'Aucune biométrie enregistrée sur cet appareil';

  @override
  String get biometricUnlockPrompt => 'Déverrouiller SimpleDiary';

  @override
  String get biometricTapToUnlock =>
      'Appuyez pour déverrouiller avec la biométrie';

  @override
  String get usePasswordInstead => 'Utiliser le mot de passe à la place';

  @override
  String get biometricRetry => 'Réessayer';

  @override
  String get biometricEnrollSuccess =>
      'Connexion biométrique activée avec succès';

  @override
  String get biometricEnrollFailed =>
      'Impossible d\'activer la connexion biométrique';

  @override
  String get backupSettings => 'Sauvegardes automatiques';

  @override
  String get backupSettingsDescription =>
      'Configurez les sauvegardes automatiques pour protéger vos données de journal.';

  @override
  String get enableAutoBackup => 'Activer les sauvegardes automatiques';

  @override
  String get enableAutoBackupDescription =>
      'Sauvegardez automatiquement vos données selon un calendrier régulier';

  @override
  String get backupFrequency => 'Fréquence de sauvegarde';

  @override
  String get backupFrequencyDescription =>
      'À quelle fréquence les sauvegardes automatiques doivent-elles s\'exécuter';

  @override
  String get backupFrequencyDaily => 'Quotidien';

  @override
  String get backupFrequencyWeekly => 'Hebdomadaire';

  @override
  String get backupFrequencyMonthly => 'Mensuel';

  @override
  String get backupPreferredTime => 'Heure préférée';

  @override
  String get backupPreferredTimeDescription =>
      'Quand exécuter la sauvegarde automatique';

  @override
  String get backupWifiOnly => 'WiFi uniquement';

  @override
  String get backupWifiOnlyDescription =>
      'Exécuter les sauvegardes uniquement en WiFi (Android)';

  @override
  String get backupMaxCount => 'Conserver les sauvegardes';

  @override
  String get backupMaxCountDescription =>
      'Nombre maximum de sauvegardes à conserver';

  @override
  String backupMaxCountValue(int count) {
    return '$count sauvegardes';
  }

  @override
  String get backupNow => 'Sauvegarder maintenant';

  @override
  String get backupNowDescription =>
      'Créer une sauvegarde manuelle immédiatement';

  @override
  String get backupHistory => 'Historique des sauvegardes';

  @override
  String get backupHistoryDescription => 'Voir et gérer vos sauvegardes';

  @override
  String lastBackup(String time) {
    return 'Dernière sauvegarde : $time';
  }

  @override
  String get lastBackupNever => 'Dernière sauvegarde : Jamais';

  @override
  String get backupCreating => 'Création de la sauvegarde...';

  @override
  String get backupSuccess => 'Sauvegarde créée avec succès';

  @override
  String backupFailed(String error) {
    return 'Sauvegarde échouée : $error';
  }

  @override
  String get backupRestoring => 'Restauration de la sauvegarde...';

  @override
  String get backupRestoreSuccess =>
      'Sauvegarde restaurée avec succès. Veuillez redémarrer l\'application.';

  @override
  String backupRestoreFailed(String error) {
    return 'Restauration échouée : $error';
  }

  @override
  String get backupRestoreConfirm => 'Restaurer la sauvegarde';

  @override
  String backupRestoreConfirmMessage(String date) {
    return 'Ceci remplacera toutes les données actuelles par la sauvegarde du $date. Une sauvegarde de sécurité sera créée d\'abord. Continuer ?';
  }

  @override
  String get backupDeleteConfirm => 'Supprimer la sauvegarde';

  @override
  String get backupDeleteConfirmMessage =>
      'Êtes-vous sûr de vouloir supprimer cette sauvegarde ?';

  @override
  String get backupDeleted => 'Sauvegarde supprimée';

  @override
  String backupStorageUsed(String size) {
    return 'Stockage utilisé : $size';
  }

  @override
  String backupEntries(int days, int notes, int habits) {
    return '$days jours, $notes notes, $habits habitudes';
  }

  @override
  String get backupTypeManual => 'Manuel';

  @override
  String get backupTypeScheduled => 'Programmé';

  @override
  String get backupTypePreRestore => 'Pré-restauration';

  @override
  String get backupNoBackups => 'Pas encore de sauvegardes';

  @override
  String get backupNoBackupsDescription =>
      'Activez les sauvegardes automatiques ou créez une sauvegarde manuelle pour protéger vos données';

  @override
  String get backupOverdue => 'Sauvegarde en retard';

  @override
  String get backupDestination => 'Destination de sauvegarde';

  @override
  String get backupDestinationDescription =>
      'Choisissez où vos sauvegardes doivent être stockées';

  @override
  String get backupDestinationRequiresSupabase =>
      'Configurez d\'abord les paramètres Supabase pour activer le stockage cloud';

  @override
  String get backupDestinationLocal => 'Local';

  @override
  String get backupDestinationCloud => 'Cloud';

  @override
  String get backupDestinationBoth => 'Les deux';

  @override
  String get backupUploadToCloud => 'Téléverser';

  @override
  String get backupUploadSuccess => 'Sauvegarde téléversée dans le cloud';

  @override
  String backupUploadFailed(String error) {
    return 'Échec du téléversement cloud : $error';
  }

  @override
  String get backupCloudBackups => 'Sauvegardes cloud';

  @override
  String get backupDownloadFromCloud => 'Télécharger';

  @override
  String get backupDownloadSuccess => 'Sauvegarde téléchargée depuis le cloud';

  @override
  String backupDownloadFailed(String error) {
    return 'Échec du téléchargement cloud : $error';
  }

  @override
  String get backupCloudDeleteConfirm => 'Supprimer du cloud';

  @override
  String get backupCloudDeleteConfirmMessage =>
      'Êtes-vous sûr de vouloir supprimer cette sauvegarde du stockage cloud ?';

  @override
  String get backupCloudDeleted => 'Sauvegarde supprimée du cloud';

  @override
  String get backupCloudNoBackups => 'Aucune sauvegarde cloud trouvée';

  @override
  String get backupLocation => 'Emplacement des sauvegardes';

  @override
  String get backupLocationDescription =>
      'Choisissez où les sauvegardes locales sont stockées sur cet appareil';

  @override
  String backupLocationDefault(String path) {
    return 'Par défaut ($path)';
  }

  @override
  String backupLocationCustom(String path) {
    return 'Personnalisé : $path';
  }

  @override
  String get backupLocationChange => 'Modifier';

  @override
  String get backupLocationReset => 'Réinitialiser par défaut';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans SimpleDiary';

  @override
  String get onboardingWelcomeDescription =>
      'Votre compagnon personnel de réflexion quotidienne.\nSuivez vos journées, découvrez des tendances et progressez chaque semaine.';

  @override
  String get onboardingRatingsTitle => 'Évaluez votre journée';

  @override
  String get onboardingRatingsDescription =>
      'Notez quatre domaines clés chaque jour :\nSocial · Productivité · Sport · Alimentation.\nVoyez d\'un coup d\'œil l\'équilibre de votre vie.';

  @override
  String get onboardingNotesTitle => 'Ajouter des activités';

  @override
  String get onboardingNotesDescription =>
      'Consignez des notes et événements dans des catégories comme Travail, Gym, Loisirs et plus.\nTout apparaît dans votre calendrier personnel.';

  @override
  String get onboardingInsightsTitle => 'Découvrir des tendances';

  @override
  String get onboardingInsightsDescription =>
      'Le tableau de bord affiche les séries, les statistiques hebdomadaires et les insights.\nDécouvrez quelles activités améliorent le plus votre humeur.';

  @override
  String get onboardingGetStartedTitle => 'Prêt à commencer ?';

  @override
  String get onboardingGetStartedDescription =>
      'Explorez d\'abord avec des données d\'exemple, ou créez directement votre compte.';

  @override
  String get onboardingExploreDemo => 'Explorer avec les données démo';

  @override
  String get onboardingCreateAccount => 'Créer un compte';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get setupWizardTitle => 'Configuration rapide';

  @override
  String get setupWizardThemeTitle => 'Choisissez votre thème';

  @override
  String get setupWizardThemeHint =>
      'Vous pouvez modifier cela à tout moment dans les Paramètres.';

  @override
  String get setupWizardThemeLight => 'Clair';

  @override
  String get setupWizardThemeDark => 'Sombre';

  @override
  String get setupWizardLanguageTitle => 'Choisissez votre langue';

  @override
  String get setupWizardLanguageHint =>
      'Vous pouvez modifier cela à tout moment dans les Paramètres.';

  @override
  String get setupWizardNext => 'Suivant';

  @override
  String get setupWizardDone => 'Terminé';

  @override
  String get demoModeBannerText => 'Exploration avec des données démo';

  @override
  String get demoModeCreateAccount => 'Créer un compte';

  @override
  String get quickMoodCheck => 'Vérification rapide de l\'humeur';

  @override
  String get tapWhereYouAre =>
      'Appuyez sur la carte d\'humeur pour indiquer votre état';

  @override
  String get highEnergy => 'Énergie élevée';

  @override
  String get lowEnergy => 'Énergie faible';

  @override
  String get pleasant => 'Agréable';

  @override
  String get unpleasant => 'Désagréable';

  @override
  String get wellbeingDimensions => 'Dimensions du bien-être';

  @override
  String get permaPlusDescription =>
      'Modèle PERMA+ – évaluez chaque domaine de votre journée';

  @override
  String get overallMoodDimension => 'Humeur';

  @override
  String get howDidYouFeel =>
      'Comment vous êtes-vous senti émotionnellement aujourd\'hui ?';

  @override
  String get energyDimension => 'Énergie';

  @override
  String get physicalVitality => 'Votre vitalité physique et votre vigilance';

  @override
  String get connectionDimension => 'Connexion';

  @override
  String get socialConnections => 'Qualité des interactions sociales';

  @override
  String get purposeDimension => 'Sens';

  @override
  String get meaningAndPurpose => 'Sentiment de sens et de direction';

  @override
  String get achievementDimension => 'Accomplissement';

  @override
  String get accomplishments => 'Progrès sur les objectifs et les tâches';

  @override
  String get engagementDimension => 'Engagement';

  @override
  String get flowAndAbsorption => 'Absorbé dans des activités agréables';

  @override
  String get selectEmotions => 'Sélectionner des émotions';

  @override
  String get howAreYouFeeling =>
      'Comment vous sentez-vous ? (sélectionnez tout ce qui s\'applique)';

  @override
  String get positiveEmotions => 'Positif';

  @override
  String get negativeEmotions => 'Négatif';

  @override
  String get neutralEmotions => 'Neutre / Mixte';

  @override
  String get intensityMild => 'Légère';

  @override
  String get intensityModerate => 'Modérée';

  @override
  String get intensityStrong => 'Forte';

  @override
  String get contextFactors => 'Facteurs contextuels';

  @override
  String get contextFactorsDescription =>
      'Contexte optionnel pouvant influencer votre humeur';

  @override
  String get sleepHours => 'Heures de sommeil';

  @override
  String get sleepQuality => 'Qualité du sommeil';

  @override
  String get exercisedToday => 'Fait du sport aujourd\'hui';

  @override
  String get stressLevel => 'Niveau de stress';

  @override
  String get addTagHint => 'Ajouter un tag (ex. voyage, malade, rendez-vous)';

  @override
  String get ratingModeLabel => 'Mode d\'évaluation';

  @override
  String get quickMode => 'Rapide (10 sec)';

  @override
  String get balancedMode => 'Équilibré (30 sec)';

  @override
  String get detailedMode => 'Détaillé (60 sec)';

  @override
  String get customMode => 'Personnalisé';

  @override
  String get switchToEnhancedMode => 'Passer au mode amélioré';

  @override
  String get switchToSimpleMode => 'Passer au mode simple';

  @override
  String get rateWellbeingDimensions =>
      'Évaluez votre bien-être selon les dimensions clés';

  @override
  String get showQuickMood => 'Afficher la carte d\'humeur rapide';

  @override
  String get showEmotionWheel => 'Afficher la roue des émotions';

  @override
  String get showContextFactors => 'Afficher les facteurs contextuels';

  @override
  String get useLegacyRating => 'Utiliser l\'évaluation simple (4 catégories)';
}
