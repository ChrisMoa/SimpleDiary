import 'dart:io';

import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LogWrapper {
  LogWrapper();

  static Future<File> createLogfile() async {
    // ignore: deprecated_member_use
    var logDir =
        Directory('${settingsContainer.applicationExternalDocumentsPath}/Logs');
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
    level: kDebugMode ? Level.trace : Level.warning,
    output: ConsoleOutput(),
    printer: PrettyPrinter(
      noBoxingByDefault: true,
      methodCount: 2,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
    ),
  );
}
