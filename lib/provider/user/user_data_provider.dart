import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:SimpleDiary/services/database_services/user_data_local_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDataProvider extends StateNotifier<UserData> {
  final _sharedPreferenceStorage = const FlutterSecureStorage();
  late UserDataLocalDb _userDataLocalDb;

  UserDataProvider() : super(UserData.fromEmpty()) {
    _userDataLocalDb = UserDataLocalDb(primaryKey: 'username', tableName: 'userData');
    _userDataLocalDb.initDatabase();

    //* try to check if an active user was set to shared pref
    readSharedPreferences();
  }

  @override
  void dispose() {
    writeSharedPreferences(false);
    super.dispose();
  }

  Future<void> readSharedPreferences() async {
    var overallMap = await _sharedPreferenceStorage.readAll();
    try {
      state = UserData.fromMap(overallMap);
      LogWrapper.logger.t('last user: ${state.username}');
    } catch (e) {
      LogWrapper.logger.t('cant read userData: ${e.toString()}');
    }
  }

  Future<void> writeSharedPreferences(bool ignoreEmptyUser) async {
    if (!ignoreEmptyUser && state.username.isEmpty) {
      return;
    }
    LogWrapper.logger.t('writes data of user ${state.username} to the shared preferences');
    for (var entry in state.toMap().entries) {
      await _sharedPreferenceStorage.write(key: entry.key, value: entry.value);
    }
  }

  Future<void> createUser(UserData userData) async {
    LogWrapper.logger.t('creates user ${userData.username}');
    bool userExists = await _userDataLocalDb.checkIfElementExists(userData);
    assert(!userExists, '${userData.username} already exists in the database');
    await _userDataLocalDb.insert(userData);
    state = userData;
    writeSharedPreferences(false);
  }

  Future<bool> login(String username, String pin) async {
    var tmpUser = UserData(username: username, pin: pin);
    bool userExists = await _userDataLocalDb.checkIfElementExists(tmpUser);
    assert(userExists, '$username doesnt exist in the database');
    var user = (await _userDataLocalDb.getElement(tmpUser.getId())) as UserData;
    if(pin != user.pin){
      return false;
    }
    user.isLoggedIn = true;
    state = user;
    writeSharedPreferences(false);
    LogWrapper.logger.t('logged in as ${state.username}');
    return true;
  }

  Future<void> updateUser(UserData userData) async {
    LogWrapper.logger.t('update user ${userData.username}');
    bool userExists = await _userDataLocalDb.checkIfElementExists(userData);
    assert(userExists, '${userData.username} does not exists in the database');
    await _userDataLocalDb.update(userData);
    state = userData;
    writeSharedPreferences(false);
  }

  Future<void> logout() async {
    LogWrapper.logger.t('logout from user ${state.username}');
    state = UserData.fromEmpty();
    writeSharedPreferences(true);
  }
}

final userDataProvider = StateNotifierProvider<UserDataProvider, UserData>(
  (ref) => UserDataProvider(),
);
