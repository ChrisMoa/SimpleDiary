import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/core/settings/settings_provider.dart';
import 'package:day_tracker/core/utils/debug_auto_login.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/data/models/user_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDataProvider extends StateNotifier<UserData> {
  final SettingsContainer _settings;

  UserDataProvider(this._settings)
      : super(_settings.lastLoggedInUsername.isNotEmpty
            ? _settings.getUserSettings().savedUserData
            : UserData.fromEmpty());

  void createUser(UserData userData) {
    LogWrapper.logger.t('creates user ${userData.username}');
    // When creating a real account, clean up the demo guest account.
    if (userData.username != _demoUsername) {
      _removeDemoUserIfExists();
    }
    bool userExists = _settings.checkIfUserExists(userData.username);
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

    _settings.userSettings.add(newUserSettings);
    _settings.lastLoggedInUsername = userData.username;
    _settings.activeUserSettings = newUserSettings;
    _settings.activeUserSettings.savedUserData.clearPassword = originalPassword;
    _settings.saveSettings();

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
    bool userExists = _settings.checkIfUserExists(username);
    assert(userExists, '$username doesnt exist in the database');

    var savedUserData = _settings.userSettings
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
    _settings.lastLoggedInUsername = stateUserData.username;
    _settings.activeUserSettings = _settings.getUserSettings();
    _settings.activeUserSettings.savedUserData.clearPassword = password;
    _settings.saveSettings();
    LogWrapper.logger.i('logged in as ${state.username}');
    return true;
  }

  void updateUser(UserData userData) {
    LogWrapper.logger.i('update user ${userData.username}');
    var oldUsername =
        _settings.activeUserSettings.savedUserData.username;

    var savedUserData = _settings.userSettings
        .firstWhere(
            (userSetting) =>
                userSetting.savedUserData.username == oldUsername)
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

    // Update username
    savedUserData.username = userData.username;

    // Update email
    savedUserData.email = userData.email;

    // update saved user
    _settings.activeUserSettings.savedUserData = savedUserData;
    _settings.activeUserSettings.savedUserData.clearPassword = originalPassword;
    _settings.lastLoggedInUsername = userData.username;
    var existingUserIndex = _settings.userSettings.indexWhere(
        (userSetting) => userSetting == _settings.activeUserSettings);
    if (existingUserIndex != -1) {
      _settings.userSettings[existingUserIndex] =
          _settings.activeUserSettings;
    }
    _settings.saveSettings();

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

  /// Lock the session without clearing credentials.
  /// Used for biometric re-lock on app resume.
  void lockSession() {
    LogWrapper.logger.i('Locking session for user ${state.username}');
    state = UserData(
      username: state.username,
      password: state.password,
      salt: state.salt,
      email: state.email,
      userId: state.userId,
      isLoggedIn: false,
      clearPassword: state.clearPassword,
    );
  }

  void logout() {
    LogWrapper.logger.i('logout from user ${state.username}');
    UserData emptyUser = UserData.fromEmpty();
    var userSettings = _settings.userSettings;
    var emptyUserSettings = userSettings.firstWhere(
      (userSetting) => userSetting.savedUserData.username == emptyUser.username,
      orElse: () => UserSettings.fromEmpty(),
    );
    if (!_settings
        .checkIfUserExists(emptyUserSettings.savedUserData.username)) {
      createUser(UserData.fromEmpty());
    } else {
      _settings.activeUserSettings =
          emptyUserSettings; // 0 is always empty user
      _settings.lastLoggedInUsername = '';
    }
    state = emptyUser;
  }

  static const _demoUsername = 'Demo User';

  /// Creates (or logs in) the demo guest account used during the "Explore"
  /// onboarding path.  The account has an empty password so no authentication
  /// dialog is shown.
  void createDemoUser() {
    if (!_settings.checkIfUserExists(_demoUsername)) {
      createUser(UserData(username: _demoUsername, clearPassword: ''));
    } else {
      login(_demoUsername, '');
    }
  }

  /// Removes the demo guest account from settings if it exists.
  /// Called automatically at the start of [createUser] for real accounts.
  void _removeDemoUserIfExists() {
    _settings.userSettings.removeWhere(
      (s) => s.savedUserData.username == _demoUsername,
    );
    LogWrapper.logger.d('Removed demo user account if present');
  }

  void debugAutoLogin() {
    if (!DebugAutoLogin.isEnabled || !DebugAutoLogin.hasValidCredentials) {
      return;
    }

    final username = DebugAutoLogin.username;
    final password = DebugAutoLogin.password;
    final email = DebugAutoLogin.email;

    LogWrapper.logger.i('Debug auto-login: attempting login as $username');

    // Create user if doesn't exist yet
    if (!_settings.checkIfUserExists(username)) {
      LogWrapper.logger.i('Debug auto-login: creating test user $username');
      createUser(UserData(
        username: username,
        clearPassword: password,
        email: email,
      ));
      return; // createUser already sets isLoggedIn=true
    }

    // User exists, log in
    final success = login(username, password);
    if (!success) {
      LogWrapper.logger.e('Debug auto-login failed for $username');
    }
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
  (ref) => UserDataProvider(ref.read(settingsProvider)),
);

final userDataSettingsProvider = Provider<UserSettings>((ref) {
  final userData = ref.watch(userDataProvider);
  var userSettings = ref.read(settingsProvider).userSettings;
  return userSettings.firstWhere(
      (userSetting) => userSetting.savedUserData.username == userData.username);
});
