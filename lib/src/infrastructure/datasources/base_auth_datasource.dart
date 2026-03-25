import 'base_datasource.dart';

/// Datasource base para operaciones de autenticación.
/// Extiende [BaseDatasource] y define el contrato de auth.
///
/// ```dart
/// class AuthDatasource extends BaseAuthDatasource {
///   AuthDatasource() : super(dio: ApiDioFactory.create());
///
///   @override
///   Future<Map<String, dynamic>> login(String email, String password) async {
///     final response = await safeRequest(() => dio.post(
///       '/v1/auth/login/',
///       data: {'email': email, 'password': password},
///     ));
///     return response.data;
///   }
///
///   @override
///   Future<void> logout(String token) async {
///     await safeRequest(() => dio.post('/v1/auth/logout/'));
///   }
/// }
/// ```
abstract class BaseAuthDatasource extends BaseDatasource {
  BaseAuthDatasource({required super.dio});

  /// Realiza el login y retorna los datos del usuario/tokens
  Future<Map<String, dynamic>> login(String email, String password);

  /// Realiza el logout
  Future<void> logout(String token);
}
