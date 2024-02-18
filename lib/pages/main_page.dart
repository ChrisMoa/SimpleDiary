import 'dart:io';
import 'dart:ui';

import 'package:SimpleDiary/model/Settings/settings_container.dart';
import 'package:SimpleDiary/model/encryption/aes_encryptor.dart';
import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/model/user/user_data.dart';
import 'package:SimpleDiary/pages/auth/auth_user_data_page.dart';
import 'package:SimpleDiary/pages/auth/pin_authentication_page.dart';
import 'package:SimpleDiary/pages/auth/show_user_data_page.dart';
import 'package:SimpleDiary/provider/database%20provider/diary_day_local_db_provider.dart';
import 'package:SimpleDiary/provider/database%20provider/note_local_db_provider.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:SimpleDiary/services/drawer_item_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          LogWrapper.logger.t('changed to authUserDataPage');
          return const AuthUserDataPage();
        }
        if (userData.username.isNotEmpty && !userData.isLoggedIn) {
          // go to login/register page
          LogWrapper.logger.t('changed to PinAuthenticationPage');
          return const PinAuthenticationPage();
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            titleTextStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
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
                color: Theme.of(context).colorScheme.secondaryContainer,
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
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              currentAccountPictureSize: const Size(50, 50),
              accountEmail: Text(
                _userData.email,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
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
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
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
      _decryptDatabase(_userData, userData);

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

  Future<void> _decryptDatabase(UserData oldUserData, UserData newUserData) async {
    // encrypt old database
    if (oldUserData.username.isNotEmpty) {
      var aesEncryptor = AesEncryptor(password: oldUserData.password);
      File file = ref.read(notesLocalDataProvider.notifier).dbFile;
      LogWrapper.logger.d('encrypts the database of user ${oldUserData.userId}');
      try {
        aesEncryptor.encryptFile(file); // only one database file has to be encrypted as the databases uses the same file
      } catch (e) {
        LogWrapper.logger.e('error during decrypting file of user ${oldUserData.userId}: $e');
      }
    }

    // decrypt new database
    if (newUserData.username.isNotEmpty) {
      try {
        var aesEncryptor = AesEncryptor(password: newUserData.password);
        ref.read(notesLocalDataProvider.notifier).changeDbFileToUser(newUserData);
        File file = ref.read(notesLocalDataProvider.notifier).dbFile;
        LogWrapper.logger.d('decrypts the database of user ${newUserData.userId}');
        aesEncryptor.decryptFile(file); // only one database file has to be encrypted as the databases uses the same file
      } catch (e) {
        LogWrapper.logger.e('error during decrypting file of user ${newUserData.userId}: $e');
      }
    }
  }

  Future<void> _onInitAsync() async {
    setState(() {
      _asyncInit = true;
    });
  }

  Future<AppExitResponse> _handleExitRequest() async {
    LogWrapper.logger.i('leaves app');
    _decryptDatabase(_userData, UserData.fromEmpty());
    settingsContainer.saveSettings();
    return AppExitResponse.exit;
  }

  _handleOnDetach() {
    LogWrapper.logger.d('detached app');
  }

  void _handleOnResume() {
    LogWrapper.logger.d('resumes app');
  }
}
