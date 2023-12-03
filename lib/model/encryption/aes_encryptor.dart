import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:SimpleDiary/model/log/logger_instance.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AesEncryptor {
  //* constructors -----------------------------------------------------------------------------------------------------------------------------------

  AesEncryptor({required this.password, String? ivAsBase64}) {
    ivAsBase64 == null ? _iv = IV.fromLength(16) : _iv = IV.fromBase64(ivAsBase64);
    _key = Key.fromBase64(base64Encode(sha256.convert(utf8.encode(password)).bytes));
    _encrypter = Encrypter(AES(_key, mode: _aesMode));
  }

  factory AesEncryptor.loadFromKeyFile(File file) {
    Map<String, dynamic> map = jsonDecode(file.readAsStringSync());
    assert(map.containsKey('password'), '${file.path} has no password');
    assert(map.containsKey('iv'), '${file.path} has no iv');
    return AesEncryptor(password: map['password'], ivAsBase64: map['iv']);
  }

  //* public methods ---------------------------------------------------------------------------------------------------------------------------------

  /// get the iv for aes encryption as a base64-String
  String get iv {
    return _iv.base64;
  }

  /// saves the passwrod and iv to the given filePath
  /// [file] the file where the credentials will be written
  void saveToKeyFile(File file) {
    Map<String, String> map = {};
    map['password'] = password;
    map['iv'] = _iv.base64;
    file.writeAsStringSync(jsonEncode(map));
  }

  /// encrypts the given plain text
  /// [plainText] the plainText that should be encrypted
  /// [return] the encrypted cipherText as byte array
  Uint8List encryptString(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).bytes;
  }

  /// decrypts the given plain ciptherText
  /// [cipherText] the cipherText that should be decrypted as byte array
  /// [return] the decrypted plainText as String
  String decryptString(Uint8List cipherText) {
    return _encrypter.decrypt(Encrypted(cipherText), iv: _iv);
  }

  /// encrypts the given file
  /// [file] the file that should be encrypted
  /// [return] void
  void encryptFile(File file) {
    LogWrapper.logger.t('encrypt file: ${file.path}');
    file.writeAsBytesSync(_encrypter.encryptBytes(file.readAsBytesSync(), iv: _iv).bytes);
  }

  /// decrypts the given file
  /// [file] the file that should be encrypted
  /// [return] void
  void decryptFile(File file) {
    LogWrapper.logger.t('decrypt file: ${file.path}');
    file.writeAsBytesSync(_encrypter.decryptBytes(Encrypted(file.readAsBytesSync()), iv: _iv));
  }

  /// encrypts the given folder
  /// [folder] the directory that should be encrypted
  /// [recursively] if true all subdirectories of the directory will be encrypted, default is true
  /// [return] void
  void encryptFolder(Directory folder, [bool? recursively]) {
    var tmpRecursively = recursively ?? true;
    for (var file in folder.listSync(recursive: tmpRecursively).whereType<File>().toList()) {
      encryptFile(File(file.path));
    }
  }

  /// decrypts the given folder
  /// [folder] the directory that should be encrypted
  /// [recursively] if true all subdirectories of the directory will be decrypted, default is true
  /// [return] void
  void decryptFolder(Directory folder, [bool? recursively]) {
    var tmpRecursively = recursively ?? true;
    for (var file in folder.listSync(recursive: tmpRecursively).whereType<File>().toList()) {
      decryptFile(File(file.path));
    }
  }

  //* public parameters ------------------------------------------------------------------------------------------------------------------------------

  final String password; //! the password that is applied as aes key

  //* private methods --------------------------------------------------------------------------------------------------------------------------------

  //* private parameters -----------------------------------------------------------------------------------------------------------------------------

  late IV _iv; //! the iv for aes encryption
  late Key _key; //! the key for aes encryption
  late Encrypter _encrypter; //! the aes encryption module
  final _aesMode = AESMode.ctr; //! the aes encryption mode
}
