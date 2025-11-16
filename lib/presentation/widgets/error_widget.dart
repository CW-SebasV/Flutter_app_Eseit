import 'package:flutter/material.dart';
import 'package:contact_map/core/constants/strings.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              Strings.errorMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getUserFriendlyError(error),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('location') || error.contains('ubicación')) {
      return 'Error de ubicación. Verifica que tengas los permisos necesarios.';
    }
    if (error.contains('network') || error.contains('internet')) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    }
    if (error.contains('API') || error.contains('Google')) {
      return 'Error del servicio de búsqueda. Intenta más tarde.';
    }
    return error;
  }
}
