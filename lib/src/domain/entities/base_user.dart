/// Entidad base de usuario. Extiende esta clase con los campos
/// específicos de tu proyecto.
///
/// ```dart
/// class LoginUser extends BaseUser {
///   final String token;
///   final String company;
///
///   const LoginUser({
///     required super.id,
///     required super.name,
///     required super.lastname,
///     required super.email,
///     required super.status,
///     required this.token,
///     required this.company,
///   });
/// }
/// ```
abstract class BaseUser {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final String status;

  const BaseUser({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.status,
  });

  String get fullName => '$name $lastname'.trim();
}
