import 'package:flutter/material.dart';

/// GlobalKey del navegador raíz. Úsalo en tu GoRouter y pásalo
/// a [BaseWalletKit.init] para que los interceptores puedan navegar.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Clase de configuración central de la librería.
/// Inicializar en main() antes de runApp().
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   BaseWalletKit.init(
///     navigatorKey: rootNavigatorKey,
///     loginRoute: '/login',
///   );
///   runApp(MyApp());
/// }
/// ```
class BaseWalletKit {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static String _loginRoute = '/login';
  static List<String> _authenticatedRoutes = [];
  static List<String> _authRoutes = [];

  /// Inicializa la librería con la configuración del proyecto.
  static void init({
    required GlobalKey<NavigatorState> navigatorKey,
    String loginRoute = '/login',
    List<String> authenticatedRoutes = const [],
    List<String> authRoutes = const [],
  }) {
    _navigatorKey = navigatorKey;
    _loginRoute = loginRoute;
    _authenticatedRoutes = authenticatedRoutes;
    _authRoutes = authRoutes;
  }

  static GlobalKey<NavigatorState> get navigatorKey {
    assert(_navigatorKey != null,
        'BaseWalletKit no fue inicializado. Llama BaseWalletKit.init() en main().');
    return _navigatorKey!;
  }

  static String get loginRoute => _loginRoute;
  static List<String> get authenticatedRoutes => _authenticatedRoutes;
  static List<String> get authRoutes => _authRoutes;
}
