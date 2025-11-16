import 'dart:convert';
import 'package:contact_map/core/constants/app_constants.dart';
import 'package:contact_map/core/errors/exceptions.dart';
import 'package:contact_map/data/models/place_model.dart';
import 'package:http/http.dart' as http;

abstract class IOverpassApiDatasource {
  Future<List<PlaceModel>> searchNearbyPlaces({
    required double lat,
    required double lng,
    required double radius,
    required String keyword,
  });
}

class OverpassApiDatasource implements IOverpassApiDatasource {
  final http.Client client;
  const OverpassApiDatasource(this.client);

  @override
  Future<List<PlaceModel>> searchNearbyPlaces({
    required double lat,
    required double lng,
    required double radius,
    required String keyword,
  }) async {
    final double radiusInMeters = radius * 1000;

    // --- CORRECCIÓN ---
    // La sintaxis (has_tag("phone")_or_has_tag("contact:whatsapp")) no es válida en Overpass QL.
    // La forma correcta de buscar "elementos que tengan 'phone' O 'contact:whatsapp'"
    // es usar una unión (los paréntesis internos) para cada tipo de elemento (node, way, relation).
    final String query = """
    [out:json][timeout:25];

    // Buscar lugares dentro del radio
    (
      node(around:$radiusInMeters,$lat,$lng)["name"];
      way(around:$radiusInMeters,$lat,$lng)["name"];
      relation(around:$radiusInMeters,$lat,$lng)["name"];
    );

    // Devuelve geometría y centro
    out body center;
    """;
    // --- FIN DE LA CORRECCIÓN ---

    try {
      final response = await client.post(
        Uri.parse(AppConstants.overpassApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: 'data=$query',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> elements = data['elements'] as List<dynamic>;
        final List<PlaceModel> places = elements
            .map((json) => PlaceModel.fromJson(json))
            .where((place) => place.lat != 0.0)
            .toList();
        return places;
      } else if (response.statusCode == 400) {
        // Este es el error que estás viendo.
        throw ServerException(
            'Consulta inválida (Bad Request). Revisa la query de Overpass.');
      } else if (response.statusCode == 429) {
        throw ServerException(
            'Demasiadas peticiones. Intenta de nuevo más tarde.');
      } else {
        throw ServerException(
            'Error del servidor de Overpass: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}