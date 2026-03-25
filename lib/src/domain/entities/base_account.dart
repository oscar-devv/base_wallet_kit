/// Entidad base de cuenta/wallet. Extiende con los campos
/// específicos de tu proyecto.
///
/// ```dart
/// class WalletAccount extends BaseAccount {
///   final String currency;
///
///   const WalletAccount({
///     required super.id,
///     required super.balance,
///     required super.status,
///     required this.currency,
///   });
/// }
/// ```
abstract class BaseAccount {
  final String id;
  final String balance;
  final String status;

  const BaseAccount({
    required this.id,
    required this.balance,
    required this.status,
  });
}
