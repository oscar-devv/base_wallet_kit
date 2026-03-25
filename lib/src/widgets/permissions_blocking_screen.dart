import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// Pantalla de bloqueo que se muestra cuando los permisos obligatorios
/// (ubicación) no han sido concedidos. Impide el uso de la app hasta
/// que el usuario habilite los permisos desde la configuración del dispositivo.
class PermissionsBlockingScreen extends StatelessWidget {
  const PermissionsBlockingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    size: 64,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Permisos Requeridos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Esta aplicación requiere acceso a tu ubicación para funcionar correctamente. '
                  'Por favor, habilita los permisos de ubicación en la configuración de tu dispositivo.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF374151),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Geolocator.openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ir a Configuración',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Salir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
