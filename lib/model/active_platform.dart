import 'dart:io';

enum ActivePlatform { android, ios, linux, windows, macOS, web }

class ActivePlatformClass {
  late ActivePlatform _platform;

  ActivePlatformClass() {
    try {
      _platform = _getActivePlatform();
    } catch (e) {
      _platform = ActivePlatform.web;
    }
  }

  ActivePlatform get platform {
    return _platform;
  }

  ActivePlatform _getActivePlatform() => Platform.isAndroid
      ? ActivePlatform.android
      : Platform.isIOS
          ? ActivePlatform.ios
          : Platform.isLinux
              ? ActivePlatform.linux
              : Platform.isWindows
                  ? ActivePlatform.windows
                  : Platform.isMacOS
                      ? ActivePlatform.macOS
                      : ActivePlatform.web;
}

final ActivePlatformClass activePlatform = ActivePlatformClass();
