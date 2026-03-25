// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/permissions_blocking_screen.dart';

/// Servicio para manejar permisos obligatorios de la aplicación.
///
/// Gestiona el flujo completo de solicitud de permisos de ubicación,
/// mostrando diálogos apropiados y una pantalla de bloqueo si son denegados
/// permanentemente.
class MandatoryPermissionsService {
  static final MandatoryPermissionsService _instance =
      MandatoryPermissionsService._internal();
  factory MandatoryPermissionsService() => _instance;
  MandatoryPermissionsService._internal();

  /// Verifica si los servicios de ubicación están habilitados.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      if (kDebugMode) print('⚠️ Error verificando servicios de ubicación: $e');
      return false;
    }
  }

  /// Verifica el estado actual de los permisos de ubicación.
  Future<LocationPermission> getCurrentLocationPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      if (kDebugMode) print('⚠️ Error verificando permisos de ubicación: $e');
      return LocationPermission.denied;
    }
  }

  /// Solicita permisos de ubicación de forma obligatoria.
  ///
  /// Retorna `true` si los permisos fueron concedidos.
  Future<bool> requestLocationPermission(BuildContext context) async {
    try {
      if (kDebugMode) print('📍 MandatoryPermissions: Solicitando permisos de ubicación...');

      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('❌ MandatoryPermissions: Servicios de ubicación deshabilitados');
        await _showEnableLocationServicesDialog(context);
        return false;
      }

      LocationPermission permission = await getCurrentLocationPermission();

      if (permission == LocationPermission.denied) {
        if (kDebugMode) print('📍 MandatoryPermissions: Solicitando permisos...');
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('❌ MandatoryPermissions: Permisos denegados permanentemente');
        await _showGoToSettingsDialog(context);
        return false;
      }

      if (permission == LocationPermission.denied) {
        if (kDebugMode) print('❌ MandatoryPermissions: Permisos denegados');
        return false;
      }

      if (kDebugMode) print('✅ MandatoryPermissions: Permisos concedidos');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ MandatoryPermissions: Error solicitando permisos: $e');
      return false;
    }
  }

  Future<void> _showEnableLocationServicesDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Servicios de Ubicación Requeridos'),
          content: const Text(
            'Esta aplicación necesita acceso a la ubicación para funcionar correctamente. '
            'Por favor, habilita los servicios de ubicación en la configuración de tu dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await Future.delayed(const Duration(milliseconds: 300));
                await Geolocator.openLocationSettings();
                await Future.delayed(const Duration(seconds: 2));
                if (context.mounted) showBlockingScreenSafe(context);
              },
              child: const Text('Ir a Configuración'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                exitApp();
              },
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGoToSettingsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.location_off_rounded, color: Color(0xFF1E3A8A), size: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Permisos Requeridos',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Los permisos de ubicación fueron denegados permanentemente. '
                'Para usar esta aplicación, debes habilitar los permisos de ubicación '
                'en la configuración de la aplicación.',
                style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF374151)),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los permisos deben habilitarse manualmente en la configuración del dispositivo.',
                        style: TextStyle(fontSize: 11, color: const Color(0xFF92400E), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  flex: 45,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        exitApp();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Salir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 55,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await Future.delayed(const Duration(milliseconds: 300));
                        await Geolocator.openAppSettings();
                        await Future.delayed(const Duration(seconds: 2));
                        if (context.mounted) showBlockingScreenSafe(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Ir a Configuración',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Verifica si los permisos de ubicación están concedidos sin solicitarlos.
  Future<bool> arePermissionsGranted() async {
    try {
      LocationPermission permission = await getCurrentLocationPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si todos los permisos obligatorios están concedidos.
  Future<bool> areAllMandatoryPermissionsGranted() async {
    return await arePermissionsGranted();
  }

  /// Cierra la aplicación.
  void exitApp() {
    if (kDebugMode) print('🚪 MandatoryPermissions: Cerrando aplicación por falta de permisos');
    SystemNavigator.pop();
  }

  /// Muestra la pantalla de bloqueo de forma segura usando MaterialPageRoute.
  void showBlockingScreenSafe(BuildContext context) {
    Future.microtask(() {
      if (!context.mounted) return;
      try {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (_) {}

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!context.mounted) return;
        try {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const PermissionsBlockingScreen(),
            ),
            (route) => false,
          );
        } catch (e) {
          if (kDebugMode) print('⚠️ Error en navegación segura: $e');
          exitApp();
        }
      });
    });
  }

  /// Muestra la pantalla de bloqueo.
  void showBlockingScreen(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        try {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const PermissionsBlockingScreen(),
            ),
            (route) => false,
          );
        } catch (e) {
          if (kDebugMode) print('⚠️ Error en navegación: $e');
          exitApp();
        }
      }
    });
  }
}
