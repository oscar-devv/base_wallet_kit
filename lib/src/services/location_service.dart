// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio para obtener la ubicación geográfica real del dispositivo.
/// Utilizado por procesos KYC para registrar la ubicación de la verificación.
class LocationService {
  static LocationService? _instance;

  LocationService._();

  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  /// Coordenadas por defecto (Ciudad de México).
  /// Se usan como fallback si no se puede obtener la ubicación real.
  static const double _defaultLatitude = 19.432608;
  static const double _defaultLongitude = -99.133209;

  /// Obtiene la ubicación actual del dispositivo.
  ///
  /// Returns: Map con 'latitude' y 'longitude' como double.
  /// Si no se puede obtener la ubicación, retorna coordenadas por defecto.
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      if (kDebugMode) print('📍 Iniciando obtención de ubicación...');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('⚠️ Servicios de ubicación deshabilitados - usando ubicación por defecto');
        return _getDefaultLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) print('⚠️ Permisos de ubicación denegados - usando ubicación por defecto');
          return _getDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('⚠️ Permisos de ubicación denegados permanentemente - usando ubicación por defecto');
        return _getDefaultLocation();
      }

      if (kDebugMode) print('🔍 Obteniendo ubicación actual...');

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      if (kDebugMode) {
        print('✅ Ubicación obtenida: lat=${position.latitude}, lng=${position.longitude}');
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      if (kDebugMode) print('❌ Error al obtener ubicación: $e');
      return _getDefaultLocation();
    }
  }

  Map<String, double> _getDefaultLocation() {
    return {
      'latitude': _defaultLatitude,
      'longitude': _defaultLongitude,
    };
  }

  /// Verifica si se pueden obtener los permisos de ubicación.
  Future<bool> canGetLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
      LocationPermission permission = await Geolocator.checkPermission();
      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  /// Solicita permisos de ubicación si no están concedidos.
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }
}
