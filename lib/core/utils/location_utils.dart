import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationUtils {
  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Verificar permisos primero
      final status = await Permission.location.status;
      if (!status.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          throw Exception('Permiso de ubicación denegado por el usuario');
        }
      }

      Location location = Location();

      // Verificar si el servicio está habilitado
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('Servicio de ubicación no disponible');
        }
      }

      // Obtener ubicación actual
      return await location.getLocation();
    } catch (e) {
      throw Exception('Error obteniendo ubicación: ${e.toString()}');
    }
  }

  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
}
