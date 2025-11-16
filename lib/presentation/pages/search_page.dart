import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contact_map/presentation/providers/place_provider.dart';
import 'package:contact_map/presentation/widgets/place_card.dart';
import 'package:contact_map/presentation/widgets/loading_widget.dart';
import 'package:contact_map/presentation/widgets/error_widget.dart';
import 'package:contact_map/core/constants/strings.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PlaceProvider>(context, listen: false);
      // Puedes cargar historial de búsquedas aquí si lo implementas
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    final provider = Provider.of<PlaceProvider>(context, listen: false);
    provider.searchPlaces(query);
    // Guardar en historial
    // LocalStorage().saveSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PlaceProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: Strings.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearResults();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: _performSearch,
                ),
                const SizedBox(height: 16),
                // Radio de búsqueda
                if (provider.currentLocation != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubicación actual',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${provider.currentLocation!.latitude!.toStringAsFixed(4)}, '
                            'Lng: ${provider.currentLocation!.longitude!.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Resultados
                Expanded(
                  child: _buildResults(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults(PlaceProvider provider) {
    if (provider.isLoading) {
      return const LoadingWidget();
    }

    if (provider.error.isNotEmpty) {
      return CustomErrorWidget(
        error: provider.error,
        onRetry: () {
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        },
      );
    }

    if (provider.places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Ingresa un término de búsqueda'
                  : Strings.noResults,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.places.length,
      itemBuilder: (context, index) {
        final place = provider.places[index];
        return PlaceCard(place: place);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}