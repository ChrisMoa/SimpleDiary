import 'dart:io';
import 'package:SimpleDiary/model/Settings/settings_container.dart';
import 'package:SimpleDiary/utils.dart';
import 'package:logger/logger.dart';

class LogWrapper {
  LogWrapper();

  static Future<File> createLogfile() async {
    var logDir = Directory('${settingsContainer.applicationDocumentsPath}/Logs');
    await logDir.create(recursive: true);
    var logFiles = logDir.listSync(recursive: false).whereType<File>().toList();
    logFiles.sort((a, b) {
      if (a.lastModifiedSync().isAfter(b.lastModifiedSync())) {
        return 0;
      } else {
        return 1;
      }
    });
    for (var file in logFiles.skip(9)) {
      file.deleteSync();
    }
    final date = Utils.toFileDateTime(DateTime.now());
    return File('${logDir.path}/${date}_log.csv');
  }

  static Logger logger = Logger(
    level: Level.trace,
    output: ConsoleOutput(),
    printer: PrettyPrinter(
      // printTime: true,
      noBoxingByDefault: true,
      methodCount: 2, // Number of method calls to display
      errorMethodCount: 3, // Number of method calls to display for errors
      lineLength: 80, // Width of log output
      colors: true, // Colorize log messages
    ),
  );
}
