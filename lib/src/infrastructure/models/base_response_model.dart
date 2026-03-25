/// Modelo base para respuestas de API.
/// La mayoría de las APIs devuelven una estructura similar.
///
/// Extiende para agregar campos específicos:
/// ```dart
/// class LoginResponseModel extends BaseResponseModel {
///   final String token;
///   LoginResponseModel.fromJson(Map<String, dynamic> json)
///       : token = json['token'],
///         super.fromJson(json);
/// }
/// ```
class BaseResponseModel {
  final bool? success;
  final String? message;
  final dynamic data;

  BaseResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) =>
      BaseResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'],
      );

  Map<String, dynamic> toJson() => {
        if (success != null) 'success': success,
        if (message != null) 'message': message,
        if (data != null) 'data': data,
      };
}
