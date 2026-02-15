import 'package:app_links/app_links.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:home_widget/home_widget.dart';
import 'package:day_tracker/core/settings/settings_container.dart';

/// Service for managing home screen widget integration
class WidgetService {
  static const String appGroupId = 'group.com.example.daytracker';
  static const String androidWidgetName = 'QuickNoteWidgetReceiver';

  /// Pending quick note URI from widget launch (survives login flow)
  static Uri? pendingQuickNoteUri;

  /// Callback for when widget is clicked while app is running
  static void Function(Uri)? _onWidgetClickCallback;

  /// Initialize home widget and check if launched from widget
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);

    // Check if app was cold-started from the widget via app_links
    // (app_links captures deep links before home_widget)
    final appLinks = AppLinks();
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null && initialUri.scheme == 'daytracker' && initialUri.host == 'quicknote') {
      LogWrapper.logger.i('App launched from widget with URI: $initialUri');
      pendingQuickNoteUri = initialUri;
    }

    // Listen for deep links while app is running
    appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'daytracker' && uri.host == 'quicknote') {
        LogWrapper.logger.i('Widget deep link received: $uri');
        pendingQuickNoteUri = uri;
        _onWidgetClickCallback?.call(uri);
      }
    });

    // Also listen to home_widget clicks as fallback
    HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        LogWrapper.logger.i('Widget clicked with URI: $uri');
        pendingQuickNoteUri = uri;
        _onWidgetClickCallback?.call(uri);
      }
    });
  }

  /// Register a callback for real-time widget clicks (when app is already open)
  static void setOnWidgetClickCallback(void Function(Uri) callback) {
    _onWidgetClickCallback = callback;
  }

  /// Consume the pending URI (returns it and clears it)
  static Uri? consumePendingUri() {
    final uri = pendingQuickNoteUri;
    pendingQuickNoteUri = null;
    return uri;
  }

  /// Update widget with current data
  static Future<void> updateWidget({String? lastCategory}) async {
    if (lastCategory != null) {
      await HomeWidget.saveWidgetData<String>('widget_last_category', lastCategory);
    }

    await HomeWidget.saveWidgetData<String>(
      'current_user',
      settingsContainer.lastLoggedInUsername,
    );

    await HomeWidget.saveWidgetData<String>(
      'app_path',
      settingsContainer.applicationDocumentsPath,
    );

    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: 'QuickNoteWidget',
    );
  }

  /// Register background callback for widget actions
  static Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerInteractivityCallback(backgroundCallback);
  }
}

/// Background callback for widget interactions
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri != null) {
    WidgetService.pendingQuickNoteUri = uri;
  }
}
