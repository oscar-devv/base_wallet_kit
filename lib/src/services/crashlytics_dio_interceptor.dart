import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Interceptor de Dio para registrar trazas de red en Firebase Crashlytics.
/// Registra inicio de request, respuestas con error HTTP (>=400) y excepciones.
class CrashlyticsDioInterceptor extends Interceptor {
  final FirebaseCrashlytics _crashlytics;

  CrashlyticsDioInterceptor({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _safeLog('http_request method=${options.method} url=${_truncate(options.uri.toString(), 300)}');
    _safeSetKey('http_last_method', options.method);
    _safeSetKey('http_last_url', _truncate(options.uri.toString(), 500));
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode ?? 0;
    _safeSetKey('http_last_status_code', statusCode);

    if (statusCode >= 400) {
      final body = _truncate(response.data?.toString() ?? 'null', 800);
      _safeSetKey('http_last_error_body', body);
      _safeRecordError(
        Exception('HTTP $statusCode en ${response.requestOptions.method} ${response.requestOptions.path}'),
        StackTrace.current,
        reason: 'http_status_error',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode ?? 0;
    _safeSetKey('http_last_status_code', statusCode);
    _safeSetKey('http_last_error_message', _truncate(err.message ?? 'null', 400));
    _safeSetKey('http_last_error_body', _truncate(err.response?.data?.toString() ?? 'null', 800));
    _safeRecordError(
      err,
      err.stackTrace,
      reason: 'http_dio_exception status=$statusCode url=${_truncate(err.requestOptions.uri.toString(), 200)}',
    );
    handler.next(err);
  }

  void _safeLog(String message) {
    try { _crashlytics.log(message); } catch (_) {}
  }

  void _safeSetKey(String key, Object value) {
    try { _crashlytics.setCustomKey(key, value); } catch (_) {}
  }

  void _safeRecordError(Object exception, StackTrace stack, {required String reason}) {
    try {
      _crashlytics.recordError(exception, stack, reason: reason, fatal: false);
    } catch (_) {}
  }

  String _truncate(String value, int maxLength) =>
      value.length <= maxLength ? value : '${value.substring(0, maxLength)}...';
}
