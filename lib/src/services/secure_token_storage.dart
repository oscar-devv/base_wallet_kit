import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Almacena y recupera tokens de autenticación de forma segura usando Keychain (iOS)
/// y EncryptedSharedPreferences (Android).
class SecureTokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _keyAuthToken = 'secure_auth_token';
  static const String _keyBalanceToken = 'secure_balance_token';

  static Future<void> saveAuthToken(String token) async {
    if (token.isEmpty) return;
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      if (kDebugMode) debugPrint('🔐 Auth token guardado');
    } catch (e) {
      throw Exception('Error guardando auth token: $e');
    }
  }

  static Future<void> saveBalanceToken(String token) async {
    if (token.isEmpty) return;
    try {
      await _storage.write(key: _keyBalanceToken, value: token);
      if (kDebugMode) debugPrint('🔐 Balance token guardado');
    } catch (e) {
      throw Exception('Error guardando balance token: $e');
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      final token = await _storage.read(key: _keyAuthToken);
      return token?.isNotEmpty == true ? token : null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getBalanceToken() async {
    try {
      final token = await _storage.read(key: _keyBalanceToken);
      return token?.isNotEmpty == true ? token : null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateBalanceToken(String newToken) async =>
      saveBalanceToken(newToken);

  static Future<void> clearAllTokens() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyBalanceToken);
      if (kDebugMode) debugPrint('🔐 Tokens eliminados');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error eliminando tokens: $e');
    }
  }

  static Future<bool> hasTokens() async {
    try {
      final auth = await _storage.read(key: _keyAuthToken);
      final balance = await _storage.read(key: _keyBalanceToken);
      return (auth?.isNotEmpty ?? false) || (balance?.isNotEmpty ?? false);
    } catch (e) {
      return false;
    }
  }
}
