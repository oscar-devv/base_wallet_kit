// ignore_for_file: unused_field, prefer_final_fields, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio de ubicación con carga diferida — obtiene la ubicación solo cuando
/// se necesita (ej: durante el proceso de login o KYC).
class LazyLocationService {
  static final LazyLocationService _instance = LazyLocationService._internal();
  factory LazyLocationService() => _instance;
  LazyLocationService._internal();

  bool _permissionRequested = false;
  bool _hasPermission = false;

  /// Obtiene la ubicación solo cuando se necesita.
  ///
  /// Returns: Map con claves 'success', 'latitude', 'longitude', 'accuracy',
  /// 'timestamp' y 'error'.
  Future<Map<String, dynamic>> getLocationWhenNeeded() async {
    try {
      if (kDebugMode) print('📍 LazyLocationService: Verificando servicios de ubicación...');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('⚠️ LazyLocationService: Servicios de ubicación deshabilitados');
        return _buildErrorResponse('Servicios de ubicación deshabilitados');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        if (kDebugMode) print('📍 LazyLocationService: Solicitando permisos de ubicación...');
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('❌ LazyLocationService: Permisos denegados permanentemente');
        return _buildErrorResponse('Permisos de ubicación denegados permanentemente');
      }

      if (permission == LocationPermission.denied) {
        if (kDebugMode) print('❌ LazyLocationService: Permisos denegados');
        return _buildErrorResponse('Permisos de ubicación denegados');
      }

      if (kDebugMode) print('📍 LazyLocationService: Obteniendo ubicación actual...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (kDebugMode) {
        print('✅ LazyLocationService: Ubicación obtenida: ${position.latitude}, ${position.longitude}');
      }

      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now(),
        'error': null,
      };
    } catch (e) {
      if (kDebugMode) print('❌ LazyLocationService: Error obteniendo ubicación: $e');
      return _buildErrorResponse(e.toString());
    }
  }

  /// Verifica permisos sin solicitarlos.
  Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _buildErrorResponse(String error) {
    return {
      'success': false,
      'latitude': null,
      'longitude': null,
      'accuracy': null,
      'timestamp': DateTime.now(),
      'error': error,
    };
  }
}
