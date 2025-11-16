import 'package:contact_map/domain/entities/place_entity.dart';

class PlaceModel extends PlaceEntity {
  PlaceModel({
    required super.id,
    required super.name,
    super.address,
    super.phoneNumber,
    required super.lat,
    required super.lng,
    super.distanceFromUser,
  }) : super(
          rating: null,
        );

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};

    final String? phone =
        tags['contact:whatsapp'] as String? ?? tags['phone'] as String?;

    final String? street = tags['addr:street'] as String?;
    final String? housenumber = tags['addr:housenumber'] as String?;

    String? address;
    if (street != null && housenumber != null) {
      address = '$street $housenumber';
    } else if (street != null) {
      address = street;
    } else {
      address = tags['addr:full'] as String?;
    }

    return PlaceModel(
      id: json['id'].toString(),
      name: tags['name'] as String? ?? 'Negocio sin nombre',
      lat: (json['lat'] as num?)?.toDouble() ??
          (json['center']?['lat'] as num?)?.toDouble() ??
          0.0,
      lng: (json['lon'] as num?)?.toDouble() ??
          (json['center']?['lon'] as num?)?.toDouble() ??
          0.0,
      phoneNumber: phone,
      address: address,
    );
  }

  PlaceModel copyWith({
    double? distanceFromUser,
  }) {
    return PlaceModel(
      id: id,
      name: name,
      address: address,
      phoneNumber: phoneNumber,
      lat: lat,
      lng: lng,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
    );
  }
}
