import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:encrypt/encrypt.dart';

class AesEncryptor {
  //* constructors -----------------------------------------------------------------------------------------------------------------------------------

  AesEncryptor({required this.encryptionKey}) {
    try {
      // Ensure the key is properly formatted for AES
      // AES requires exactly 16, 24, or 32 bytes for 128, 192, or 256-bit encryption
      final keyBytes = base64.decode(encryptionKey);
      // We'll use the first 32 bytes for 256-bit AES
      final validKeyBytes = keyBytes.length >= 32
          ? keyBytes.sublist(0, 32)
          : _padKey(keyBytes, 32);

      _key = Key(validKeyBytes);
      _encrypter = Encrypter(AES(_key, mode: _aesMode));
      _stringDefaultIV = IV.fromLength(16); // Use a standard IV length
      LogWrapper.logger.d('AES encryptor initialized successfully');
    } catch (e) {
      LogWrapper.logger.e('Error initializing AES encryptor: $e');
      rethrow;
    }
  }

  // Pad the key to the required length if needed
  Uint8List _padKey(Uint8List key, int targetLength) {
    if (key.length >= targetLength) return key.sublist(0, targetLength);

    Uint8List paddedKey = Uint8List(targetLength);
    paddedKey.setAll(0, key);
    // Fill remaining bytes with a derivation of existing key bytes
    for (int i = key.length; i < targetLength; i++) {
      paddedKey[i] = key[i % key.length];
    }
    return paddedKey;
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
  /// [return] the encrypted cipherText as base64String (includes IV)
  String encryptStringAsBase64(String plainText) {
    // Generate a random IV for each encryption
    IV iv = IV.fromLength(16);
    
    // Encrypt the data
    Encrypted encrypted = _encrypter.encrypt(plainText, iv: iv);
    
    // Combine IV and encrypted data, then encode as base64
    Uint8List combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64.encode(combined);
  }

  /// decrypts the given plain ciptherText
  /// [cipherText] the cipherText that should be decrypted as byte array
  /// [return] the decrypted plainText as String
  String decryptString(Uint8List cipherText) {
    return _encrypter.decrypt(Encrypted(cipherText), iv: _stringDefaultIV);
  }

  /// decrypts the given plain ciptherText from base64 (expects IV prepended)
  /// [cipherText] the cipherText as base64 string (IV + encrypted data)
  /// [return] the decrypted plainText as String
  String decryptStringFromBase64(String cipherTextBase64) {
    // Decode from base64
    Uint8List combined = base64.decode(cipherTextBase64);
    
    // Verify we have enough data (at least 16 bytes for IV)
    if (combined.length <= 16) {
      throw Exception('Invalid encrypted data: too short');
    }
    
    // Extract IV (first 16 bytes)
    IV iv = IV(Uint8List.fromList(combined.sublist(0, 16)));
    
    // Extract encrypted data (rest of the bytes)
    Uint8List encryptedData = combined.sublist(16);
    
    // Decrypt
    return _encrypter.decrypt(Encrypted(encryptedData), iv: iv);
  }

  /// encrypts the given file
  /// [file] the file that should be encrypted
  /// [return] void
  void encryptFile(File file) {
    try {
      LogWrapper.logger.d('Beginning file encryption');
      // Read the file as bytes
      Uint8List fileBytes = Uint8List.fromList(file.readAsBytesSync());
      LogWrapper.logger.d('Read ${fileBytes.length} bytes from file');

      // Generate a random IV (Initialization Vector)
      IV iv = IV.fromLength(16);
      LogWrapper.logger.d('Generated IV for encryption');

      // Encrypt the file using AES
      Encrypted encrypted = _encrypter.encryptBytes(fileBytes, iv: iv);
      LogWrapper.logger.d('File content encrypted successfully');

      // Save the IV and encrypted data to a new file
      Uint8List encryptedFileBytes =
          Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
      file.writeAsBytesSync(encryptedFileBytes);
      LogWrapper.logger.d('Encrypted file saved successfully');
    } catch (e) {
      LogWrapper.logger.e('Error during file encryption: $e');
      rethrow;
    }
  }

  /// decrypts the given file
  /// [file] the file that should be encrypted
  /// [return] void
  void decryptFile(File file) {
    try {
      LogWrapper.logger.d('Beginning file decryption');
      // Read the encrypted file as bytes
      Uint8List encryptedFileBytesRead =
          Uint8List.fromList(file.readAsBytesSync());
      LogWrapper.logger
          .d('Read ${encryptedFileBytesRead.length} bytes from encrypted file');

      // Verify file has enough bytes for IV and content
      if (encryptedFileBytesRead.length <= 16) {
        LogWrapper.logger
            .e('File too small to contain IV and encrypted content');
        throw Exception('Invalid encrypted file format');
      }

      // Extract the IV from the encrypted file
      IV ivRead = IV(Uint8List.fromList(encryptedFileBytesRead.sublist(0, 16)));
      LogWrapper.logger.d('Extracted IV from file');

      // Extract the encrypted data from the encrypted file
      Uint8List encryptedDataRead = encryptedFileBytesRead.sublist(16);
      LogWrapper.logger
          .d('Extracted ${encryptedDataRead.length} bytes of encrypted data');

      // Decrypt the data
      Uint8List decryptedBytes = Uint8List.fromList(
          _encrypter.decryptBytes(Encrypted(encryptedDataRead), iv: ivRead));
      LogWrapper.logger
          .d('Data decrypted successfully, ${decryptedBytes.length} bytes');

      // Save the decrypted data to the file
      file.writeAsBytesSync(decryptedBytes);
      LogWrapper.logger.d('Decrypted file saved successfully');
    } catch (e) {
      LogWrapper.logger.e('Error during file decryption: $e');
      rethrow;
    }
  }

  //* public parameters ------------------------------------------------------------------------------------------------------------------------------

  final String encryptionKey; // The database encryption key

  //* private parameters -----------------------------------------------------------------------------------------------------------------------------
  late Key _key; // The key for aes encryption
  late Encrypter _encrypter; // The aes encryption module
  final _aesMode = AESMode.cbc; // Using CBC mode for better security
  late IV _stringDefaultIV; // The default iv for string encryption
}
