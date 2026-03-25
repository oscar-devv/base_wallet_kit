import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/base_response.dart';

/// Estado base de autenticación
class BaseAuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const BaseAuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  BaseAuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) =>
      BaseAuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

/// Notifier base para flujos de autenticación.
/// Extiende esta clase en tu proyecto para agregar lógica específica.
///
/// ```dart
/// class LoginNotifier extends BaseAuthNotifier {
///   final LoginRepository _repo;
///   LoginNotifier(this._repo) : super();
///
///   Future<void> login(String email, String password) async {
///     setLoading(true);
///     final result = await _repo.login(email, password);
///     handleResult(result);
///   }
/// }
/// ```
abstract class BaseAuthNotifier extends StateNotifier<BaseAuthState> {
  BaseAuthNotifier() : super(const BaseAuthState());

  void setLoading(bool value) =>
      state = state.copyWith(isLoading: value);

  void setError(String message) =>
      state = state.copyWith(isLoading: false, errorMessage: message);

  void setAuthenticated(bool value) =>
      state = state.copyWith(isAuthenticated: value, isLoading: false);

  void clearError() =>
      state = state.copyWith(errorMessage: null);

  void handleResult<T>(BaseResponse<T> response, {void Function(T data)? onSuccess}) {
    if (response.success && response.data != null) {
      setAuthenticated(true);
      onSuccess?.call(response.data as T);
    } else {
      setError(response.errorMessage ?? 'Error desconocido');
    }
  }
}
