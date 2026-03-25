import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/router/base_router.dart';

/// Servicio para manejar el estado de navegación y evitar loops de redirección.
class NavigationStateService {
  static final NavigationStateService _instance =
      NavigationStateService._internal();
  factory NavigationStateService() => _instance;
  NavigationStateService._internal();

  static const String _currentRouteKey = 'current_route';
  static const String _appSessionKey = 'app_session_id';

  Future<bool> canPerformAutomaticNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentSessionId = _generateSessionId();
      final lastSessionId = prefs.getString(_appSessionKey);

      if (lastSessionId != currentSessionId) {
        await prefs.setString(_appSessionKey, currentSessionId);
        return true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_${(timestamp % 1000).toString().padLeft(3, '0')}';
  }

  Future<void> recordAutomaticNavigation(String routeName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentRouteKey, routeName);
      if (kDebugMode) debugPrint('✅ NavigationStateService: registrada ruta $routeName');
    } catch (_) {}
  }

  Future<String?> getCurrentRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currentRouteKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentRouteKey);
      await prefs.remove(_appSessionKey);
    } catch (_) {}
  }

  Future<void> initializeOnAppStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_appSessionKey);
      await prefs.remove(_currentRouteKey);
    } catch (_) {}
  }

  /// Verifica si la ruta es autenticada usando las rutas configuradas en [BaseWalletKit.init]
  bool isAuthenticatedRoute(String routeName) =>
      BaseWalletKit.authenticatedRoutes.any((r) => routeName.contains(r));

  /// Verifica si la ruta es de login/registro usando las rutas configuradas en [BaseWalletKit.init]
  bool isLoginOrRegistrationRoute(String routeName) =>
      BaseWalletKit.authRoutes.any((r) => routeName.contains(r));
}
