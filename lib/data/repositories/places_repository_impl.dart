import 'package:dartz/dartz.dart';
import 'package:contact_map/domain/repositories/places_repository.dart';
import 'package:contact_map/data/datasources/overpass_api_datasource.dart';
import 'package:contact_map/domain/entities/place_entity.dart';
import 'package:contact_map/core/errors/failures.dart';
import 'package:contact_map/core/errors/exceptions.dart';
import 'package:contact_map/core/utils/helpers.dart';
import 'dart:io';

class PlacesRepositoryImpl implements PlacesRepository {
  final IOverpassApiDatasource apiDatasource;

  PlacesRepositoryImpl({required this.apiDatasource});

  @override
  Future<Either<Failure, List<PlaceEntity>>> searchPlaces({
    required double lat,
    required double lng,
    required double radius,
    required String keyword,
  }) async {
    try {
      final placeModels = await apiDatasource.searchNearbyPlaces(
        lat: lat,
        lng: lng,
        radius: radius,
        keyword: keyword,
      );

      final String kw = keyword.trim().toLowerCase();

      // -----------------------------
      // 1. Calcular distancias
      // -----------------------------
      List<PlaceEntity> places = placeModels.map((model) {
        final distance = Helpers.calculateDistance(lat, lng, model.lat, model.lng);
        return model.copyWith(distanceFromUser: distance);
      }).toList();

      // -----------------------------
      // 2. Eliminar duplicados por ID o coordenadas
      // -----------------------------
      final seen = <String>{};
      places = places.where((p) {
        final key = "${p.id}-${p.lat}-${p.lng}";
        if (seen.contains(key)) return false;
        seen.add(key);
        return true;
      }).toList();

      // -----------------------------
      // 3. Filtrado por keyword (si existe)
      // -----------------------------
      if (kw.isNotEmpty) {
        places = places.where((p) {
          final name = p.name.toLowerCase();
          return name.contains(kw);
        }).toList();
      }

      // -----------------------------
      // 4. Filtrar lugares “inútiles” (sin nombre real)
      // -----------------------------
      places = places.where((p) {
        final n = p.name.toLowerCase();
        return n.isNotEmpty &&
               n != "yes" &&
               n != "no" &&
               n != "unknown";
      }).toList();

      // -----------------------------
      // 5. Orden avanzado:
      //    a) Coincidencia exacta
      //    b) Coincidencia parcial
      //    c) Teléfono / WhatsApp
      //    d) Distancia
      // -----------------------------
      places.sort((a, b) {
        int scoreA = _relevanceScore(a, kw);
        int scoreB = _relevanceScore(b, kw);

        if (scoreA != scoreB) return scoreB - scoreA;  // mayor primero

        // distancia cuando relevancia es igual
        return (a.distanceFromUser ?? double.infinity)
            .compareTo(b.distanceFromUser ?? double.infinity);
      });

      return Right(places);

    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));

    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));

    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));

    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet.'));

    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  // ------------------------------------------------------------
  // 🎯 Sistema de relevancia tipo "WhatsApp Maps"
  // ------------------------------------------------------------
  int _relevanceScore(PlaceEntity place, String kw) {
    int score = 0;

    final name = place.name.toLowerCase();
    final hasPhone = place.phoneNumber != null && place.phoneNumber!.isNotEmpty;

    // Exact match
    if (kw.isNotEmpty && name == kw) score += 50;

    // Starts with
    if (kw.isNotEmpty && name.startsWith(kw)) score += 30;

    // Contains
    if (kw.isNotEmpty && name.contains(kw)) score += 20;

    // Phone / Whatsapp priority
    if (hasPhone) score += 15;

    return score;
  }
}
