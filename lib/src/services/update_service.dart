import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/ios_update_checker.dart';

/// Servicio para verificar y mostrar actualizaciones disponibles.
///
/// Android: usa un [MethodChannel] para comunicarse con el código nativo
/// de Google Play In-App Updates.
/// iOS: delega a [IOSUpdateChecker] que redirige a la App Store.
///
/// Uso:
/// ```dart
/// await UpdateService.checkForUpdate(context, channelName: 'com.miempresa.miapp/in_app_update');
/// ```
class UpdateService {
  /// Flag para evitar mostrar el diálogo múltiples veces.
  static bool _isCheckingUpdate = false;
  static bool _isDialogShowing = false;

  /// Resetea los flags internos (útil en testing o reinicio de sesión).
  static void resetFlags() {
    _isCheckingUpdate = false;
    _isDialogShowing = false;
    _log('🔄 Flags reseteados');
  }

  /// Verifica si hay actualizaciones disponibles y las muestra al usuario.
  ///
  /// [channelName] nombre del MethodChannel nativo para Android in-app updates.
  /// [iOSBundleId] bundle ID de la app en el App Store (requerido para iOS).
  /// [iOSAppStoreCountry] código de país del App Store (por defecto 'MX').
  /// [onUpdateAvailable] callback opcional para manejar la lógica de overlay
  /// de actualización desde el proyecto que consume la librería.
  static Future<void> checkForUpdate(
    BuildContext context, {
    required String channelName,
    required String iOSBundleId,
    String iOSAppStoreCountry = 'MX',
    void Function({
      required bool immediateUpdateAllowed,
      required bool flexibleUpdateAllowed,
      String? message,
    })? onUpdateAvailable,
  }) async {
    _log('🔍 checkForUpdate llamado');
    _log('🔍 Platform.isAndroid: ${Platform.isAndroid}');
    _log('🔍 Platform.isIOS: ${Platform.isIOS}');

    if (_isCheckingUpdate) {
      _log('⏭️ Verificación omitida: ya en progreso');
      return;
    }

    if (_isDialogShowing) {
      final modalRoute = ModalRoute.of(context);
      final isDialogActuallyVisible = modalRoute?.isCurrent == false;
      if (!isDialogActuallyVisible) {
        _log('⚠️ Flag indica diálogo visible pero no está en pantalla - reseteando flag');
        _isDialogShowing = false;
      } else {
        _log('⏭️ Verificación omitida: diálogo ya visible');
        return;
      }
    }

    _isCheckingUpdate = true;

    if (Platform.isAndroid) {
      try {
        _log('Iniciando verificación de actualización...');

        final MethodChannel channel = MethodChannel(channelName);
        final updateInfoMap = await channel.invokeMethod<Map<dynamic, dynamic>>(
          'checkForUpdate',
        );

        _log('Respuesta del código nativo: $updateInfoMap');

        if (updateInfoMap == null) {
          _log('ERROR: No se pudo obtener información de actualización (respuesta null)');
          return;
        }

        final errorCode = updateInfoMap['errorCode'] as String?;
        if (errorCode == 'APP_NOT_OWNED') {
          _log('⚠️ App no instalada desde Play Store. Las actualizaciones in-app solo funcionan si la app fue instalada desde Play Store.');
          return;
        }

        final updateAvailability = updateInfoMap['updateAvailability'] as int?;
        _log('updateAvailability: $updateAvailability');

        if (updateAvailability == null) {
          _log('ERROR: updateAvailability es null');
          return;
        }

        final immediateUpdateAllowed =
            updateInfoMap['immediateUpdateAllowed'] as bool? ?? false;
        final flexibleUpdateAllowed =
            updateInfoMap['flexibleUpdateAllowed'] as bool? ?? false;

        _log('immediateUpdateAllowed: $immediateUpdateAllowed');
        _log('flexibleUpdateAllowed: $flexibleUpdateAllowed');

        // UpdateAvailability.UPDATE_AVAILABLE = 2
        if (updateAvailability == 2) {
          _log('✅ Actualización disponible!');
          _isDialogShowing = true;

          if (onUpdateAvailable != null) {
            // Delegar al proyecto la lógica de mostrar el overlay/dialog
            onUpdateAvailable(
              immediateUpdateAllowed: immediateUpdateAllowed,
              flexibleUpdateAllowed: flexibleUpdateAllowed,
            );
          } else {
            // Fallback: mostrar un AlertDialog básico
            if (context.mounted) {
              await _showUpdateDialog(context);
            }
          }
        } else {
          _log('⏭️ No hay actualización disponible. Estado: $updateAvailability');
        }
      } on PlatformException catch (e) {
        _log('❌ PlatformException al verificar actualizaciones: ${e.message}');
      } catch (e, stackTrace) {
        _log('❌ Exception al verificar actualizaciones: $e\n$stackTrace');
      } finally {
        _isCheckingUpdate = false;
      }
    } else if (Platform.isIOS) {
      IOSUpdateChecker(
        iOSBundleId: iOSBundleId,
        iOSAppStoreCountry: iOSAppStoreCountry,
      ).checkForUpdate(context);
      _isCheckingUpdate = false;
    } else {
      _isCheckingUpdate = false;
    }
  }

  /// Diálogo básico de actualización cuando no se proporciona [onUpdateAvailable].
  static Future<void> _showUpdateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Actualización disponible'),
        content: const Text(
          'Hay una nueva versión de la aplicación disponible. '
          'Actualiza desde la tienda para continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _isDialogShowing = false;
            },
            child: const Text('Más tarde'),
          ),
        ],
      ),
    );
  }

  static void _log(String message) {
    debugPrint('[UpdateService] $message');
  }
}
