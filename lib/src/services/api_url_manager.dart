import 'package:flutter/foundation.dart';
import '../constants/environment.dart';
import 'remote_config_service.dart';

/// Singleton que expone la URL base activa controlada por Firebase Remote Config.
/// Controlado desde Firebase Console con el boolean `use_primary_url`:
/// - `true`  → usa [Environment.urlBase]
/// - `false` → usa [Environment.urlBaseOld]
class ApiUrlManager {
  /// Instancia única de [ApiUrlManager] (patrón Singleton).
  ///
  /// Accede a través de este getter en lugar de crear instancias directamente:
  /// ```dart
  /// await ApiUrlManager.instance.initialize();
  /// final url = ApiUrlManager.instance.currentBaseUrl;
  /// ```
  static final ApiUrlManager instance = ApiUrlManager._();
  ApiUrlManager._();

  RemoteConfigService? _remoteConfigService;

  /// URL base activa según la configuración de Firebase Remote Config.
  ///
  /// Retorna [Environment.urlBase] cuando `use_primary_url` es `true` (por defecto),
  /// o [Environment.urlBaseOld] en caso contrario. Llama a [initialize] antes
  /// de usar esta propiedad para asegurarte de obtener el valor remoto.
  String get currentBaseUrl {
    final usePrimary = _remoteConfigService?.getUsePrimaryUrl() ?? true;
    return usePrimary
        ? Environment.instance.urlBase
        : Environment.instance.urlBaseOld;
  }

  bool get isUsingPrimaryUrl =>
      _remoteConfigService?.getUsePrimaryUrl() ?? true;

  /// Inicializa el servicio cargando la configuración desde Firebase Remote Config.
  ///
  /// Debe llamarse una vez al arrancar la app, típicamente en `main.dart`:
  /// ```dart
  /// await ApiUrlManager.instance.initialize();
  /// ```
  /// Si la inicialización falla, se usa la URL primaria como valor por defecto.
  Future<void> initialize() async {
    try {
      _remoteConfigService = await RemoteConfigService.getInstance();
      debugPrint('🌐 ApiUrlManager inicializado - URL activa: $currentBaseUrl');
    } catch (e) {
      debugPrint('🌐 ApiUrlManager - Error al inicializar: $e. Usando URL primaria.');
    }
  }
}
