import 'dart:io';
import 'dart:ui';

import 'package:day_tracker/core/authentication/password_auth_service.dart';
import 'package:day_tracker/core/encryption/aes_encryptor.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/core/navigation/drawer_item_builder.dart';
import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/authentication/data/models/user_data.dart';
import 'package:day_tracker/features/authentication/domain/providers/user_data_provider.dart';
import 'package:day_tracker/features/authentication/presentation/pages/auth_user_data_page.dart';
import 'package:day_tracker/features/authentication/presentation/pages/password_authentication_page.dart';
import 'package:day_tracker/features/authentication/presentation/pages/show_user_data_page.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/note_templates/domain/providers/note_template_local_db_provider.dart';
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
        } else if (userData.username.isNotEmpty && !userData.isLoggedIn) {
          // go to login/register page
          LogWrapper.logger.t('changed to PinAuthenticationPage');
          return const PasswordAuthenticationPage();
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
      await _decryptDatabase(_userData, userData);

      // user changed
      await ref.read(diaryDayLocalDbDataProvider.notifier).changeUser(userData);
      await ref.read(notesLocalDataProvider.notifier).changeUser(userData);

      // Initialize template database for the user
      LogWrapper.logger.d('Initializing templates for user ${userData.username}');
      await ref.read(noteTemplateLocalDataProvider.notifier).changeDbFileToUser(userData);
      await ref.read(noteTemplateLocalDataProvider.notifier).readObjectsFromDatabase();

      _userData = userData;
      setState(() {
        dbRead = true;
      });
    } on AssertionError catch (e) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(actions: const [], title: Text('${e.message}')),
      );
    } catch (e) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(actions: const [], title: Text('unknown exception : $e')),
      );
    }
  }

  Future<void> _decryptDatabase(UserData oldUserData, UserData newUserData) async {
    // Encrypt old database if we have a valid user
    if (oldUserData.username.isNotEmpty && oldUserData.clearPassword.isNotEmpty) {
      try {
        LogWrapper.logger.i('Generating encryption key for user ${oldUserData.username}');
        String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(oldUserData.clearPassword, oldUserData.salt);

        if (encryptionKey.isNotEmpty) {
          var aesEncryptor = AesEncryptor(encryptionKey: encryptionKey);

          // Encrypt notes database
          File notesFile = ref.read(notesLocalDataProvider.notifier).dbFile;
          if (notesFile.existsSync() && notesFile.lengthSync() > 0) {
            LogWrapper.logger.d('Encrypting notes database for user ${oldUserData.userId}');
            aesEncryptor.encryptFile(notesFile);
            LogWrapper.logger.d('Notes database encrypted successfully');
          }

          // Encrypt templates database
          File templatesFile = ref.read(noteTemplateLocalDataProvider.notifier).dbFile;
          if (templatesFile.existsSync() && templatesFile.lengthSync() > 0) {
            LogWrapper.logger.d('Encrypting templates database for user ${oldUserData.userId}');
            aesEncryptor.encryptFile(templatesFile);
            LogWrapper.logger.d('Templates database encrypted successfully');
          }
        } else {
          LogWrapper.logger.e('Empty encryption key generated for ${oldUserData.username}');
        }
      } catch (e) {
        LogWrapper.logger.e('Error during encrypting database for user ${oldUserData.userId}: $e');
      }
    } else {
      LogWrapper.logger.d('No valid user credentials for encryption');
    }

    // Decrypt new database if we have a valid user
    if (newUserData.username.isNotEmpty && newUserData.clearPassword.isNotEmpty) {
      try {
        LogWrapper.logger.i('Generating decryption key for user ${newUserData.username}');
        String encryptionKey = PasswordAuthService.getDatabaseEncryptionKey(newUserData.clearPassword, newUserData.salt);

        if (encryptionKey.isNotEmpty) {
          // Change database file to new user
          ref.read(notesLocalDataProvider.notifier).changeDbFileToUser(newUserData);
          ref.read(noteTemplateLocalDataProvider.notifier).changeDbFileToUser(newUserData);

          // Decrypt notes database
          File notesFile = ref.read(notesLocalDataProvider.notifier).dbFile;
          if (notesFile.existsSync() && notesFile.lengthSync() > 0) {
            LogWrapper.logger.d('Decrypting notes database for user ${newUserData.userId}');
            var aesEncryptor = AesEncryptor(encryptionKey: encryptionKey);
            aesEncryptor.decryptFile(notesFile);
            LogWrapper.logger.d('Notes database decrypted successfully');
          }

          // Decrypt templates database
          File templatesFile = ref.read(noteTemplateLocalDataProvider.notifier).dbFile;
          if (templatesFile.existsSync() && templatesFile.lengthSync() > 0) {
            LogWrapper.logger.d('Decrypting templates database for user ${newUserData.userId}');
            var aesEncryptor = AesEncryptor(encryptionKey: encryptionKey);
            aesEncryptor.decryptFile(templatesFile);
            LogWrapper.logger.d('Templates database decrypted successfully');
          } else {
            LogWrapper.logger.w('Templates database file empty or does not exist - no decryption needed');
          }
        } else {
          LogWrapper.logger.e('Empty decryption key generated for ${newUserData.username}');
        }
      } catch (e) {
        LogWrapper.logger.e('Error during decrypting database for user ${newUserData.userId}: $e');
      }
    } else {
      LogWrapper.logger.d('No valid user credentials for decryption');
    }
  }

  Future<void> _onInitAsync() async {
    setState(() {
      _asyncInit = true;
    });
  }

  Future<AppExitResponse> _handleExitRequest() async {
    LogWrapper.logger.i('leaves app');
    await _decryptDatabase(_userData, UserData.fromEmpty());
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
