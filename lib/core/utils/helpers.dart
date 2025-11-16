import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contact_map/core/constants/strings.dart';

class Helpers {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String formatDistance(double? distance) {
    if (distance == null) return 'N/A';
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} ${Strings.km}';
  }

  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    if (cleaned.length == 10) {
      return '+52$cleaned';
    }
    return '+$cleaned';
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  // 🚀 NUEVA FUNCIÓN: abrir ubicación en mapas
  static Future<void> openMap(
    double lat,
    double lon, {
    String name = "",
  }) async {
    final encodedName = Uri.encodeComponent(name);

    // GEO (Android/iOS App)
    final Uri geoUri = Uri.parse("geo:$lat,$lon?q=$lat,$lon($encodedName)");

    // Google Maps (siempre funciona en navegador)
    final Uri googleUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lon");

    // OpenStreetMap (fallback)
    final Uri osmUrl = Uri.parse(
        "https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=16/$lat/$lon");

    try {
      // 1 - Intento app de mapas nativa
      if (await launchUrl(geoUri, mode: LaunchMode.externalApplication)) {
        return;
      }

      // 2 - Google Maps navegador (NO usa canLaunchUrl porque a veces falla)
      if (await launchUrl(googleUrl, mode: LaunchMode.externalApplication)) {
        return;
      }

      // 3 - fallback OSM
      await launchUrl(osmUrl, mode: LaunchMode.externalApplication);

    } catch (e) {
      debugPrint("❌ openMap error: $e");
    }
  }

}
