import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Diálogo de valoración de la app.
/// Muestra el diálogo después de N aperturas si el usuario no lo ha valorado aún.
class RatingDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRate;
  final VoidCallback? onLater;
  final VoidCallback? onNever;

  const RatingDialog({
    super.key,
    this.title = '¿Te gusta la app?',
    this.message = 'Tómate un momento para valorarla en la tienda.',
    required this.onRate,
    this.onLater,
    this.onNever,
  });

  static const String _keyHasRated = 'has_rated_app';
  static const String _keyNeverAsk = 'never_ask_rating';
  static const String _keyOpenCount = 'app_open_count';

  /// Verifica si debe mostrar el diálogo y lo muestra si aplica.
  static Future<void> showIfNeeded(
    BuildContext context, {
    int showAfterOpenings = 5,
    VoidCallback? onRate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hasRated = prefs.getBool(_keyHasRated) ?? false;
    final neverAsk = prefs.getBool(_keyNeverAsk) ?? false;

    if (hasRated || neverAsk) return;

    final openCount = (prefs.getInt(_keyOpenCount) ?? 0) + 1;
    await prefs.setInt(_keyOpenCount, openCount);

    if (openCount < showAfterOpenings) return;

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => RatingDialog(
          onRate: () async {
            await prefs.setBool(_keyHasRated, true);
            Navigator.of(ctx).pop();
            onRate?.call();
          },
          onLater: () => Navigator.of(ctx).pop(),
          onNever: () async {
            await prefs.setBool(_keyNeverAsk, true);
            Navigator.of(ctx).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      content: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black54)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (onNever != null)
          TextButton(
            onPressed: onNever,
            child: const Text('No preguntar', style: TextStyle(color: Colors.grey)),
          ),
        if (onLater != null)
          TextButton(
            onPressed: onLater,
            child: const Text('Luego', style: TextStyle(color: Colors.grey)),
          ),
        ElevatedButton(
          onPressed: onRate,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: const Text('Valorar ahora'),
        ),
      ],
    );
  }
}
