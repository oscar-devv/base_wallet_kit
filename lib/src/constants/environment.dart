/// Clase abstracta que define las variables de entorno requeridas.
/// Cada proyecto debe crear su propia implementación concreta.
///
/// Ejemplo:
/// ```dart
/// class AppEnvironment extends Environment {
///   @override
///   String get urlBase => 'https://api.miapp.com/';
///
///   @override
///   String get urlBaseOld => 'https://api-legacy.miapp.com/';
/// }
/// ```
abstract class Environment {
  /// URL base principal de la API
  String get urlBase;

  /// URL base secundaria / fallback de la API
  String get urlBaseOld;

  /// Instancia global accesible desde cualquier parte de la app.
  /// Debe inicializarse en main() antes de ejecutar la app:
  /// ```dart
  /// Environment.instance = AppEnvironment();
  /// ```
  static late Environment instance;
}
