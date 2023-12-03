import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:SimpleDiary/provider/user/user_data_provider.dart';
import 'package:SimpleDiary/services/database_services/firestore_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remoteUserLoginProvider = Provider<Future<String>>(
  (ref) async {
    final userData = ref.watch(userDataProvider);
    if (!userData.isRemoteUser) {
      return '';
    }

    String str = await FirestoreAPI.signInWithEmailPassword(apiKey: dotenv.env['FIRESTORE_API_KEY'] ?? '', email: userData.email, password: userData.password);
    if (str.length >= 10) {
      LogWrapper.logger.t('userLoginProvider: ${str.substring(0, 5)}...${str.substring(str.length - 5, str.length)}');
    } else {
      LogWrapper.logger.t('userLoginProvider');
    }
    return str;
  },
);
