import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/base_response.dart';

/// Estado base de cuenta
class BaseAccountState<T> {
  final bool isLoading;
  final String? errorMessage;
  final T? data;

  const BaseAccountState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
  });

  BaseAccountState<T> copyWith({
    bool? isLoading,
    String? errorMessage,
    T? data,
  }) =>
      BaseAccountState<T>(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        data: data ?? this.data,
      );
}

/// Notifier base para operaciones de cuenta.
/// Extiende para agregar operaciones específicas del proyecto.
///
/// ```dart
/// class AccountNotifier extends BaseAccountNotifier<WalletAccount> {
///   final AccountRepository _repo;
///   AccountNotifier(this._repo) : super();
///
///   Future<void> loadAccount(String id) async {
///     setLoading(true);
///     final result = await _repo.getById(id);
///     handleResult(result);
///   }
/// }
/// ```
abstract class BaseAccountNotifier<T>
    extends StateNotifier<BaseAccountState<T>> {
  BaseAccountNotifier() : super(const BaseAccountState());

  void setLoading(bool value) =>
      state = state.copyWith(isLoading: value);

  void setError(String message) =>
      state = state.copyWith(isLoading: false, errorMessage: message);

  void setData(T data) =>
      state = state.copyWith(data: data, isLoading: false);

  void clearError() =>
      state = state.copyWith(errorMessage: null);

  void handleResult(BaseResponse<T> response) {
    if (response.success && response.data != null) {
      setData(response.data as T);
    } else {
      setError(response.errorMessage ?? 'Error desconocido');
    }
  }
}
