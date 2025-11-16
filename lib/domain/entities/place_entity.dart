class PlaceEntity {
  final String id;
  final String name;
  final double? rating;
  final String? address;
  final String? phoneNumber;
  final double lat;
  final double lng;
  final double? distanceFromUser;

  PlaceEntity({
    required this.id,
    required this.name,
    this.rating,
    this.address,
    this.phoneNumber,
    required this.lat,
    required this.lng,
    this.distanceFromUser,
  });
}
