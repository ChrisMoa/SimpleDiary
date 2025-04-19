import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AesEncryptor {
  //* constructors -----------------------------------------------------------------------------------------------------------------------------------

  AesEncryptor({required this.password}) {
    _key = Key.fromBase64(base64Encode(sha256.convert(utf8.encode(password)).bytes));
    _encrypter = Encrypter(AES(_key, mode: _aesMode));
    _stringDefaultIV = IV.fromBase64("13572468");
  }

  //* public methods ---------------------------------------------------------------------------------------------------------------------------------

  /// encrypts the given plain text
  /// [plainText] the plainText that should be encrypted
  /// [return] the encrypted cipherText as byte array
  Uint8List encryptString(String plainText) {
    return _encrypter.encrypt(plainText, iv: _stringDefaultIV).bytes;
  }

  /// encrypts the given plain text
  /// [plainText] the plainText that should be encrypted
  /// [return] the encrypted cipherText as base64String
  String encryptStringAsBase64(String plainText) {
    return base64.encode(encryptString(plainText));
  }

  /// decrypts the given plain ciptherText
  /// [cipherText] the cipherText that should be decrypted as byte array
  /// [return] the decrypted plainText as String
  String decryptString(Uint8List cipherText) {
    return _encrypter.decrypt(Encrypted(cipherText), iv: _stringDefaultIV);
  }

  /// decrypts the given plain ciptherText
  /// [cipherText] the cipherText that should be decrypted as byte array
  /// [return] the decrypted plainText as String
  String decryptStringFromBase64(String cipherText) {
    return _encrypter.decrypt(Encrypted(base64.decode(cipherText)), iv: _stringDefaultIV);
  }

  /// encrypts the given file
  /// [file] the file that should be encrypted
  /// [return] void
  void encryptFile(File file) {
    // Read the file as bytes
    Uint8List fileBytes = Uint8List.fromList(file.readAsBytesSync());

    // Generate a random IV (Initialization Vector)
    IV iv = IV.fromLength(16);

    // Encrypt the file using AES in CBC mode
    Encrypted encrypted = _encrypter.encryptBytes(fileBytes, iv: iv);

    // Save the IV and encrypted data to a new file
    Uint8List encryptedFileBytes = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    file.writeAsBytesSync(encryptedFileBytes);
  }

  /// decrypts the given file
  /// [file] the file that should be encrypted
  /// [return] void
  void decryptFile(File file) {
    // Read the encrypted file as bytes
    Uint8List encryptedFileBytesRead = Uint8List.fromList(file.readAsBytesSync());

    // Extract the IV from the encrypted file
    IV ivRead = IV(Uint8List.fromList(encryptedFileBytesRead.sublist(0, 16).cast<int>()));

    // Extract the encrypted data from the encrypted file
    Uint8List encryptedDataRead = encryptedFileBytesRead.sublist(16);

    // Decrypt the data
    Uint8List decryptedBytes = Uint8List.fromList(_encrypter.decryptBytes(Encrypted(encryptedDataRead), iv: ivRead));

    // Save the decrypted data to a new file
    file.writeAsBytesSync(decryptedBytes);
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
  late Key _key; //! the key for aes encryption
  late Encrypter _encrypter; //! the aes encryption module
  final _aesMode = AESMode.ctr; //! the aes encryption mode
  late IV _stringDefaultIV; //! the default iv for string encryption
}

