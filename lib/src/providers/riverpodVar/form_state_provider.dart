import 'package:flutter_riverpod/legacy.dart';

/// Provider para controlar la visibilidad de alertas en campos de formulario.
/// true = mostrar alerta de validación, false = campo válido.
final isAlertEmailProvider = StateProvider<bool>((ref) => false);
final isAlertPasswordProvider = StateProvider<bool>((ref) => false);
final isAlertConfirmPasswordProvider = StateProvider<bool>((ref) => false);
final isAlertNameProvider = StateProvider<bool>((ref) => false);
final isAlertPhoneProvider = StateProvider<bool>((ref) => false);

/// Provider para controlar el estado de carga de operaciones asíncronas.
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider para controlar si la pantalla de selección de método de auth está activa.
final isAuthMethodSelectionActiveProvider = StateProvider<bool>((ref) => false);

/// Provider para el estado de autenticación biométrica en progreso.
final isBiometricAuthInProgressProvider = StateProvider<bool>((ref) => false);
