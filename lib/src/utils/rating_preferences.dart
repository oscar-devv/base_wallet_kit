import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia de preferencias relacionadas con el rating/calificación de la app.
class RatingPreferences {
  static const String _keyHasRated = 'user_has_rated';
  static const String _keyRatingPromptShown = 'rating_prompt_shown';

  /// Verifica si el usuario ya calificó la app.
  static Future<bool> hasRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasRated) ?? false;
  }

  /// Marca que el usuario ya calificó la app.
  static Future<void> setHasRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasRated, true);
  }

  /// Verifica si ya se mostró el prompt de calificación en esta sesión.
  static Future<bool> wasPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRatingPromptShown) ?? false;
  }

  /// Marca que ya se mostró el prompt en esta sesión.
  static Future<void> setPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRatingPromptShown, true);
  }

  /// Resetea el flag de sesión. Llamar al hacer logout.
  static Future<void> resetSessionFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRatingPromptShown, false);
  }
}
