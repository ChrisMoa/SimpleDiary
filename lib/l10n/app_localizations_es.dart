// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Simple Diary';

  @override
  String get drawerHome => 'Inicio';

  @override
  String get drawerSettings => 'Configuración';

  @override
  String get drawerCalendar => 'Calendario';

  @override
  String get drawerDiaryWizard => 'Asistente de Diario';

  @override
  String get drawerNotesOverview => 'Resumen de Notas';

  @override
  String get drawerTemplates => 'Plantillas';

  @override
  String get drawerSync => 'Sincronización de Datos';

  @override
  String get drawerAbout => 'Acerca de';

  @override
  String get drawerErrorInvalidEntry => 'Error: Entrada inválida';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get saveSettings => 'Guardar Configuración';

  @override
  String get settingsSavedSuccessfully =>
      'Configuración guardada correctamente';

  @override
  String errorSavingSettings(String error) {
    return 'Error al guardar la configuración: $error';
  }

  @override
  String get noteCategories => 'Categorías de Notas';

  @override
  String get manageCategoriesAndTags =>
      'Administra tus categorías y etiquetas de notas';

  @override
  String get manageCategories => 'Administrar Categorías';

  @override
  String get themeSettings => 'Configuración de Tema';

  @override
  String get customizeAppearance =>
      'Personaliza la apariencia de tu aplicación de diario.';

  @override
  String get themeColor => 'Color del Tema';

  @override
  String get clickColorToChange =>
      'Haz clic en este color para cambiarlo en un diálogo';

  @override
  String get themeMode => 'Modo de Tema';

  @override
  String get toggleDarkMode =>
      'Alterna este botón para cambiar entre tema oscuro y claro';

  @override
  String get selectColor => 'Seleccionar color';

  @override
  String get selectColorShade => 'Seleccionar tono de color';

  @override
  String get selectedColorAndShades => 'Color seleccionado y sus tonos';

  @override
  String get languageSettings => 'Configuración de Idioma';

  @override
  String get languageDescription =>
      'Elige el idioma para la interfaz de la aplicación.';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailOptional => 'Correo electrónico (opcional)';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get remoteAccount => '¿Cuenta remota?';

  @override
  String get pleaseEnterUsername => 'Por favor ingresa un nombre de usuario';

  @override
  String get pleaseEnterPassword => 'Por favor ingresa una contraseña';

  @override
  String get pleaseEnterYourPassword => 'Por favor ingresa tu contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get pleaseEnterValidEmail =>
      'Por favor ingresa una dirección de correo electrónico válida';

  @override
  String get authenticationError => 'Error de Autenticación';

  @override
  String get invalidUsernameOrPassword =>
      'Nombre de usuario o contraseña incorrectos. Por favor intenta de nuevo.';

  @override
  String unexpectedError(String error) {
    return 'Ocurrió un error inesperado: $error';
  }

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get enterPasswordToContinue => 'Ingresa tu contraseña para continuar';

  @override
  String get incorrectPassword => 'Contraseña incorrecta';

  @override
  String get switchUser => 'Cambiar Usuario';

  @override
  String get accountSettings => 'Configuración de cuenta';

  @override
  String get save => 'Guardar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get doYouWantToLogout => '¿Quieres cerrar sesión?';

  @override
  String get doYouWantToOverwriteUserdata =>
      '¿Quieres sobrescribir tus datos de usuario?';

  @override
  String get logoutTitle => 'Cerrar sesión';

  @override
  String get logoutMessage => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get stayHere => 'quedarse aquí';

  @override
  String get today => 'Hoy';

  @override
  String get recorded => 'Registrado';

  @override
  String get pending => 'Pendiente';

  @override
  String get recordToday => 'Registrar hoy';

  @override
  String get dayStreak => 'Racha de Días';

  @override
  String get weeklyAverage => 'Promedio Semanal';

  @override
  String get status => 'Estado';

  @override
  String get newEntry => 'Nueva Entrada';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get sevenDayOverview => 'Resumen de 7 Días';

  @override
  String get ratingTrend => 'Tendencia de Valoración';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get insightsAndAchievements => 'Perspectivas y Logros';

  @override
  String errorLoadingInsights(String error) {
    return 'Error al cargar perspectivas: $error';
  }

  @override
  String weekNumber(int number) {
    return 'Semana $number';
  }

  @override
  String get milestoneReached => '¡Has alcanzado un hito importante!';

  @override
  String get perfectWeek => '¡Semana Perfecta!';

  @override
  String get perfectWeekDescription =>
      '¡Registraste todos los días esta semana!';

  @override
  String get notRecordedToday => 'No registrado hoy';

  @override
  String get rememberToRate => '¡No olvides calificar tu día de hoy!';

  @override
  String get bestCategory => 'Mejor Categoría';

  @override
  String bestCategoryDescription(String category) {
    return 'Tu mejor categoría esta semana: ¡$category!';
  }

  @override
  String get moodPatterns => 'Patrones de Humor';

  @override
  String get patternInsight => 'Patrón';

  @override
  String get trendInsight => 'Tendencia';

  @override
  String get weeklyInsight => 'Semanal';

  @override
  String get tipInsight => 'Consejo';

  @override
  String dayDetail(String date) {
    return 'Detalle del Día: $date';
  }

  @override
  String get noDiaryEntryForDay => 'No hay entrada de diario para este día';

  @override
  String errorLoadingNotes(String error) {
    return 'Error al cargar notas: $error';
  }

  @override
  String errorLoadingDiaryDay(String error) {
    return 'Error al cargar día del diario: $error';
  }

  @override
  String get addANote => 'Agregar una nota';

  @override
  String get daySummary => 'Resumen del Día';

  @override
  String get notesAndActivities => 'Notas y Actividades';

  @override
  String nEntries(int count) {
    return '$count entradas';
  }

  @override
  String get noNotesForDay => 'No hay notas para este día';

  @override
  String get addThoughtsActivitiesMemories =>
      'Agrega tus pensamientos, actividades o recuerdos';

  @override
  String get editNote => 'Editar nota';

  @override
  String get allDay => 'Todo el día';

  @override
  String overallMood(String mood) {
    return 'Estado de Ánimo General: $mood';
  }

  @override
  String get deleteDiaryEntry => 'Eliminar Entrada de Diario';

  @override
  String get confirmDeleteDiaryEntry =>
      '¿Estás seguro de que quieres eliminar esta entrada de diario? Esto eliminará tanto la calificación del día como todas las notas asociadas.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Cerrar';

  @override
  String get edit => 'Editar';

  @override
  String get create => 'Crear';

  @override
  String get update => 'Actualizar';

  @override
  String get ratingPoor => 'Pobre';

  @override
  String get ratingFair => 'Regular';

  @override
  String get ratingGood => 'Bueno';

  @override
  String get ratingGreat => 'Muy Bueno';

  @override
  String get ratingExcellent => 'Excelente';

  @override
  String get moodToughDay => 'Día Difícil';

  @override
  String get moodCouldBeBetter => 'Podría Ser Mejor';

  @override
  String get moodPrettyGood => 'Bastante Bueno';

  @override
  String get moodGreatDay => 'Gran Día';

  @override
  String get moodPerfectDay => 'Día Perfecto';

  @override
  String get noDiaryEntriesYet => 'Aún no hay entradas de diario';

  @override
  String get startTrackingDescription =>
      'Comienza a rastrear tu día agregando notas\ny completando evaluaciones diarias';

  @override
  String get startTodaysJournal => 'Comenzar Diario de Hoy';

  @override
  String get confirmDeletion => 'Confirmar Eliminación';

  @override
  String get confirmDeleteDiaryEntryShort =>
      '¿Estás seguro de que quieres eliminar esta entrada de diario?';

  @override
  String get diaryEntryDeleted => 'Entrada de diario eliminada';

  @override
  String get undo => 'Deshacer';

  @override
  String get loadingDayData => 'Cargando datos del día...';

  @override
  String get calendar => 'Calendario';

  @override
  String get noteDetails => 'Detalles de la Nota';

  @override
  String get dayRating => 'Calificación del Día';

  @override
  String get howWasYourDay =>
      '¿Cómo estuvo tu día? Califica los diferentes aspectos de tu experiencia.';

  @override
  String get saveDayRating => 'Guardar Calificación del Día';

  @override
  String get dayRatingSaved => '¡Calificación del día guardada correctamente!';

  @override
  String get notRated => 'Sin Calificar';

  @override
  String get ratingSocialDescription =>
      '¿Cómo fueron tus interacciones sociales y relaciones hoy?';

  @override
  String get ratingProductivityDescription =>
      '¿Qué tan productivo fuiste en tu trabajo o tareas diarias?';

  @override
  String get ratingSportDescription =>
      '¿Cómo estuvo tu actividad física y ejercicio hoy?';

  @override
  String get ratingFoodDescription =>
      '¿Qué tan saludable y satisfactoria fue tu dieta hoy?';

  @override
  String get tapToChangeDate => 'Toca para cambiar la fecha';

  @override
  String get previousDay => 'Día anterior';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get nextDay => 'Día siguiente';

  @override
  String get addTitle => 'Agregar Título';

  @override
  String get addNote => 'Agregar nota';

  @override
  String get description => 'Descripción';

  @override
  String get allDayQuestion => '¿Todo el día?';

  @override
  String get from => 'DESDE';

  @override
  String get to => 'Hasta';

  @override
  String get saveUpperCase => 'GUARDAR';

  @override
  String get saveWord => 'guardar';

  @override
  String get reload => 'recargar';

  @override
  String get noteUpdateError => 'No se pudo actualizar la nota';

  @override
  String dateLabel(String date) {
    return 'Fecha: $date';
  }

  @override
  String get organizeCategoriesDescription =>
      'Organiza tus notas con categorías personalizadas';

  @override
  String get noCategoriesYet => 'Aún no hay categorías';

  @override
  String get createCategoriesToOrganize =>
      'Crea categorías para organizar tus notas';

  @override
  String get createCategory => 'Crear Categoría';

  @override
  String get editCategory => 'Editar Categoría';

  @override
  String get categoryName => 'Nombre de Categoría';

  @override
  String get categoryColor => 'Color de Categoría';

  @override
  String get preview => 'Vista Previa';

  @override
  String get pleaseEnterCategoryName =>
      'Por favor ingresa un nombre de categoría';

  @override
  String get categoryAlreadyExists => 'Ya existe una categoría con este nombre';

  @override
  String get categoryUpdated => 'Categoría actualizada';

  @override
  String get categoryCreated => 'Categoría creada';

  @override
  String get categoryDeleted => 'Categoría eliminada';

  @override
  String get cannotDeleteCategory => 'No se Puede Eliminar la Categoría';

  @override
  String categoryInUse(String title) {
    return 'La categoría \"$title\" está siendo utilizada por una o más notas. Por favor reasigna o elimina esas notas primero.';
  }

  @override
  String get deleteCategory => 'Eliminar Categoría';

  @override
  String confirmDeleteCategory(String title) {
    return '¿Estás seguro de que quieres eliminar \"$title\"?';
  }

  @override
  String get editCategoryTooltip => 'Editar categoría';

  @override
  String get deleteCategoryTooltip => 'Eliminar categoría';

  @override
  String get defaultCategoryWork => 'Trabajo';

  @override
  String get defaultCategoryLeisure => 'Ocio';

  @override
  String get defaultCategoryFood => 'Comida';

  @override
  String get defaultCategoryGym => 'Gimnasio';

  @override
  String get defaultCategorySleep => 'Dormir';

  @override
  String get noteTemplates => 'Plantillas de Notas';

  @override
  String get selectTemplate => 'Seleccionar Plantilla';

  @override
  String get noTemplatesAvailable => 'No hay plantillas disponibles';

  @override
  String get noTemplatesYet => 'Aún no hay plantillas';

  @override
  String get createTemplatesToQuicklyAdd =>
      'Crea plantillas para agregar notas rápidamente';

  @override
  String get createTemplate => 'Crear Plantilla';

  @override
  String get editTemplate => 'Editar Plantilla';

  @override
  String get templateName => 'Nombre de Plantilla';

  @override
  String get durationMinutes => 'Duración (minutos)';

  @override
  String get category => 'Categoría';

  @override
  String get pleaseEnterTemplateName =>
      'Por favor ingresa un nombre de plantilla';

  @override
  String get pleaseEnterDuration => 'Por favor ingresa la duración';

  @override
  String get pleaseEnterValidDuration =>
      'Por favor ingresa una duración válida';

  @override
  String get simple => 'Simple';

  @override
  String get sections => 'Secciones';

  @override
  String get addSection => 'Agregar Sección';

  @override
  String get sectionTitle => 'Título de Sección';

  @override
  String get hintOptional => 'Sugerencia (opcional)';

  @override
  String get removeSection => 'Eliminar sección';

  @override
  String get templateUpdatedSuccessfully =>
      'Plantilla actualizada correctamente';

  @override
  String get templateCreatedSuccessfully => 'Plantilla creada correctamente';

  @override
  String get deleteTemplate => 'Eliminar Plantilla';

  @override
  String confirmDeleteTemplate(String title) {
    return '¿Estás seguro de que quieres eliminar \"$title\"?';
  }

  @override
  String get templateDeleted => 'Plantilla eliminada';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get descriptionSections => 'Secciones de Descripción:';

  @override
  String get descriptionLabel => 'Descripción:';

  @override
  String addedTemplateAtTime(String title, String time) {
    return 'Agregado \"$title\" a las $time';
  }

  @override
  String errorCreatingNote(String error) {
    return 'Error al crear nota: $error';
  }

  @override
  String get fileSynchronization => 'Sincronización de Archivos';

  @override
  String get fileSyncDescription =>
      'Importa y exporta tus datos de diario a archivos JSON o ICS de calendario con cifrado opcional.';

  @override
  String get exportToJson => 'Exportar a JSON';

  @override
  String get saveYourDiaryData => 'Guarda tus datos de diario en un archivo';

  @override
  String get importFromJson => 'Importar desde JSON';

  @override
  String get loadDiaryData => 'Cargar datos de diario desde un archivo';

  @override
  String get exportToIcsCalendar => 'Exportar a Calendario ICS';

  @override
  String get saveNotesAsCalendarEvents =>
      'Guardar notas como eventos de calendario (.ics)';

  @override
  String get importFromIcsCalendar => 'Importar desde Calendario ICS';

  @override
  String get loadCalendarEvents =>
      'Cargar eventos de calendario desde archivo .ics';

  @override
  String get exportRange => 'Rango de Exportación';

  @override
  String get whichEntriesToExport => '¿Qué entradas quieres exportar?';

  @override
  String get customRange => 'Rango Personalizado';

  @override
  String get all => 'Todas';

  @override
  String get encryptJsonExport => 'Cifrar Exportación JSON (Opcional)';

  @override
  String get decryptJsonImport => 'Descifrar Importación JSON';

  @override
  String get encryptIcsExport => 'Cifrar Exportación ICS (Opcional)';

  @override
  String get decryptIcsImport => 'Descifrar Importación ICS';

  @override
  String get passwordOptional => 'Contraseña (Opcional)';

  @override
  String get leaveEmptyForNoEncryption => 'Dejar vacío para no cifrar';

  @override
  String get saveJsonExportFile => 'Guardar Archivo de Exportación JSON';

  @override
  String get selectJsonFileToImport => 'Seleccionar Archivo JSON para Importar';

  @override
  String get saveIcsCalendarFile => 'Guardar Archivo de Calendario ICS';

  @override
  String get selectIcsFileToImport => 'Seleccionar Archivo ICS para Importar';

  @override
  String get operationCompletedSuccessfully =>
      'Operación completada correctamente';

  @override
  String importedDaysWithNotes(int days, int notes) {
    return 'Importados $days días con $notes notas';
  }

  @override
  String importedNotesFromIcs(int count) {
    return 'Importadas $count notas desde calendario ICS';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get oldEncryptionFormatError =>
      'Este archivo usa el formato de cifrado antiguo y no puede ser importado.\nPor favor exporta tus datos nuevamente con la nueva versión.';

  @override
  String get passwordRequiredForEncryptedFile =>
      'Se requiere contraseña para archivo cifrado';

  @override
  String get passwordRequiredForEncryptedIcsFile =>
      'Se requiere contraseña para archivo ICS cifrado';

  @override
  String get cannotReadIcsFile =>
      'No se puede leer el archivo ICS. El archivo puede estar dañado.';

  @override
  String get pleaseEnterAllFields => 'Por favor completa todos los campos';

  @override
  String get fillInYourCompleteDay => 'Completa tu día completo';

  @override
  String get testingConnection => 'Probando conexión...';

  @override
  String get connectionSuccessful => '¡Conexión exitosa!';

  @override
  String get connectionFailedAuth => 'Conexión fallida: Error de autenticación';

  @override
  String connectionFailed(String error) {
    return 'Conexión fallida: $error';
  }

  @override
  String get synchronization => 'Sincronización';

  @override
  String get supabaseSynchronization => 'Sincronización Supabase';

  @override
  String get supabaseSyncDescription =>
      'Sincroniza tus datos del diario con el almacenamiento en la nube de Supabase para respaldo y acceso entre dispositivos.';

  @override
  String get uploadToSupabase => 'Subir a Supabase';

  @override
  String get saveYourDiaryDataToCloud =>
      'Guarda tus datos del diario en la nube';

  @override
  String get downloadFromSupabase => 'Descargar de Supabase';

  @override
  String get loadDiaryDataFromCloud => 'Carga datos del diario desde la nube';

  @override
  String get supabaseSettings => 'Configuración de Supabase';

  @override
  String get supabaseDescription =>
      'Configura tu almacenamiento en la nube Supabase para respaldo y acceso entre dispositivos.';

  @override
  String get supabaseUrl => 'URL de Supabase';

  @override
  String get anonKey => 'Clave Anónima';

  @override
  String get testConnection => 'Probar Conexión';

  @override
  String get pdfExport => 'Exportar PDF';

  @override
  String get pdfExportDescription =>
      'Genera informes PDF imprimibles con tus entradas de diario, calificaciones y estadísticas.';

  @override
  String get quickExport => 'Exportación Rápida';

  @override
  String get lastWeek => 'Últimos 7 Días';

  @override
  String get lastMonth => 'Últimos 30 Días';

  @override
  String get currentMonth => 'Este Mes';

  @override
  String get selectDateRangeForReport =>
      'Selecciona un rango de fechas personalizado para tu informe';

  @override
  String get selectMonth => 'Seleccionar Mes';

  @override
  String get selectSpecificMonth => 'Elige un mes específico para exportar';

  @override
  String get exportAllData => 'Exportar Todos los Datos';

  @override
  String get generatePdfWithAllData =>
      'Generar informe PDF con todos tus datos';

  @override
  String get selectDateRange => 'Seleccionar rango de fechas para el informe';

  @override
  String get export => 'Exportar';

  @override
  String get pdfExportSuccess => 'Informe PDF generado exitosamente';

  @override
  String pdfExportError(String error) {
    return 'Error al generar PDF: $error';
  }

  @override
  String get about => 'Acerca de';

  @override
  String get dayTracker => 'Day Tracker';

  @override
  String version(String version) {
    return 'Versión: $version';
  }

  @override
  String get developer => 'Desarrollador';

  @override
  String get contact => 'Contacto';

  @override
  String get features => 'Características';

  @override
  String get licenses => 'Licencias';

  @override
  String get viewLicenses => 'Ver Licencias';

  @override
  String get appDescription =>
      'Day Tracker es una aplicación personal de diario y productividad que te ayuda a rastrear tus actividades diarias y calificar diferentes aspectos de tu día.';

  @override
  String get featureTrackActivities => 'Rastrea actividades diarias y citas';

  @override
  String get featureRateDay => 'Califica diferentes aspectos de tu día';

  @override
  String get featureCalendar => 'Ve tu horario en un calendario';

  @override
  String get featureEncryption => 'Datos seguros con cifrado';

  @override
  String get featureSync => 'Sincroniza datos entre dispositivos con Supabase';

  @override
  String get featureExportImport => 'Exporta e importa datos';

  @override
  String copyright(int year) {
    return '© $year Your Company';
  }

  @override
  String score(int score) {
    return 'Puntuación: $score';
  }

  @override
  String get createNote => 'Crear Nota';

  @override
  String get fromTemplate => 'Desde Plantilla';

  @override
  String get noNoteSelected => 'Ninguna nota seleccionada';

  @override
  String get clickExistingOrCreateNew =>
      'Haz clic en una nota existente o crea una nueva';

  @override
  String get title => 'Título';

  @override
  String get stopDictation => 'Detener dictado';

  @override
  String get dictateDescription => 'Dictar descripción';

  @override
  String get addDetailsAboutNote => 'Agrega detalles sobre esta nota...';

  @override
  String get listening => 'Escuchando...';

  @override
  String get template => 'Plantilla';

  @override
  String get add => 'Agregar';

  @override
  String get deleteNote => 'Eliminar Nota';

  @override
  String get confirmDeleteNote =>
      '¿Estás seguro de que quieres eliminar esta nota?';

  @override
  String get endTimeAfterStartTime =>
      'La hora de fin debe ser posterior a la hora de inicio';

  @override
  String addedNoteAtTime(String time) {
    return 'Nueva nota agregada a las $time';
  }

  @override
  String get dailySchedule => 'Horario Diario';

  @override
  String get scheduleComplete => 'Horario completo';

  @override
  String get newNote => 'Nueva Nota';

  @override
  String fromTime(String time) {
    return 'Desde: $time';
  }

  @override
  String toTime(String time) {
    return 'Hasta: $time';
  }

  @override
  String get searchNotes => 'Buscar notas...';

  @override
  String get searchNotesPlaceholder => 'Buscar por título o descripción';

  @override
  String get filterByCategory => 'Filtrar por categoría';

  @override
  String get filterByDate => 'Filtrar por fecha';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get clearAll => 'Limpiar todo';

  @override
  String get dateFrom => 'Desde fecha';

  @override
  String get dateTo => 'Hasta fecha';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get noNotesMatchSearch => 'No hay notas que coincidan con tu búsqueda';

  @override
  String get tryDifferentSearch => 'Intenta ajustar tus criterios de búsqueda';

  @override
  String nResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoritos';

  @override
  String get favoriteDays => 'Días Favoritos';

  @override
  String get favoriteNotes => 'Notas Favoritas';

  @override
  String get addToFavorites => 'Agregar a favoritos';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get noFavorites => 'Aún no hay favoritos';

  @override
  String get noFavoriteDays => 'No hay días favoritos';

  @override
  String get noFavoriteNotes => 'No hay notas favoritas';

  @override
  String get markAsFavorite => 'Marcar como favorito';

  @override
  String get unmarkAsFavorite => 'Desmarcar como favorito';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get notificationSettings => 'Configuración de notificaciones';

  @override
  String get notificationSettingsDescription =>
      'Configura recordatorios y notificaciones para tus entradas de diario.';

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get enableNotificationsDescription =>
      'Activa recordatorios diarios para escribir en tu diario';

  @override
  String get reminderTime => 'Hora del recordatorio';

  @override
  String get reminderTimeDescription => 'Elige cuándo quieres ser recordado';

  @override
  String get smartReminders => 'Recordatorios inteligentes';

  @override
  String get smartRemindersDescription =>
      'Solo recordar si aún no has escrito la entrada de hoy';

  @override
  String get streakWarnings => 'Advertencias de racha';

  @override
  String get streakWarningsDescription =>
      'Recibe notificaciones cuando tu racha de escritura esté en riesgo';

  @override
  String get notificationPermissionDenied =>
      'Se denegó el permiso de notificación. Por favor, actívalo en la configuración.';

  @override
  String get selectReminderTime => 'Seleccionar hora del recordatorio';

  @override
  String get goalsSectionTitle => 'Objetivos';

  @override
  String get goalCreateNew => 'Crear Objetivo';

  @override
  String get goalCreate => 'Crear';

  @override
  String get goalSelectCategory => '¿Qué área quieres mejorar?';

  @override
  String get goalSelectTimeframe => 'Elige tu plazo';

  @override
  String get goalSetTarget => 'Establece tu objetivo';

  @override
  String goalTargetHint(String category) {
    return '¿Qué promedio de $category quieres alcanzar?';
  }

  @override
  String get goalWeekly => 'Semanal';

  @override
  String get goalMonthly => 'Mensual';

  @override
  String get goalDaysLeft => 'días restantes';

  @override
  String get goalDaysRemaining => 'Días Restantes';

  @override
  String get goalCurrentAverage => 'Actual';

  @override
  String get goalTarget => 'Objetivo';

  @override
  String get goalTargetLabel => 'Puntuación Objetivo';

  @override
  String goalSuggestedTarget(String target) {
    return 'Basado en tu historial, sugerimos $target';
  }

  @override
  String get goalUseSuggestion => 'Usar';

  @override
  String get goalEmptyTitle => 'Sin objetivos activos';

  @override
  String get goalEmptySubtitle =>
      'Establece un objetivo para seguir tu progreso y mantenerte motivado';

  @override
  String get goalSetFirst => 'Establece tu Primer Objetivo';

  @override
  String get goalStatusOnTrack => 'En camino';

  @override
  String get goalStatusBehind => 'Necesita atención';

  @override
  String get goalStatusAhead => '¡Superando el objetivo!';

  @override
  String get goalStatusCompleted => '¡Objetivo alcanzado!';

  @override
  String get goalStatusFailed => 'Objetivo no alcanzado';

  @override
  String get goalStreak => 'Racha de Objetivos';

  @override
  String get goalHistory => 'Historial de Objetivos';

  @override
  String get goalSuccessRate => 'Tasa de Éxito';

  @override
  String get days => 'días';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get photos => 'Fotos';

  @override
  String get noPhotos => 'No hay fotos adjuntas';

  @override
  String get deletePhoto => 'Eliminar foto';

  @override
  String get deletePhotoConfirm =>
      '¿Está seguro de que desea eliminar esta foto?';

  @override
  String get imageNotFound => 'Imagen no encontrada';
}
