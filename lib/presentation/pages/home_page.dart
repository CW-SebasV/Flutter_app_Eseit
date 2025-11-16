import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contact_map/presentation/providers/place_provider.dart';
import 'package:contact_map/presentation/widgets/search_bar.dart';
import 'package:contact_map/presentation/widgets/distance_slider.dart';
import 'package:contact_map/presentation/widgets/place_card.dart';
import 'package:contact_map/presentation/widgets/loading_widget.dart';
import 'package:contact_map/presentation/widgets/error_widget.dart';
import 'package:contact_map/presentation/widgets/location_permission.dart';
import 'package:contact_map/core/constants/strings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appTitle),
      ),
      body: Consumer<PlaceProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const LoadingWidget(message: 'Inicializando...');
          }

          if (!provider.hasLocationPermission) {
            return LocationPermissionWidget(
              onPermissionGranted: () {
                provider.initialize();
              },
            );
          }

          if (provider.isLocationLoading) {
            return const LoadingWidget(message: 'Obteniendo ubicación...');
          }

          return _buildSearchUI(context, provider);
        },
      ),
    );
  }

  Widget _buildSearchUI(BuildContext context, PlaceProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomSearchBar(
            onSearch: (query) {
              provider.searchPlaces(query);
            },
          ),
          const SizedBox(height: 16),
          const DistanceSlider(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildResultsList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(PlaceProvider provider) {
    if (provider.isLoading) {
      return const LoadingWidget();
    }

    if (provider.error.isNotEmpty) {
      return CustomErrorWidget(
        error: provider.error,
        onRetry: () {
          provider.retryLastAction();
        },
      );
    }

    if (provider.places.isEmpty) {
      if (provider.hasSearched) {
        return const Center(child: Text(Strings.noResults));
      } else {
        return const Center(
            child: Text('Busca negocios para comenzar'));
      }
    }

    return ListView.builder(
      itemCount: provider.places.length,
      itemBuilder: (context, index) {
        return PlaceCard(place: provider.places[index]);
      },
    );
  }
}