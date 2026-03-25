// ignore_for_file: constant_identifier_names, avoid_print
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la versión de la app para evitar datos corruptos entre actualizaciones.
/// No borra datos — solo registra la versión actual.
///
/// Para iOS: los datos persisten entre actualizaciones (SharedPreferences y Keychain).
/// La limpieza del Keychain solo ocurre en primera instalación/reinstalación,
/// controlada por el flag `app_initialized` (ver login screen).
class MigrationManager {
  static const String APP_VERSION_KEY = 'app_version';
  static const String USER_DATA_KEY = 'stringListUser';

  /// Versión actual de iOS (App Store)
  static String iosVersion = '1.0.0';

  /// Versión actual de Android (Play Store)
  static String androidVersion = '1.0.0';

  /// Configura las versiones antes de llamar [checkAppVersion].
  /// Llamar desde main() antes de runApp().
  static void configure({
    required String ios,
    required String android,
  }) {
    iosVersion = ios;
    androidVersion = android;
  }

  static Future<void> checkAppVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedVersion = prefs.getString(APP_VERSION_KEY);
      final String currentVersion =
          Platform.isIOS ? iosVersion : androidVersion;

      if (kDebugMode) {
        print('Versión almacenada: $storedVersion');
        print('Versión actual: $currentVersion');
        print('Plataforma: ${Platform.isIOS ? 'iOS' : 'Android'}');
      }

      if (storedVersion != currentVersion) {
        if (kDebugMode) print('Nueva versión detectada. Actualizando...');
        await prefs.setString(APP_VERSION_KEY, currentVersion);
      }
    } catch (e) {
      if (kDebugMode) print('Error en checkAppVersion: $e');
    }
  }
}
