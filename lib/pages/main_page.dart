import 'dart:io';
import 'dart:ui';

import 'package:SimpleDiary/model/encryption/aes_encryptor.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:SimpleDiary/pages/auth/auth_user_data_page.dart';
import 'package:SimpleDiary/pages/auth/show_user_data_page.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:SimpleDiary/services/drawer_item_builder.dart';
import 'package:SimpleDiary/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  //* parameters -------------------------------------------------------------------------------------------------------------------------------------
  int _selectedDrawerIndex = 0;
  final DrawerItemProvider _drawerItemProvider = DrawerItemProvider();
  var _userData = UserData.fromEmpty();
  bool dbRead = false;
  bool _asyncInit = false;
  late AesEncryptor _aesEncryptor;
  final _sharedPreferenceStorage = const FlutterSecureStorage();
  late File _databaseFile;
  late final AppLifecycleListener _listener;

  //* builds -----------------------------------------------------------------------------------------------------------------------------------------

  @override
  void initState() {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    _listener = AppLifecycleListener(
      onExitRequested: _handleExitRequest,
      onDetach: _handleOnDetach,
      onResume: _handleOnResume,
    );
    _onInitAsync();
    super.initState();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_asyncInit) {
      return const SizedBox(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(),
      );
    }

    return Builder(
      builder: (context) {
        var userData = ref.watch(userDataProvider);
        if (userData.username.isEmpty) {
          // go to login/register page
          return const AuthUserDataPage();
        }
        if (userData.username != _userData.username) {
          dbRead = false;
          _onUserChanged(userData);
        }
        if (!dbRead) {
          return const CircularProgressIndicator();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            titleTextStyle: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            title: Text(widget.title),
          ),
          drawer: _buildDrawer(context),
          body: _drawerItemProvider.getDrawerItemWidget(_selectedDrawerIndex),
        );
      },
    );
  }

  //* build helper -----------------------------------------------------------------------------------------------------------------------------------

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
              onDetailsPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ShowUserDataPage(),
                  ),
                );
              },
              accountName: Text(
                _userData.username,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              currentAccountPictureSize: const Size(50, 50),
              accountEmail: Text(
                _userData.email,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              currentAccountPicture: const CircleAvatar(
                radius: 3,
                backgroundImage: AssetImage('assets/images/User-icon-256-blue.png'),
              ),
            ),
          ),
          for (var index = 0; index < _drawerItemProvider.getDrawerItems.length; index++)
            ListTile(
              leading: Icon(_drawerItemProvider.getDrawerItems[index].icon),
              title: Text(
                _drawerItemProvider.getDrawerItems[index].title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              selected: index == _selectedDrawerIndex,
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = index;
                });
                Navigator.pop(context); // close drawer
              },
            ),
        ],
      ),
    );
  }

  //* callbacks --------------------------------------------------------------------------------------------------------------------------------------

  Future<void> _onUserChanged(UserData userData) async {
    try {
      // user changed
      await ref.read(diaryDayLocalDbDataProvider.notifier).changeUser(userData);
      await ref.read(notesLocalDataProvider.notifier).changeUser(userData);
      _userData = userData;
      setState(() {
        dbRead = true;
      });
    } on AssertionError catch (e) {
      setState(() {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(actions: const [], title: Text('${e.message}')),
        );
      });
    } catch (e) {
      setState(() {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(actions: const [], title: Text('unknown exception : $e')),
        );
      });
    }
  }

  Future<void> _onInitAsync() async {
    //* create encryptor
    var overallMap = await _sharedPreferenceStorage.readAll();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    var additionalDbFilePath = dotenv.env['LOCAL_DB_PATH'] ?? 'test.db';
    var additionalKeyFilePath = dotenv.env['LOCAL_APP_DIR'] ?? 'Test/';
    _databaseFile = File('${documentsDirectory.path}/$additionalDbFilePath');
    if (!overallMap.containsKey('password') || !overallMap.containsKey('iv')) {
      LogWrapper.logger.t('create new keyfile');
      _aesEncryptor = AesEncryptor(password: Utils.generateRandomString(100));
      await _sharedPreferenceStorage.write(key: 'iv', value: _aesEncryptor.iv);
      await _sharedPreferenceStorage.write(key: 'password', value: _aesEncryptor.password);
      overallMap['iv'] = _aesEncryptor.iv;
      overallMap['password'] = _aesEncryptor.password;
      File keyFile = File('${documentsDirectory.path}/$additionalKeyFilePath/DiaryKey.json');
      _aesEncryptor.saveToKeyFile(keyFile);
      LogWrapper.logger.i('saved key to "${keyFile.path}". Dont share this file');
    } else {
      LogWrapper.logger.t('uses saved aesEncryptor');
      _aesEncryptor = AesEncryptor(
        password: overallMap['password']!,
        ivAsBase64: overallMap['iv'],
      );
    }

    //* decrypt file
    try {
      _aesEncryptor.decryptFile(_databaseFile);
    } catch (e) {
      LogWrapper.logger.e('wasnt be able to decrypt file');
    }

    setState(() {
      _asyncInit = true;
    });
  }

  Future<AppExitResponse> _handleExitRequest() async {
    LogWrapper.logger.i('leaves app');
    try {
      _aesEncryptor.encryptFile(_databaseFile);
      LogWrapper.logger.t('decrypted database');
    } catch (e) {
      LogWrapper.logger.e('Error during encryption: $e');
    }
    return AppExitResponse.exit;
  }

  _handleOnDetach() {
    LogWrapper.logger.e('detached app');
  }

  void _handleOnResume() {
    LogWrapper.logger.e('resumes app');
  }
}
