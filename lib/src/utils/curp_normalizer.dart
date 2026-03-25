/// Normalización de CURP para formularios y OCR.
/// En los primeros 4 caracteres reemplaza '0' por 'O' (el OCR suele confundirlos).
class CurpNormalizer {
  static const int curpMaxLength = 18;

  static String normalize(String value) {
    if (value.isEmpty) return value;
    String cleaned =
        value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length > curpMaxLength) {
      cleaned = cleaned.substring(0, curpMaxLength);
    }
    if (cleaned.length >= 4) {
      final firstFour = cleaned.substring(0, 4).replaceAll('0', 'O');
      cleaned = firstFour + cleaned.substring(4);
    }
    return cleaned;
  }
}
