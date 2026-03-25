import 'dart:async';
import 'package:flutter/material.dart';

/// Gestiona operaciones en segundo plano con manejo seguro de errores y reintentos.
class BackgroundOperationManager {
  /// Ejecuta una operación con manejo seguro y reintentos automáticos.
  ///
  /// [operation] función asíncrona a ejecutar.
  /// [onError] callback opcional para manejar errores.
  /// [retryCount] número de reintentos si falla la operación.
  /// [retryDelay] tiempo de espera entre reintentos.
  static Future<T?> executeSafely<T>({
    required Future<T> Function() operation,
    void Function(Object error)? onError,
    int retryCount = 2,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts <= retryCount) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        debugPrint('Error en operación (intento $attempts): $e');

        if (attempts > retryCount) {
          onError?.call(e);
          return null;
        }

        await Future.delayed(retryDelay);
      }
    }

    return null;
  }

  /// Verifica si el contexto proporcionado aún es válido.
  static bool isContextValid(BuildContext? context) {
    if (context == null) return false;
    return context.mounted;
  }
}
