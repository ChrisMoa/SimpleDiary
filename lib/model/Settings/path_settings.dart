import 'package:SimpleDiary/model/Settings/settings.dart';
import 'package:SimpleDiary/model/Settings/setting_parameter.dart';
import 'package:SimpleDiary/model/active_platform.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class PathSettings extends Settings {  
  SettingsParameter<String> applicationDocumentsPath = SettingsParameter<String>('');

  @override
  Future<void> fromMap(Map<String, dynamic> map) async {
    map.containsKey('applicationDocumentsPath') 
    ? applicationDocumentsPath = SettingsParameter<String>(map['applicationDocumentsPath']) 
    : applicationDocumentsPath = SettingsParameter<String>(await _readAppDocumentsPath());
    // Add other parameters here
  }

  @override
  Future<Map<String, dynamic>> toMap() async {
    Map<String, dynamic> map = {
      // add initializer list here
      'applicationDocumentsPath': applicationDocumentsPath.value,
    };
    return map;
  }

  @override
  String get name => 'PathSettings';

  Future<String> _readAppDocumentsPath() async {  
  switch(activePlatform.platform){
    case ActivePlatform.ios:
    case ActivePlatform.android:
      return '/storage/emulated/0/${dotenv.env['PROJECT_NAME'] ?? 'SimpleDiary'}' ;
    case ActivePlatform.windows:
      var addAppPath = dotenv.env['PROJECT_NAME'] ?? 'SimpleDiary';
      return '${(await getApplicationDocumentsDirectory()).path}/$addAppPath';
    default: throw Exception('platform not supported');
  }
}
}
