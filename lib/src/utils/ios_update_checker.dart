import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Verifica si hay una nueva versión disponible en el App Store (solo iOS)
/// y muestra un bottom sheet modal no dismissible.
class IOSUpdateChecker {
  final String iOSBundleId;
  final String iOSAppStoreCountry;
  final bool enableSkipButton;

  IOSUpdateChecker({
    required this.iOSBundleId,
    this.iOSAppStoreCountry = 'MX',
    this.enableSkipButton = false,
  });

  Future<bool> _safelyLaunchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      if (!Platform.isIOS) return;

      final packageInfo = await PackageInfo.fromPlatform();
      debugPrint('🔄 Verificando actualización iOS - versión actual: ${packageInfo.version}');

      final newVersion = NewVersionPlus(
        iOSId: iOSBundleId,
        iOSAppStoreCountry: iOSAppStoreCountry,
      );
      final status = await newVersion.getVersionStatus();

      if (status == null || !status.canUpdate) {
        debugPrint('✅ No hay actualizaciones disponibles');
        return;
      }

      debugPrint('⬆️ Nueva versión disponible: ${status.storeVersion}');

      if (context.mounted) {
        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          barrierColor: Colors.black.withValues(alpha: 0.8),
          builder: (ctx) => PopScope(
            canPop: false,
            child: _UpdateBottomSheet(
              onUpdate: () async {
                final launched = await _safelyLaunchUrl(status.appStoreLink);
                if (!launched && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo abrir la App Store.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              enableSkip: enableSkipButton,
              onSkip: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al verificar actualización iOS: $e');
    }
  }
}

class _UpdateBottomSheet extends StatelessWidget {
  final VoidCallback onUpdate;
  final bool enableSkip;
  final VoidCallback? onSkip;

  const _UpdateBottomSheet({
    required this.onUpdate,
    this.enableSkip = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF020337),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.system_update, color: Color(0xFF4BCEFC), size: 48),
          const SizedBox(height: 16),
          const Text(
            'Nueva versión disponible',
            style: TextStyle(
              color: Color(0xFF4BCEFC),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Actualiza la app para continuar disfrutando de todas las funciones.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4BCEFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Actualizar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (enableSkip) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onSkip,
              child: const Text(
                'Omitir por ahora',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
