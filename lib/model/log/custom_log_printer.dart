import 'package:SimpleDiary/utils.dart';
import 'package:logger/logger.dart';

class CustomLogPrinter extends LogPrinter {
  final splitChars = ';';

  @override
  List<String> log(LogEvent event) {
    return [
      Utils.toTimeFine(event.time) + splitChars + event.level.name + splitChars + event.message,
    ];
  }
}
