import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de autenticación biométrica.
class BiometricPreferences {
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyAppInitialized = 'app_initialized';

  static Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyBiometricEnabled) ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricEnabled, enabled);
    } catch (e) {
      throw Exception('Error guardando preferencia biométrica: $e');
    }
  }

  static Future<void> enable() async => setEnabled(true);
  static Future<void> disable() async => setEnabled(false);

  static Future<bool> toggle() async {
    final current = await isEnabled();
    await setEnabled(!current);
    return !current;
  }

  /// Verifica si la app fue inicializada (flag para limpieza de Keychain en iOS)
  static Future<bool> isAppInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyAppInitialized) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Marca la app como inicializada (primera vez que corre tras instalar)
  static Future<void> markAppAsInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAppInitialized, true);
    } catch (_) {}
  }
}
