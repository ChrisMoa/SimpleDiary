import 'dart:convert';
import 'dart:io';
import 'package:SimpleDiary/model/Settings/settings_container.dart';
import 'package:SimpleDiary/model/encryption/aes_encryptor.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:SimpleDiary/services/database_services/user_data_local_db.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDataProvider extends StateNotifier<UserData> {
  late UserDataLocalDb _userDataLocalDb;

  UserDataProvider() : super(settingsContainer.userSettings.lastLoggedInUsername.value.isNotEmpty ? UserData(username: settingsContainer.userSettings.lastLoggedInUsername.value) : UserData.fromEmpty()) {
    _userDataLocalDb = UserDataLocalDb(primaryKey: 'username', tableName: 'userData', dbFile: File('${settingsContainer.pathSettings.applicationDocumentsPath.value}/users.db'));
    _userDataLocalDb.initDatabase();

    //* try to check if an active user was set to shared pref
  }

  Future<void> createUser(UserData userData) async {
    LogWrapper.logger.t('creates user ${userData.username}');
    bool userExists = await _userDataLocalDb.checkIfElementExists(userData);
    assert(!userExists, '${userData.username} already exists in the database');

    // hash pin and password 
    var hashedPin = sha256.convert(utf8.encode(userData.pin)).toString();
    var encryptor = AesEncryptor(password: userData.pin);
    
    var savedUser = userData; // copy of user with the hashed pin and encrypted password
    savedUser.password = encryptor.encryptStringAsBase64(userData.password);
    savedUser.pin = hashedPin;
    await _userDataLocalDb.insert(savedUser);

    // apply userData unencrypted as state
    settingsContainer.userSettings.lastLoggedInUsername.value = userData.username;
    state = userData;
  }

  Future<bool> login(String username, String pin) async {
    var tmpUser = UserData(username: username, pin: pin);
    bool userExists = await _userDataLocalDb.checkIfElementExists(tmpUser);
    if(username == testUserData.username && !userExists){
      LogWrapper.logger.d('add test user to database');
      createUser(testUserData);
      userExists = true;
    }
    assert(userExists, '$username doesnt exist in the database');
    var user = (await _userDataLocalDb.getElement(tmpUser.getId())) as UserData;
    var hashedPin = sha256.convert(utf8.encode(pin)).toString();
    if(hashedPin != user.pin){
      LogWrapper.logger.d('pin of $username wasnt correct');
      return false;
    }
    var decryptor = AesEncryptor(password: pin);
    user.pin = pin;
    user.password = decryptor.decryptStringFromBase64(user.password);
    user.isLoggedIn = true;
    state = user;
    settingsContainer.userSettings.lastLoggedInUsername.value = user.username;
    LogWrapper.logger.i('logged in as ${state.username}');
    return true;
  }

  Future<void> updateUser(UserData userData) async {
    LogWrapper.logger.i('update user ${userData.username}');
    bool userExists = await _userDataLocalDb.checkIfElementExists(userData);
    assert(userExists, '${userData.username} does not exists in the database');
    await _userDataLocalDb.update(userData);
    state = userData;
    settingsContainer.userSettings.lastLoggedInUsername.value = userData.username;
  }

  Future<void> logout() async {
    LogWrapper.logger.i('logout from user ${state.username}');
    state = UserData.fromEmpty();
    settingsContainer.userSettings.lastLoggedInUsername.value = '';
  }
}

final userDataProvider = StateNotifierProvider<UserDataProvider, UserData>(
  (ref) => UserDataProvider(),
);
