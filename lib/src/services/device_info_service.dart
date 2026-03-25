import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Servicio para obtener información del dispositivo en Android e iOS.
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Obtiene información completa del dispositivo.
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceInfo();
      } else {
        return {'error': 'Plataforma no soportada'};
      }
    } catch (e) {
      return {'error': 'Error al obtener información del dispositivo: $e'};
    }
  }

  static Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    return {
      'platform': 'Android',
      'brand': androidInfo.brand,
      'model': androidInfo.model,
      'manufacturer': androidInfo.manufacturer,
      'product': androidInfo.product,
      'device': androidInfo.device,
      'androidId': androidInfo.id,
      'version': {
        'release': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'codename': androidInfo.version.codename,
        'incremental': androidInfo.version.incremental,
      },
      'board': androidInfo.board,
      'bootloader': androidInfo.bootloader,
      'hardware': androidInfo.hardware,
      'fingerprint': androidInfo.fingerprint,
      'host': androidInfo.host,
      'tags': androidInfo.tags,
      'type': androidInfo.type,
      'isPhysicalDevice': androidInfo.isPhysicalDevice,
      'supportedAbis': androidInfo.supportedAbis,
      'supported32BitAbis': androidInfo.supported32BitAbis,
      'supported64BitAbis': androidInfo.supported64BitAbis,
    };
  }

  static Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    return {
      'platform': 'iOS',
      'name': iosInfo.name,
      'model': iosInfo.model,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'localizedModel': iosInfo.localizedModel,
      'identifierForVendor': iosInfo.identifierForVendor,
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
      'utsname': {
        'sysname': iosInfo.utsname.sysname,
        'nodename': iosInfo.utsname.nodename,
        'release': iosInfo.utsname.release,
        'version': iosInfo.utsname.version,
        'machine': iosInfo.utsname.machine,
      },
    };
  }

  /// Obtiene información básica del dispositivo (marca, modelo, SO).
  static Future<Map<String, String>> getBasicDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return {
          'platform': 'Android',
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkVersion': androidInfo.version.sdkInt.toString(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return {
          'platform': 'iOS',
          'brand': 'Apple',
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'version': iosInfo.systemVersion,
          'sdkVersion': iosInfo.systemVersion,
        };
      } else {
        return {
          'platform': 'Unknown',
          'brand': 'Unknown',
          'model': 'Unknown',
          'manufacturer': 'Unknown',
          'version': 'Unknown',
          'sdkVersion': 'Unknown',
        };
      }
    } catch (e) {
      return {
        'platform': 'Error',
        'brand': 'Error',
        'model': 'Error',
        'manufacturer': 'Error',
        'version': 'Error',
        'sdkVersion': 'Error',
      };
    }
  }

  /// Obtiene el identificador único del dispositivo.
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      } else {
        return 'unknown';
      }
    } catch (e) {
      return 'error';
    }
  }

  /// Verifica si es un dispositivo físico o emulador/simulador.
  static Future<bool> isPhysicalDevice() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.isPhysicalDevice;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
