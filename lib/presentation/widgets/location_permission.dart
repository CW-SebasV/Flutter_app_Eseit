import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionWidget extends StatelessWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const LocationPermissionWidget({
    super.key,
    required this.onPermissionGranted,
    this.onPermissionDenied,
  });

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      onPermissionGranted();
    } else {
      onPermissionDenied?.call();
    }
  }

  void _openAppSettings() {
    openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Ubicación requerida',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Para encontrar negocios cercanos, necesitamos acceso a tu ubicación.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Permitir ubicación'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _openAppSettings,
                child: const Text('Configurar en Ajustes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
