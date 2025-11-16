import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contact_map/domain/entities/place_entity.dart';
import 'package:contact_map/core/constants/strings.dart';
import 'package:contact_map/core/utils/helpers.dart';
import 'package:contact_map/presentation/styles/colors.dart';

class DetailsPage extends StatelessWidget {
  final PlaceEntity place;
  const DetailsPage({super.key, required this.place});

  void _launchWhatsApp(BuildContext context, String phoneNumber) async {
    final formattedPhone = Helpers.formatPhoneNumber(phoneNumber);
    final url = Uri.parse('https://wa.me/$formattedPhone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        Helpers.showSnackBar(context, 'No se pudo abrir WhatsApp',
            isError: true);
      }
    }
  }

  void _launchMaps(BuildContext context) async {
    final lat = place.lat;
    final lon = place.lng;
    final name = Uri.encodeComponent(place.name);

    // 1. Geo URI (Android nativo)
    final Uri geoUri = Uri.parse("geo:$lat,$lon?q=$lat,$lon($name)");

    // 2. Google Maps URL
    final Uri googleUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lon");

    // 3. OSM URL
    final Uri osmUri = Uri.parse(
        "https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=16/$lat/$lon");

    try {
      // INTENTO 1 → Aplicación nativa
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }

      // INTENTO 2 → Google Maps app o navegador
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(
          googleUri,
          mode: LaunchMode.platformDefault, // ← Más compatible
        );
        return;
      }

      // INTENTO 3 → Navegador con OSM
      if (await canLaunchUrl(osmUri)) {
        await launchUrl(
          osmUri,
          mode: LaunchMode.platformDefault, // ← evita el error de component null
        );
        return;
      }

      Helpers.showSnackBar(context, 'No se encontró una aplicación para abrir mapas', isError: true);
    } catch (e) {
      Helpers.showSnackBar(context, 'Error al abrir mapas', isError: true);
    }
  }


  void _callPhone(BuildContext context, String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        Helpers.showSnackBar(context, 'No se pudo realizar la llamada',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
              onPressed: () => Helpers.openMap(
              place.lat,
              place.lng,
              name: place.name,
            ),
            tooltip: 'Ver en mapa',
          ),

        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Información básica ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    // OSM no tiene ratings, así que omitimos esa sección

                    // Dirección
                    if (place.address != null && place.address!.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              place.address!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Distancia
                    if (place.distanceFromUser != null) ...[
                       Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.directions_walk,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Aprox. ${Helpers.formatDistance(place.distanceFromUser)} de distancia',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Teléfono
                    if (place.phoneNumber != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            place.phoneNumber!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // --- Acciones ---
            if (place.phoneNumber != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _launchWhatsApp(context, place.phoneNumber!),
                          // FIX: Cambiado 'Icons.whatsapp' (que no existe) por 'Icons.chat'
                          icon: const Icon(Icons.chat, color: Colors.white), // Icono estándar
                          label: const Text(
                            Strings.openWhatsApp,
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whatsappGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _callPhone(context, place.phoneNumber!),
                          icon: const Icon(Icons.phone),
                          label: const Text('Llamar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}