// ignore_for_file: avoid_print

/// Ejemplo básico de uso del paquete `base_wallet_kit`.
///
/// Muestra cómo:
/// - Inicializar [ApiUrlManager] para obtener la URL base desde Remote Config.
/// - Crear una instancia de [Dio] pre-configurada con [ApiDioFactory].
/// - Parsear una dirección de INE con [AddressParserService].
library base_wallet_kit_example;

import 'package:base_wallet_kit/base_wallet_kit.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la URL base desde Firebase Remote Config.
  // Si Firebase no está disponible, usa la URL primaria como fallback.
  await ApiUrlManager.instance.initialize();
  print('URL activa: ${ApiUrlManager.instance.currentBaseUrl}');

  // Crea un cliente Dio con interceptores estándar.
  final dio = ApiDioFactory.create();
  print('Dio listo: ${dio.options.connectTimeout}');

  // Parsea una dirección de ejemplo proveniente de OCR de INE.
  final address = AddressParserService.parseAddress(
    ocrStreet: 'AV. INSURGENTES SUR',
    ocrStreetNumber: '1602',
    ocrColony: 'COL. CREDITO CONSTRUCTOR',
    ocrMunicipality: 'BENITO JUAREZ',
    ocrState: 'CDMX',
    ocrPostalCode: '03940',
  );

  print('Dirección parseada:');
  print('  Calle: ${address.streetName}');
  print('  Número: ${address.streetNumber}');
  print('  Colonia: ${address.neighborhood}');
  print('  Ciudad: ${address.city}');
  print('  Estado: ${address.region}');
  print('  CP: ${address.postalCode}');
  print('  País: ${address.country}');

  runApp(const ExampleApp());
}

/// Aplicación de ejemplo que muestra los resultados del parseo de dirección.
class ExampleApp extends StatelessWidget {
  /// Crea una instancia de [ExampleApp].
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final address = AddressParserService.parseAddress(
      ocrStreet: 'AV. INSURGENTES SUR',
      ocrStreetNumber: '1602',
      ocrColony: 'COL. CREDITO CONSTRUCTOR',
      ocrMunicipality: 'BENITO JUAREZ',
      ocrState: 'CDMX',
      ocrPostalCode: '03940',
    );

    return MaterialApp(
      title: 'base_wallet_kit – Ejemplo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('base_wallet_kit – Ejemplo'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dirección parseada con AddressParserService',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _AddressRow(label: 'Calle', value: address.streetName),
              _AddressRow(label: 'Número', value: address.streetNumber),
              _AddressRow(label: 'Colonia', value: address.neighborhood),
              _AddressRow(label: 'Ciudad', value: address.city),
              _AddressRow(label: 'Estado', value: address.region),
              _AddressRow(label: 'CP', value: address.postalCode),
              _AddressRow(label: 'País', value: address.country),
              const SizedBox(height: 32),
              const Text(
                'URL base (ApiUrlManager)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(ApiUrlManager.instance.currentBaseUrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String label;
  final String value;

  const _AddressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
