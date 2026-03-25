import 'package:dio/dio.dart';
import 'crashlytics_dio_interceptor.dart';
import 'dynamic_base_url_interceptor.dart';
import 'token_expired_interceptor.dart';

/// Factory para crear instancias de [Dio] pre-configuradas con los interceptores
/// estándar: URL dinámica, expiración de token y Crashlytics.
class ApiDioFactory {
  /// Crea un Dio listo para usar.
  /// El baseUrl es manejado dinámicamente por [DynamicBaseUrlInterceptor].
  ///
  /// Uso en datasources:
  /// ```dart
  /// final _dio = ApiDioFactory.create();
  /// ```
  static Dio create({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
    bool withTokenExpiredInterceptor = true,
    bool withCrashlyticsInterceptor = true,
    bool withDynamicUrlInterceptor = true,
  }) {
    final dio = Dio(BaseOptions(
      connectTimeout: connectTimeout ?? const Duration(seconds: 15),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 15),
      headers: headers,
    ));

    if (withDynamicUrlInterceptor) {
      dio.interceptors.add(DynamicBaseUrlInterceptor());
    }
    if (withTokenExpiredInterceptor) {
      dio.interceptors.add(TokenExpiredInterceptor());
    }
    if (withCrashlyticsInterceptor) {
      dio.interceptors.add(CrashlyticsDioInterceptor());
    }

    return dio;
  }

  /// Crea un Dio simple sin interceptores (útil para endpoints públicos)
  static Dio createSimple({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 15),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 15),
    ));
  }
}
