import 'package:dio/dio.dart';

/// Datasource base con manejo de errores centralizado.
/// Todos los datasources del proyecto deben extender esta clase.
///
/// ```dart
/// class LoginDatasource extends BaseDatasource {
///   LoginDatasource() : super(dio: ApiDioFactory.create());
///
///   Future<LoginModel> login(String email, String password) async {
///     final response = await safeRequest(() => dio.post(
///       '/v1/auth/login/',
///       data: {'email': email, 'password': password},
///     ));
///     return LoginModel.fromJson(response.data);
///   }
/// }
/// ```
abstract class BaseDatasource {
  final Dio dio;

  BaseDatasource({required this.dio});

  /// Ejecuta una petición HTTP con manejo de errores centralizado.
  /// Lanza [DatasourceException] si la petición falla.
  Future<Response> safeRequest(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response;
    } on DioException catch (e) {
      throw DatasourceException(
        message: e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      throw DatasourceException(message: e.toString());
    }
  }
}

/// Excepción lanzada por los datasources cuando ocurre un error.
class DatasourceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  DatasourceException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() =>
      'DatasourceException: $message (status: $statusCode)';
}
