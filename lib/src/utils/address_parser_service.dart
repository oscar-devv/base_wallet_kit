// ignore_for_file: prefer_const_declarations, unused_local_variable

import 'package:flutter/foundation.dart';

/// Servicio para parsear direcciones de INE de forma robusta.
/// Combina datos de KYC y OCR local, extrayendo componentes estructurados.
///
/// Todas las operaciones son estáticas; no es necesario instanciar esta clase.
class AddressParserService {
  /// Crea una instancia de [AddressParserService].
  ///
  /// No es necesario instanciar esta clase directamente ya que todos sus
  /// métodos son estáticos. Se expone el constructor para compatibilidad
  /// con la API pública del paquete.
  AddressParserService();

  /// Parsea una dirección completa y extrae sus componentes estructurados.
  ///
  /// Prioridad:
  /// 1. Datos de KYC (si están disponibles y no son dummy)
  /// 2. Datos de OCR local
  /// 3. Extracción directa del texto de dirección usando patrones
  /// 4. Valores por defecto seguros
  static ParsedAddress parseAddress({
    // KYC data
    String? jaakAddress,
    String? jaakPostalCode,
    // OCR local data
    String? ocrStreet,
    String? ocrStreetNumber,
    String? ocrColony,
    String? ocrMunicipality,
    String? ocrState,
    String? ocrPostalCode,
    String? ocrAddress,
  }) {
    if (kDebugMode) {
      print('🏠 === INICIANDO PARSING DE DIRECCIÓN ===');
      print('📍 KYC address: "${jaakAddress ?? ""}"');
      print('📍 KYC postalCode: "${jaakPostalCode ?? ""}"');
      print('📍 OCR street: "${ocrStreet ?? ""}"');
      print('📍 OCR streetNumber: "${ocrStreetNumber ?? ""}"');
      print('📍 OCR colony: "${ocrColony ?? ""}"');
      print('📍 OCR municipality: "${ocrMunicipality ?? ""}"');
      print('📍 OCR state: "${ocrState ?? ""}"');
      print('📍 OCR postalCode: "${ocrPostalCode ?? ""}"');
      print('📍 OCR address: "${ocrAddress ?? ""}"');
    }

    String rawAddress = '';
    if (jaakAddress != null && jaakAddress.isNotEmpty) {
      rawAddress = jaakAddress;
      if (kDebugMode) print('✅ Usando dirección de KYC');
    } else if (ocrAddress != null && ocrAddress.isNotEmpty) {
      rawAddress = ocrAddress;
      if (kDebugMode) print('✅ Usando dirección de OCR local');
    }

    String streetName = '';
    String streetNumber = '';
    String neighborhood = '';
    String city = '';
    String state = '';
    String postalCode = '';

    // PASO 1: Priorizar datos estructurados de OCR local
    if (_isValidValue(ocrStreet)) {
      streetName = ocrStreet!.trim();
      if (kDebugMode) print('✅ Calle desde OCR: $streetName');
    }

    if (_isValidValue(ocrStreetNumber)) {
      streetNumber = _extractNumericPart(ocrStreetNumber!);
      if (kDebugMode) print('✅ Número desde OCR: $streetNumber');
    }

    if (_isValidValue(ocrColony)) {
      neighborhood = ocrColony!.trim();
      if (kDebugMode) print('✅ Colonia desde OCR: $neighborhood');
    }

    if (_isValidValue(ocrMunicipality)) {
      city = ocrMunicipality!.trim();
      if (kDebugMode) print('✅ Municipio desde OCR: $city');
    }

    if (_isValidValue(ocrState)) {
      state = ocrState!.trim();
      if (kDebugMode) print('✅ Estado desde OCR: $state');
    }

    // PASO 2: Código postal — priorizar KYC, luego OCR
    if (_isValidValue(jaakPostalCode)) {
      postalCode = _normalizePostalCode(jaakPostalCode!);
      if (kDebugMode) print('✅ CP desde KYC: $postalCode');
    } else if (_isValidValue(ocrPostalCode)) {
      postalCode = _normalizePostalCode(ocrPostalCode!);
      if (kDebugMode) print('✅ CP desde OCR: $postalCode');
    }

    // PASO 3: Extraer componentes faltantes del texto crudo
    String apartmentFromExtraction = '';
    if (rawAddress.isNotEmpty) {
      final extracted = _extractFromRawAddress(rawAddress);

      if (streetName.isEmpty && extracted.street.isNotEmpty) {
        streetName = extracted.street;
        if (kDebugMode) print('✅ Calle extraída del texto: $streetName');
      }

      if (streetNumber.isEmpty && extracted.number.isNotEmpty) {
        streetNumber = extracted.number;
        if (kDebugMode) print('✅ Número extraído del texto: $streetNumber');
      }

      if (neighborhood.isEmpty && extracted.neighborhood.isNotEmpty) {
        neighborhood = extracted.neighborhood;
        if (kDebugMode) print('✅ Colonia extraída del texto: $neighborhood');
      }

      if (city.isEmpty && extracted.city.isNotEmpty) {
        city = extracted.city;
        if (kDebugMode) print('✅ Ciudad extraída del texto: $city');
      }

      if (state.isEmpty && extracted.state.isNotEmpty) {
        state = extracted.state;
        if (kDebugMode) print('✅ Estado extraído del texto: $state');
      }

      if (postalCode.isEmpty && extracted.postalCode.isNotEmpty) {
        postalCode = extracted.postalCode;
        if (kDebugMode) print('✅ CP extraído del texto: $postalCode');
      }

      if (extracted.apartment.isNotEmpty) {
        apartmentFromExtraction = extracted.apartment;
        if (kDebugMode) print('✅ Número interior extraído: $apartmentFromExtraction');
      }
    }

    // PASO 4: Normalizar y aplicar valores por defecto seguros
    final result = ParsedAddress(
      streetName: _sanitizeForPomelo(streetName.isNotEmpty ? streetName : 'Avenida Principal'),
      streetNumber: streetNumber.isNotEmpty ? streetNumber : '100',
      floor: '1',
      apartment: apartmentFromExtraction.isNotEmpty ? apartmentFromExtraction : '1',
      postalCode: postalCode.isNotEmpty ? postalCode : '11000',
      neighborhood: _sanitizeForPomelo(neighborhood.isNotEmpty ? neighborhood : 'Centro'),
      city: _sanitizeForPomelo(city.isNotEmpty ? city : 'Ciudad De Mexico'),
      region: _sanitizeForPomelo(state.isNotEmpty ? state : 'Ciudad De Mexico'),
      additionalInfo: 'A',
      country: 'MEX',
    );

    if (kDebugMode) {
      print('🎯 === RESULTADO FINAL DEL PARSING ===');
      print('📍 Calle: ${result.streetName}');
      print('📍 Número exterior: ${result.streetNumber}');
      print('📍 Número interior: ${result.apartment}');
      print('📍 Colonia: ${result.neighborhood}');
      print('📍 Ciudad: ${result.city}');
      print('📍 Estado: ${result.region}');
      print('📍 CP: ${result.postalCode}');
    }

    return result;
  }

  static _ExtractedComponents _extractFromRawAddress(String rawAddress) {
    if (kDebugMode) print('🔍 Extrayendo componentes de texto crudo: "$rawAddress"');

    rawAddress = rawAddress.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    List<String> lines = rawAddress.split('\n');

    String street = '';
    String number = '';
    String neighborhood = '';
    String city = '';
    String state = '';
    String postalCode = '';
    String apartment = '';

    postalCode = _extractPostalCode(rawAddress);

    if (lines.isNotEmpty) {
      final streetInfo = _extractStreetAndNumber(lines[0]);
      street = streetInfo['street'] ?? '';
      number = streetInfo['number'] ?? '';

      if (number.contains(' INT ')) {
        List<String> parts = number.split(' INT ');
        if (parts.length == 2) {
          number = parts[0];
          apartment = parts[1];
          if (kDebugMode) print('✅ Separado: exterior="$number", interior="$apartment"');
        }
      }
    }

    neighborhood = _extractNeighborhood(rawAddress);
    city = _extractCity(rawAddress);
    state = _extractState(rawAddress);

    return _ExtractedComponents(
      street: street,
      number: number,
      apartment: apartment,
      neighborhood: neighborhood,
      city: city,
      state: state,
      postalCode: postalCode,
    );
  }

  static String _extractPostalCode(String text) {
    RegExp cpPattern = RegExp(r'\b(\d{5})\b');
    Match? match = cpPattern.firstMatch(text);
    return match?.group(1) ?? '';
  }

  static Map<String, String> _extractStreetAndNumber(String line) {
    String street = '';
    String number = '';

    if (kDebugMode) print('🔍 Extrayendo calle y número de: "$line"');

    // Patrón 1: dos números consecutivos (exterior + interior)
    RegExp twoNumbersPattern = RegExp(
        r'((?:CALLE|C\.|AV\.|AVENIDA|BLVD\.|BOULEVARD|CALZ\.|CALZADA|PASEO|PRIV\.|PRIVADA)\s+[A-ZÁÉÍÓÚÜÑáéíóúüñ\s\.]+?)\s+(\d{1,4})\s+(\d{1,4})',
        caseSensitive: false);
    Match? twoNumsMatch = twoNumbersPattern.firstMatch(line);

    if (twoNumsMatch != null) {
      street = twoNumsMatch.group(1)?.trim() ?? '';
      String exteriorNumber = twoNumsMatch.group(2) ?? '';
      String interiorNumber = twoNumsMatch.group(3) ?? '';
      if (exteriorNumber.length < 5 && interiorNumber.length < 5) {
        number = "$exteriorNumber INT $interiorNumber";
        if (kDebugMode) print('✅ Patrón DOS números: calle="$street", número="$number"');
        return {'street': street, 'number': number};
      }
    }

    // Patrón 2: número después de NO/NUM
    RegExp noPattern = RegExp(
        r'(.*?)[\s]+(?:NO|No|no|NO\.|No\.|no\.|NUM|NUMERO|NÚMERO|#|N°)[\s\.]*(\d+)',
        caseSensitive: true);
    Match? noMatch = noPattern.firstMatch(line);
    if (noMatch != null) {
      street = noMatch.group(1)?.trim() ?? '';
      number = noMatch.group(2) ?? '';
      if (kDebugMode) print('✅ Patrón NO/NUM: calle="$street", número="$number"');
      return {'street': street, 'number': number};
    }

    // Patrón 3: calle con prefijo
    RegExp streetPattern = RegExp(
        r'(CALLE|C\.|AV\.|AVENIDA|BLVD\.|BOULEVARD|CALZ\.|CALZADA|PASEO|PRIV\.|PRIVADA)\s+([A-ZÁÉÍÓÚÜÑáéíóúüñ\s\.]+?)(?:\s+(?:NO\.|NUM\.|#|N°)?\s*(\d+))?',
        caseSensitive: false);
    Match? streetMatch = streetPattern.firstMatch(line);
    if (streetMatch != null) {
      street = "${streetMatch.group(1)} ${streetMatch.group(2)}".trim();
      number = streetMatch.group(3) ?? '';
      if (kDebugMode) print('✅ Patrón con prefijo: calle="$street", número="$number"');
      return {'street': street, 'number': number};
    }

    // Patrón simple: número al final
    RegExp endNumberPattern = RegExp(r'(.*?)\s+(\d{1,4})$');
    Match? endMatch = endNumberPattern.firstMatch(line);
    if (endMatch != null) {
      String potentialNumber = endMatch.group(2) ?? '';
      if (potentialNumber.length < 5) {
        street = endMatch.group(1)?.trim() ?? '';
        number = potentialNumber;
        return {'street': street, 'number': number};
      }
    }

    street = line.trim();
    return {'street': street, 'number': number};
  }

  static String _extractNeighborhood(String text) {
    List<String> lines = text.split('\n');
    List<String> colonyPrefixes = [
      'FRACC', 'FRACCIONAMIENTO', 'COL', 'COLONIA', 'BARRIO',
      'UNIDAD', 'RESIDENCIAL', 'PBLO', 'PUEBLO', 'EJIDO', 'EJ',
      'RANCHO', 'RCHO', 'ZONA', 'AMPLIACION', 'AMP', 'U.H.', 'CONJ'
    ];

    for (String line in lines) {
      String upperLine = line.toUpperCase();
      for (String prefix in colonyPrefixes) {
        if (upperLine.startsWith(prefix)) {
          RegExp cpPattern = RegExp(r'\b\d{5}\b');
          Match? cpMatch = cpPattern.firstMatch(line);
          if (cpMatch != null) return line.substring(0, cpMatch.start).trim();
          return line.trim();
        }
      }
    }

    RegExp colonyPattern = RegExp(
        r'(COL\.|COLONIA|FRACC\.|FRACCIONAMIENTO|BARRIO)\s+([A-ZÁÉÍÓÚÜÑáéíóúüñ\s\.]+?)(?=\s+(?:C\.P\.|CP|CIUDAD|MUNICIPIO|\d{5})|\s*$)',
        caseSensitive: false);
    Match? colonyMatch = colonyPattern.firstMatch(text);
    if (colonyMatch != null) {
      return "${colonyMatch.group(1)} ${colonyMatch.group(2)}".trim();
    }

    return '';
  }

  static String _extractCity(String text) {
    List<String> lines = text.split('\n');

    if (lines.length >= 3) {
      String thirdLine = lines[2].trim().toUpperCase();
      int commaIndex = thirdLine.indexOf(',');
      if (commaIndex > 0) return thirdLine.substring(0, commaIndex).trim();
    }

    RegExp cityPattern = RegExp(
        r'(CIUDAD|MUNICIPIO|ALCALDIA|DELEGACION)\s+([A-ZÁÉÍÓÚÜÑáéíóúüñ\s\.]+?)(?=\s+(?:ESTADO|EDO\.)|\s*$)',
        caseSensitive: false);
    Match? cityMatch = cityPattern.firstMatch(text);
    if (cityMatch != null) return cityMatch.group(2)?.trim() ?? '';

    return '';
  }

  static String _extractState(String text) {
    Map<String, String> stateAbbr = {
      'CDMX': 'CIUDAD DE MEXICO', 'DF': 'CIUDAD DE MEXICO',
      'EDO DE MEX': 'ESTADO DE MEXICO', 'MEX': 'ESTADO DE MEXICO',
      'AGS': 'AGUASCALIENTES', 'BC': 'BAJA CALIFORNIA',
      'BCS': 'BAJA CALIFORNIA SUR', 'CAMP': 'CAMPECHE',
      'COAH': 'COAHUILA', 'COL': 'COLIMA', 'CHIS': 'CHIAPAS',
      'CHIH': 'CHIHUAHUA', 'DGO': 'DURANGO', 'GTO': 'GUANAJUATO',
      'GRO': 'GUERRERO', 'HGO': 'HIDALGO', 'JAL': 'JALISCO',
      'MICH': 'MICHOACAN', 'MOR': 'MORELOS', 'NAY': 'NAYARIT',
      'NL': 'NUEVO LEON', 'OAX': 'OAXACA', 'PUE': 'PUEBLA',
      'QRO': 'QUERETARO', 'QROO': 'QUINTANA ROO',
      'SLP': 'SAN LUIS POTOSI', 'SIN': 'SINALOA', 'SON': 'SONORA',
      'TAB': 'TABASCO', 'TAMPS': 'TAMAULIPAS', 'TLAX': 'TLAXCALA',
      'VER': 'VERACRUZ', 'YUC': 'YUCATAN', 'ZAC': 'ZACATECAS',
    };

    String upperText = text.toUpperCase();
    for (var entry in stateAbbr.entries) {
      if (upperText.contains(entry.key)) return entry.value;
    }

    List<String> lines = text.split('\n');
    if (lines.length >= 3) {
      String thirdLine = lines[2].trim().toUpperCase();
      int commaIndex = thirdLine.indexOf(',');
      if (commaIndex > 0 && commaIndex < thirdLine.length - 1) {
        String potentialState = thirdLine.substring(commaIndex + 1).trim();
        for (var entry in stateAbbr.entries) {
          if (potentialState.contains(entry.key)) return entry.value;
        }
        return potentialState;
      }
    }

    return '';
  }

  static String _normalizePostalCode(String cp) {
    String digitsOnly = cp.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '11000';
    if (digitsOnly.length < 5) return digitsOnly.padLeft(5, '0');
    if (digitsOnly.length > 5) return digitsOnly.substring(0, 5);
    return digitsOnly;
  }

  static String _extractNumericPart(String value) {
    RegExp numPattern = RegExp(r'\d+');
    Match? match = numPattern.firstMatch(value);
    return match?.group(0) ?? '1';
  }

  /// Reemplaza caracteres acentuados por su equivalente ASCII y elimina
  /// caracteres que no son aceptados en campos de dirección (estándar Pomelo).
  static String _sanitizeForPomelo(String value) {
    final normalized = value
        .replaceAll(RegExp(r'[áàâäã]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôöõ]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'ñ'), 'n')
        .replaceAll(RegExp(r'[ÁÀÂÄÃ]'), 'A')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
        .replaceAll(RegExp(r'[ÍÌÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÓÒÔÖÕ]'), 'O')
        .replaceAll(RegExp(r'[ÚÙÛÜ]'), 'U')
        .replaceAll(RegExp(r'Ñ'), 'N');

    return normalized.replaceAll(RegExp(r"[^a-zA-Z0-9 \-\.,°'#:]"), '');
  }

  static bool _isValidValue(String? value) {
    if (value == null || value.isEmpty) return false;
    if (value == 'S/I') return false;
    List<String> dummyPatterns = [
      'avenida principal', 'calle principal', 'street',
      'dummy', 'test', 'ejemplo', 'sin informacion',
      'no disponible', 'n/a', 'na'
    ];
    String lowerValue = value.toLowerCase().trim();
    return !dummyPatterns.any((pattern) => lowerValue.contains(pattern));
  }
}

/// Modelo para dirección parseada y estructurada.
class ParsedAddress {
  final String streetName;
  final String streetNumber;
  final String floor;
  final String apartment;
  final String postalCode;
  final String neighborhood;
  final String city;
  final String region;
  final String additionalInfo;
  final String country;

  ParsedAddress({
    required this.streetName,
    required this.streetNumber,
    required this.floor,
    required this.apartment,
    required this.postalCode,
    required this.neighborhood,
    required this.city,
    required this.region,
    required this.additionalInfo,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'street_name': streetName,
      'street_number': streetNumber,
      'floor': floor,
      'apartment': apartment,
      'zip_code': postalCode,
      'neighborhood': neighborhood,
      'city': city,
      'region': region,
      'additional_info': additionalInfo,
      'country': country,
    };
  }
}

class _ExtractedComponents {
  final String street;
  final String number;
  final String apartment;
  final String neighborhood;
  final String city;
  final String state;
  final String postalCode;

  _ExtractedComponents({
    required this.street,
    required this.number,
    required this.apartment,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.postalCode,
  });
}
