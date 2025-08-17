import 'dart:convert'; // For base64 encoding/decoding
import 'package:encrypt/encrypt.dart' as encrypt; // AES encryption library
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure key storage

/// EncryptionService handles AES encryption/decryption
/// and secure key management using flutter_secure_storage.
class EncryptionService {
  // Secure storage instance for saving the AES key
  static final _storage = FlutterSecureStorage();

  // Key to store the encryption key in secure storage
  static const _keyStorageKey = 'encryption_key';

  /// Retrieves the AES key.
  /// Generates and stores a new 256-bit key if none exists.
  static Future<encrypt.Key> _getKey() async {
    String? key = await _storage.read(key: _keyStorageKey);

    if (key == null) {
      // Generate a secure random 256-bit (32-byte) AES key
      final newKey = encrypt.Key.fromSecureRandom(32);

      // Store the key as a Base64 URL-safe string
      await _storage.write(
        key: _keyStorageKey,
        value: base64UrlEncode(newKey.bytes),
      );

      return newKey;
    }

    // Decode and return the existing key
    return encrypt.Key(base64Url.decode(key));
  }

  /// Encrypts the [plainText] using AES-256 encryption.
  /// Returns a string formatted as: Base64(IV):Base64(CipherText)
  static Future<String> encryptText(String plainText) async {
    final key = await _getKey();
    final iv = encrypt.IV.fromSecureRandom(16); // 128-bit IV (required for AES)
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Return a formatted string: IV + CipherText
    return '${base64UrlEncode(iv.bytes)}:${encrypted.base64}';
  }

  /// Decrypts the [encryptedText] back to plain text.
  /// Expects the format: Base64(IV):Base64(CipherText)
  static Future<String> decryptText(String encryptedText) async {
    final key = await _getKey();

    // Split the string to extract IV and CipherText
    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid encrypted text format.');
    }

    final iv = encrypt.IV(base64Url.decode(parts[0]));
    final encrypted = encrypt.Encrypted(base64.decode(parts[1]));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.decrypt(encrypted, iv: iv);
  }
}
