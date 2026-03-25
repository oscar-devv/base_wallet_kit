import 'package:flutter/material.dart';

/// Diálogo de alerta genérico reutilizable.
class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;

  const CustomAlert({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Aceptar',
    this.cancelText,
    this.onCancel,
    this.confirmColor,
    this.icon,
  });

  /// Muestra el diálogo desde cualquier contexto
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomAlert(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: cancelText != null ? () => Navigator.of(ctx).pop(false) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: confirmColor ?? Theme.of(context).primaryColor),
            const SizedBox(height: 8),
          ],
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ],
      ),
      content: Text(message, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black54)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
            child: Text(cancelText!,
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
          ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text(confirmText,
              style: const TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ],
    );
  }
}
