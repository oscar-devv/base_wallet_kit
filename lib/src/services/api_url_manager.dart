import 'package:flutter/foundation.dart';
import '../constants/environment.dart';
import 'remote_config_service.dart';

/// Singleton que expone la URL base activa controlada por Firebase Remote Config.
/// Controlado desde Firebase Console con el boolean `use_primary_url`:
/// - `true`  → usa [Environment.urlBase]
/// - `false` → usa [Environment.urlBaseOld]
class ApiUrlManager {
  static final ApiUrlManager instance = ApiUrlManager._();
  ApiUrlManager._();

  RemoteConfigService? _remoteConfigService;

  String get currentBaseUrl {
    final usePrimary = _remoteConfigService?.getUsePrimaryUrl() ?? true;
    return usePrimary
        ? Environment.instance.urlBase
        : Environment.instance.urlBaseOld;
  }

  bool get isUsingPrimaryUrl =>
      _remoteConfigService?.getUsePrimaryUrl() ?? true;

  Future<void> initialize() async {
    try {
      _remoteConfigService = await RemoteConfigService.getInstance();
      debugPrint('🌐 ApiUrlManager inicializado - URL activa: $currentBaseUrl');
    } catch (e) {
      debugPrint('🌐 ApiUrlManager - Error al inicializar: $e. Usando URL primaria.');
    }
  }
}
