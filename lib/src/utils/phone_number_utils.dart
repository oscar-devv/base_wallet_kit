/// Utilidades para normalizar, formatear y comparar números de teléfono.
class PhoneNumberUtils {
  static const Map<String, String> supportedCountryCodes = {
    'MX': '+52',
    'US': '+1',
    'CA': '+1',
    'CO': '+57',
    'ES': '+34',
    'SV': '+503',
  };

  static String normalizePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    String clean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    for (final code in supportedCountryCodes.values) {
      final digits = code.replaceAll('+', '');
      if (clean.startsWith(digits)) {
        clean = clean.substring(digits.length);
        break;
      }
    }
    return clean;
  }

  static String formatWithCountryCode(String phoneNumber, String countryCode) {
    final normalized = normalizePhoneNumber(phoneNumber);
    if (normalized.isEmpty) return '';
    return '$countryCode$normalized';
  }

  static bool comparePhoneNumbers(String phone1, String phone2) =>
      normalizePhoneNumber(phone1) == normalizePhoneNumber(phone2);

  static bool isValidPhoneNumber(String phoneNumber) {
    final normalized = normalizePhoneNumber(phoneNumber);
    if (normalized.length < 7 || normalized.length > 15) return false;
    return RegExp(r'^\d+$').hasMatch(normalized);
  }

  static String removeCountryCode(String phoneNumber) {
    String clean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    for (final code in supportedCountryCodes.values) {
      final digits = code.replaceAll('+', '');
      if (clean.startsWith(digits)) return clean.substring(digits.length);
    }
    return clean;
  }
}
