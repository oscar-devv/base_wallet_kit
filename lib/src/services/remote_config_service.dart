import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Servicio para Firebase Remote Config.
/// Centraliza el acceso a los feature flags y configuración remota.
class RemoteConfigService {
  static RemoteConfigService? _instance;
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService._(this._remoteConfig);

  static Future<RemoteConfigService> getInstance() async {
    if (_instance != null) return _instance!;
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
    _instance = RemoteConfigService._(remoteConfig);
    return _instance!;
  }

  /// `true` → URL primaria, `false` → URL secundaria/fallback
  bool getUsePrimaryUrl() {
    try {
      return _remoteConfig.getBool('use_primary_url');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ RemoteConfig: error leyendo use_primary_url: $e');
      return true;
    }
  }

  /// Lee un boolean de Remote Config con fallback
  bool getBool(String key, {bool fallback = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      return fallback;
    }
  }

  /// Lee un string de Remote Config con fallback
  String getString(String key, {String fallback = ''}) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      return fallback;
    }
  }

  /// Lee un int de Remote Config con fallback
  int getInt(String key, {int fallback = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      return fallback;
    }
  }
}
