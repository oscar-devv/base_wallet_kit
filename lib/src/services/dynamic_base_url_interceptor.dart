import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_url_manager.dart';

/// Interceptor de Dio que reemplaza el baseUrl de cada request
/// con la URL activa de [ApiUrlManager] (controlada por Firebase Remote Config).
class DynamicBaseUrlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final activeUrl = ApiUrlManager.instance.currentBaseUrl;
    options.baseUrl = activeUrl;

    if (kDebugMode) {
      debugPrint('🔗 DynamicBaseUrl: ${options.method} '
          '${options.baseUrl}${options.path}');
    }

    handler.next(options);
  }
}
