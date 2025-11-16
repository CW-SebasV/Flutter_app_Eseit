import 'package:dartz/dartz.dart';
import 'package:contact_map/domain/entities/place_entity.dart';
import 'package:contact_map/core/errors/failures.dart';

abstract class PlacesRepository {
  Future<Either<Failure, List<PlaceEntity>>> searchPlaces({
    required double lat,
    required double lng,
    required double radius,
    required String keyword,
  });
}
