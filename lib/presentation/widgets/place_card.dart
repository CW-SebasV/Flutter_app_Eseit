import 'package:contact_map/domain/entities/place_entity.dart';
import 'package:contact_map/presentation/pages/details_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contact_map/core/constants/strings.dart';
import 'package:contact_map/core/utils/helpers.dart';
import 'package:contact_map/presentation/styles/colors.dart';

class PlaceCard extends StatelessWidget {
  final PlaceEntity place;
  const PlaceCard({super.key, required this.place});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsPage(place: place)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 8),

              // Dirección (si existe)
              if (place.address != null && place.address!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.address!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              
              // Distancia (si existe)
              if (place.distanceFromUser != null) ...[
                 Row(
                  children: [
                    Icon(Icons.directions_walk,
                        color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      Helpers.formatDistance(place.distanceFromUser),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],

              // Botón de WhatsApp (si tiene número)
              if (place.phoneNumber != null &&
                  place.phoneNumber!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(context, place.phoneNumber!),
                  // FIX: Cambiado 'Icons.whatsapp' (que no existe) por 'Icons.chat'
                  icon: const Icon(Icons.chat, color: Colors.white), // Icono estándar
                  label: const Text(
                    Strings.openWhatsApp,
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsappGreen,
                  ),
                ),
              ] else ...[
                 const SizedBox(height: 12),
                 Text(
                  'No se encontró número de WhatsApp',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic
                  ),
                 )
              ]
            ],
          ),
        ),
      ),
    );
  }
}