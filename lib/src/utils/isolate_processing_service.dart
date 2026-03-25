// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Servicio para procesar operaciones pesadas en isolates,
/// evitando bloquear el hilo principal de la UI.
class IsolateProcessingService {
  /// Convierte bytes de video a Base64 en un isolate.
  ///
  /// Útil para videos grandes (2 MB+) que bloquearían el hilo principal.
  static Future<String> convertVideoToBase64(String videoPath) async {
    if (kDebugMode) print('🔄 [Isolate] Iniciando conversión de video a Base64...');

    final videoBytes = await File(videoPath).readAsBytes();

    if (kDebugMode) {
      final sizeMB = videoBytes.length / 1024 / 1024;
      print('📁 [Isolate] Tamaño del video: ${sizeMB.toStringAsFixed(2)} MB');
    }

    final base64String = await compute(_encodeBytesToBase64, videoBytes);

    if (kDebugMode) print('✅ [Isolate] Video convertido: ${base64String.length} caracteres');

    return base64String;
  }

  /// Procesa una imagen (decodificar, redimensionar, comprimir) y la convierte
  /// a Base64 en un isolate.
  static Future<String> processImageToBase64(String imagePath) async {
    if (kDebugMode) print('🔄 [Isolate] Iniciando procesamiento de imagen...');

    final imageBytes = await File(imagePath).readAsBytes();

    if (kDebugMode) {
      final sizeMB = imageBytes.length / 1024 / 1024;
      print('📁 [Isolate] Tamaño original: ${sizeMB.toStringAsFixed(2)} MB');
    }

    final base64String = await compute(_processImageBytes, imageBytes);

    if (kDebugMode) print('✅ [Isolate] Imagen procesada y convertida a Base64');

    return base64String;
  }

  /// Convierte un archivo a Base64 en un isolate.
  static Future<String> convertFileToBase64(String filePath) async {
    if (kDebugMode) print('🔄 [Isolate] Iniciando conversión de archivo a Base64...');

    final bytes = await File(filePath).readAsBytes();

    if (kDebugMode) {
      final sizeMB = bytes.length / 1024 / 1024;
      print('📁 [Isolate] Tamaño del archivo: ${sizeMB.toStringAsFixed(2)} MB');
    }

    final base64String = await compute(_encodeBytesToBase64, bytes);

    if (kDebugMode) print('✅ [Isolate] Archivo convertido: ${base64String.length} caracteres');

    return base64String;
  }

  /// Convierte múltiples archivos a Base64 en paralelo usando isolates.
  ///
  /// [filePaths] mapa de clave → ruta del archivo.
  static Future<Map<String, String>> convertFilesToBase64Batch(
    Map<String, String> filePaths,
  ) async {
    if (kDebugMode) {
      print('🔄 [Isolate] Iniciando conversión batch de ${filePaths.length} archivos...');
    }

    final futures = filePaths.entries.map((entry) async {
      try {
        final base64 = await convertFileToBase64(entry.value);
        return MapEntry(entry.key, base64);
      } catch (e) {
        if (kDebugMode) print('❌ [Isolate] Error al procesar ${entry.key}: $e');
        return MapEntry(entry.key, '');
      }
    });

    final results = await Future.wait(futures);
    final resultMap = Map<String, String>.fromEntries(results);

    if (kDebugMode) print('✅ [Isolate] Batch completado: ${resultMap.length} archivos procesados');

    return resultMap;
  }
}

/// Función pura para convertir bytes a Base64 (se ejecuta en isolate).
String _encodeBytesToBase64(Uint8List bytes) {
  return base64Encode(bytes);
}

/// Función pura para procesar imagen en isolate.
/// Decodifica, redimensiona (mín 400px, máx 1200px) y comprime a JPEG 95%.
String _processImageBytes(Uint8List originalBytes) {
  final originalImage = img.decodeImage(originalBytes);
  if (originalImage == null) {
    throw Exception('No se pudo decodificar la imagen');
  }

  int targetWidth = originalImage.width;
  int targetHeight = originalImage.height;

  if (originalImage.width < 400 || originalImage.height < 400) {
    double widthScale = 400.0 / originalImage.width;
    double heightScale = 400.0 / originalImage.height;
    double scaleFactor = widthScale > heightScale ? widthScale : heightScale;
    targetWidth = (originalImage.width * scaleFactor).round();
    targetHeight = (originalImage.height * scaleFactor).round();
  }

  if (targetWidth < 400) targetWidth = 400;
  if (targetHeight < 400) targetHeight = 400;

  if (targetWidth > 1200 || targetHeight > 1200) {
    double reductionFactor =
        1200.0 / (targetWidth > targetHeight ? targetWidth : targetHeight);
    targetWidth = (targetWidth * reductionFactor).round();
    targetHeight = (targetHeight * reductionFactor).round();
    if (targetWidth < 400) targetWidth = 400;
    if (targetHeight < 400) targetHeight = 400;
  }

  final resizedImage = img.copyResize(
    originalImage,
    width: targetWidth,
    height: targetHeight,
    interpolation: img.Interpolation.cubic,
  );

  final compressedBytes = img.encodeJpg(resizedImage, quality: 95);
  return base64Encode(compressedBytes);
}
