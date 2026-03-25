import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacena y recupera credenciales (email/password) de forma segura.
/// Usa Keychain en iOS y EncryptedSharedPreferences en Android.
class SecureCredentials {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _keyEmail = 'biometric_email';
  static const String _keyPassword = 'biometric_password';

  static Future<void> save(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return;
    try {
      await _storage.write(key: _keyEmail, value: email);
      await _storage.write(key: _keyPassword, value: password);
    } catch (e) {
      throw Exception('Error guardando credenciales: $e');
    }
  }

  static Future<({String email, String password})?> read() async {
    try {
      final email = await _storage.read(key: _keyEmail) ?? '';
      final password = await _storage.read(key: _keyPassword) ?? '';
      if (email.isEmpty || password.isEmpty) return null;
      return (email: email, password: password);
    } catch (e) {
      throw Exception('Error leyendo credenciales: $e');
    }
  }

  static Future<void> clear() async {
    try {
      await _storage.delete(key: _keyEmail);
      await _storage.delete(key: _keyPassword);
    } catch (e) {
      throw Exception('Error limpiando credenciales: $e');
    }
  }

  static Future<bool> hasCredentials() async {
    try {
      final email = await _storage.read(key: _keyEmail);
      final password = await _storage.read(key: _keyPassword);
      return email != null && email.isNotEmpty &&
             password != null && password.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
