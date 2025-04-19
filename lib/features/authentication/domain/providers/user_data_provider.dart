import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDataProvider extends StateNotifier<UserData> {
  UserDataProvider()
      : super(settingsContainer.lastLoggedInUsername.isNotEmpty
            ? settingsContainer.getUserSettings().savedUserData
            : UserData.fromEmpty());

  void createUser(UserData userData) {
    LogWrapper.logger.t('creates user ${userData.username}');
    bool userExists = settingsContainer.checkIfUserExists(userData.username);
    assert(!userExists, '${userData.username} already exists in the database');

    // Store original clear password
    String originalPassword = userData.clearPassword;

    // Hash password and generate salt
    final passwordData = PasswordAuthService.hashPassword(originalPassword);

    var savedUser = UserData(
      username: userData.username,
      password: passwordData['hashedPassword']!,
      salt: passwordData['salt']!,
      email: userData.email,
      userId: userData.userId,
    );

    // Store user settings
    UserSettings newUserSettings = UserSettings.fromEmpty();
    newUserSettings.savedUserData = savedUser;

    settingsContainer.userSettings.add(newUserSettings);
    settingsContainer.lastLoggedInUsername = userData.username;
    settingsContainer.activeUserSettings = newUserSettings;
    settingsContainer.saveSettings();

    // Create a new UserData for state with clearPassword
    UserData sessionUser = UserData(
      username: savedUser.username,
      password: savedUser.password,
      salt: savedUser.salt,
      email: savedUser.email,
      userId: savedUser.userId,
      isLoggedIn: true,
      clearPassword: originalPassword,
    );

    state = sessionUser;
  }

  bool login(String username, String password) {
    bool userExists = settingsContainer.checkIfUserExists(username);
    assert(userExists, '$username doesnt exist in the database');

    var savedUserData = settingsContainer.userSettings
        .firstWhere(
            (userSetting) => userSetting.savedUserData.username == username)
        .savedUserData;

    // Verify password
    bool isPasswordValid = PasswordAuthService.verifyPassword(
        password, savedUserData.password, savedUserData.salt);

    if (!isPasswordValid) {
      LogWrapper.logger.d('Password for $username was incorrect');
      return false;
    }

    // Password is valid, create session user data
    var stateUserData = UserData(
      username: savedUserData.username,
      password: savedUserData.password,
      salt: savedUserData.salt,
      email: savedUserData.email,
      userId: savedUserData.userId,
      isLoggedIn: true,
      clearPassword: password, // Store cleartext password for session
    );

    state = stateUserData;
    settingsContainer.lastLoggedInUsername = stateUserData.username;
    settingsContainer.activeUserSettings = settingsContainer.getUserSettings();
    settingsContainer.saveSettings();
    LogWrapper.logger.i('logged in as ${state.username}');
    return true;
  }

  void updateUser(UserData userData) {
    LogWrapper.logger.i('update user ${userData.username}');
    var username = userData.username;
    assert(
        username == settingsContainer.activeUserSettings.savedUserData.username,
        '${userData.username} does not exist in the database');

    var savedUserData = settingsContainer.userSettings
        .firstWhere(
            (userSetting) => userSetting.savedUserData.username == username)
        .savedUserData;

    // Store original clear password if available
    String originalPassword = userData.clearPassword.isNotEmpty
        ? userData.clearPassword
        : state.clearPassword;

    // Update password if new one provided
    if (userData.clearPassword.isNotEmpty &&
        userData.clearPassword != state.clearPassword) {
      final passwordData =
          PasswordAuthService.hashPassword(userData.clearPassword);
      savedUserData.password = passwordData['hashedPassword']!;
      savedUserData.salt = passwordData['salt']!;
    }

    // Update email
    savedUserData.email = userData.email;

    // update saved user
    settingsContainer.activeUserSettings.savedUserData = savedUserData;
    var existingUserIndex = settingsContainer.userSettings.indexWhere(
        (userSetting) => userSetting == settingsContainer.activeUserSettings);
    if (existingUserIndex != -1) {
      settingsContainer.userSettings[existingUserIndex] =
          settingsContainer.activeUserSettings;
    }
    settingsContainer.saveSettings();

    // update state user with clear password
    UserData updatedStateUser = UserData(
      username: savedUserData.username,
      password: savedUserData.password,
      salt: savedUserData.salt,
      email: savedUserData.email,
      userId: savedUserData.userId,
      isLoggedIn: true,
      clearPassword: originalPassword,
    );

    state = updatedStateUser;
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

  // Helper method to get database encryption key for current user
  String getDatabaseEncryptionKey() {
    if (state.username.isEmpty || state.clearPassword.isEmpty) {
      LogWrapper.logger
          .e('Cannot generate encryption key: invalid credentials');
      return '';
    }

    return PasswordAuthService.getDatabaseEncryptionKey(
        state.clearPassword, state.salt);
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
