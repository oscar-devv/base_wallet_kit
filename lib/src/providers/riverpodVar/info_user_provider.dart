// ignore_for_file: non_constant_identifier_names
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de estado para la lista de datos del usuario en sesión.
/// Los datos se persisten en SharedPreferences bajo la clave [userPrefsKey].
///
/// Uso: accede por índice según la estructura definida por el proyecto.
/// ```dart
/// final userInfo = ref.watch(UserInfoProvider);
/// final userName = userInfo.length > 3 ? userInfo[3] : '';
/// ```
final UserInfoProvider =
    StateNotifierProvider<StringListNotifier, List<String>>(
        (ref) => StringListNotifier(prefsKey: 'stringListUser'));

/// Provider de datos de cuenta del usuario.
final AccountInfoProvider =
    StateNotifierProvider<StringListNotifier, List<String>>(
        (ref) => StringListNotifier(prefsKey: 'stringListAccount'));

/// Notifier genérico para listas de strings persistidas en SharedPreferences.
/// Utilizado por [UserInfoProvider] y [AccountInfoProvider].
class StringListNotifier extends StateNotifier<List<String>> {
  final String prefsKey;
  bool _isClearing = false;

  StringListNotifier({required this.prefsKey}) : super([]) {
    _loadStringList();
  }

  Future<void> initialize() async => _loadStringList();

  Future<void> _loadStringList() async {
    if (_isClearing) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(prefsKey);
    if (stored != null) state = stored;
  }

  Future<void> _saveStringList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(prefsKey, state);
  }

  /// Agrega un string al final de la lista
  Future<void> addString(String value) async {
    state = [...state, value];
    await _saveStringList();
  }

  /// Elimina un string por su valor
  Future<void> removeString(String value) async {
    state = state.where((s) => s != value).toList();
    await _saveStringList();
  }

  /// Actualiza un string en un índice específico
  Future<void> updateString(int index, String value) async {
    if (index < 0 || index >= state.length) return;
    final updated = [...state];
    updated[index] = value;
    state = updated;
    await _saveStringList();
  }

  /// Limpia toda la lista de forma segura, evitando recargas durante el proceso
  Future<void> clearList() async {
    _isClearing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefsKey);
      state = [];
    } finally {
      await Future.delayed(const Duration(milliseconds: 100));
      _isClearing = false;
    }
  }

  /// Retorna el valor en un índice de forma segura (sin lanzar RangeError)
  String safeGet(int index, {String fallback = ''}) {
    if (index < 0 || index >= state.length) return fallback;
    return state[index];
  }
}
