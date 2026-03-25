import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Widget que verifica permisos antes de mostrar su contenido.
/// Si el permiso no está concedido, muestra [fallback] o una pantalla de solicitud.
class PermissionGuard extends StatefulWidget {
  final Permission permission;
  final Widget child;
  final Widget? fallback;
  final String? permissionRationale;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.permissionRationale,
  });

  @override
  State<PermissionGuard> createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard> {
  bool _isGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await widget.permission.status;
    if (mounted) {
      setState(() {
        _isGranted = status.isGranted;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await widget.permission.request();
    if (mounted) {
      setState(() => _isGranted = status.isGranted);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isGranted) return widget.child;

    return widget.fallback ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  widget.permissionRationale ??
                      'Se necesita este permiso para continuar.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: const Text('Conceder permiso'),
                ),
              ],
            ),
          ),
        );
  }
}
