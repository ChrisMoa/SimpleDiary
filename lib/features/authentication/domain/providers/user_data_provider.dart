import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDataProvider extends StateNotifier<UserData> {
  UserDataProvider()
      : super(settingsContainer.lastLoggedInUsername.isNotEmpty
            ? settingsContainer.getUserSettings().savedUserData
            : UserData.fromEmpty()) {
    //* try to check if an active user was set to shared pref
  }

  void createUser(UserData userData) {
    LogWrapper.logger.t('creates user ${userData.username}');
    bool userExists = settingsContainer.checkIfUserExists(userData.username);
    assert(!userExists, '${userData.username} already exists in the database');

    // hash pin and password
    var hashedPin = sha256.convert(utf8.encode(userData.pin)).toString();
    var encryptor = AesEncryptor(password: userData.pin);

    var savedUser =
        userData; // copy of user with the hashed pin and encrypted password
    savedUser.password = encryptor.encryptStringAsBase64(userData.password);
    savedUser.pin = hashedPin;
    UserSettings newUserSettings = UserSettings.fromEmpty();
    newUserSettings.savedUserData = savedUser;

    settingsContainer.userSettings.add(newUserSettings);

    // apply userData unencrypted as state
    settingsContainer.lastLoggedInUsername = userData.username;
    settingsContainer.activeUserSettings = newUserSettings;
    settingsContainer.saveSettings();
    state = userData;
  }

  bool login(String username, String pin) {
    bool userExists = settingsContainer.checkIfUserExists(username);
    assert(userExists, '$username doesnt exist in the database');
    var stateUserData = UserData(username: username, pin: pin);
    var savedUserData = settingsContainer.userSettings
        .firstWhere(
            (userSetting) => userSetting.savedUserData.username == username)
        .savedUserData;
    var hashedPin = sha256.convert(utf8.encode(stateUserData.pin)).toString();
    if (hashedPin != savedUserData.pin) {
      LogWrapper.logger.d('pin of $username wasnt correct');
      return false;
    }
    var decryptor = AesEncryptor(password: pin);
    stateUserData.email = savedUserData.email;
    stateUserData.password =
        decryptor.decryptStringFromBase64(savedUserData.password);
    stateUserData.isLoggedIn = true;
    stateUserData.userId = savedUserData.userId;
    state = stateUserData;
    settingsContainer.lastLoggedInUsername = stateUserData.username;
    settingsContainer.activeUserSettings = settingsContainer.getUserSettings();
    settingsContainer.saveSettings();
    LogWrapper.logger.i('logged in as ${state.username}');
    return true;
  }

  void updateUser(UserData clearUserData) {
    LogWrapper.logger.i('update user ${clearUserData.username}');
    var username = clearUserData.username;
    assert(
        username == settingsContainer.activeUserSettings.savedUserData.username,
        '${clearUserData.username} does not exist in the database');
    var stateUserData = clearUserData;
    var savedUserData = settingsContainer.userSettings
        .firstWhere(
            (userSetting) => userSetting.savedUserData.username == username)
        .savedUserData;

    // udate pin
    var hashedPin = sha256.convert(utf8.encode(stateUserData.pin)).toString();
    savedUserData.pin = hashedPin;

    // update password
    var encryptor = AesEncryptor(password: stateUserData.pin);
    savedUserData.password =
        encryptor.encryptStringAsBase64(stateUserData.password);

    // update saved user
    settingsContainer.activeUserSettings.savedUserData = savedUserData;
    var existingUserIndex = settingsContainer.userSettings.indexWhere(
        (userSetting) => userSetting == settingsContainer.activeUserSettings);
    if (existingUserIndex != -1) {
      settingsContainer.userSettings[existingUserIndex] =
          settingsContainer.activeUserSettings;
    }
    settingsContainer.saveSettings();

    // update state user
    state = stateUserData;
  }

  void updateUserPassword(UserData userData) {
    login(userData.username, userData.pin);
  }

  void logout() {
    LogWrapper.logger.i('logout from user ${state.username}');
    UserData emptyUser = UserData.fromEmpty();
    var userSettings = settingsContainer.userSettings;
    var emptyUserSettings = userSettings.firstWhere(
      (userSetting) => userSetting.savedUserData.username == emptyUser.username,
      orElse: () => UserSettings.fromEmpty(),
    );
    if (!settingsContainer
        .checkIfUserExists(emptyUserSettings.savedUserData.username)) {
      createUser(UserData.fromEmpty());
    } else {
      settingsContainer.activeUserSettings =
          emptyUserSettings; // 0 is always empty user
      settingsContainer.lastLoggedInUsername = '';
    }
    state = emptyUser;
  }
}

final userDataProvider = StateNotifierProvider<UserDataProvider, UserData>(
  (ref) => UserDataProvider(),
);

final userDataSettingsProvider = Provider<UserSettings>((ref) {
  final userData = ref.watch(userDataProvider);
  var userSettings = settingsContainer.userSettings;
  return userSettings.firstWhere(
      (userSetting) => userSetting.savedUserData.username == userData.username);
});
