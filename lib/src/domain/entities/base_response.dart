/// Respuesta genérica de la API. Envuelve el resultado o el error.
class BaseResponse<T> {
  final T? data;
  final String? errorMessage;
  final int? statusCode;
  final bool success;

  const BaseResponse._({
    this.data,
    this.errorMessage,
    this.statusCode,
    required this.success,
  });

  factory BaseResponse.success(T data, {int? statusCode}) => BaseResponse._(
        data: data,
        statusCode: statusCode,
        success: true,
      );

  factory BaseResponse.error(String message, {int? statusCode}) =>
      BaseResponse._(
        errorMessage: message,
        statusCode: statusCode,
        success: false,
      );

  bool get hasData => data != null;
  bool get hasError => errorMessage != null;
}
