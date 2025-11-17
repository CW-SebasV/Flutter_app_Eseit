import 'package:flutter_test/flutter_test.dart';
import 'package:contact_map/domain/entities/place_entity.dart';
// Necesitarás mockito o una clase mock manual

// --- INICIO DEL HACK ---
// Imposible importar _relevanceScore de PlacesRepositoryImpl.
// Copiamos la lógica aquí para probarla.
// En un proyecto real, ESTA LÓGICA DEBE SER PÚBLICA Y ESTAR EN SU PROPIA CLASE.

/// Lógica copiada de PlacesRepositoryImpl._relevanceScore
int calculateTestRelevanceScore(PlaceEntity place, String kw) {
  int score = 0;
  final name = place.name.toLowerCase();
  final hasPhone = place.phoneNumber != null && place.phoneNumber!.isNotEmpty;

  // Kw debe estar limpiado igual que en el original
  final cleanKw = kw.trim().toLowerCase();

  // Exact match
  if (cleanKw.isNotEmpty && name == cleanKw) score += 50;
  // Starts with
  if (cleanKw.isNotEmpty && name.startsWith(cleanKw)) score += 30;
  // Contains
  if (cleanKw.isNotEmpty && name.contains(cleanKw)) score += 20;
  // Phone / Whatsapp priority
  if (hasPhone) score += 15;
  return score;
}
// --- FIN DEL HACK ---

// Mock manual de PlaceEntity para evitar dependencias completas
class MockPlaceEntity implements PlaceEntity {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? address;
  @override
  final double? distanceFromUser;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final String? phoneNumber;
  @override
  final double? rating;

  MockPlaceEntity({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.address,
    this.distanceFromUser,
    this.lat = 0.0,
    this.lng = 0.0,
    this.rating,
  });
}

void main() {
  group('Lógica de Relevancia (_relevanceScore)', () {
    const keyword = 'pizza';

    test(
        'debe dar más puntos a "match exacto + teléfono" que a "match parcial sin teléfono"',
        () {
      // 1. Arrange: Mock de "match exacto + teléfono"
      final exactMatchPhone = MockPlaceEntity(
        id: '1',
        name: 'Pizza', // Match exacto
        phoneNumber: '123456789', // Tiene teléfono
      );

      // 2. Arrange: Mock de "match parcial sin teléfono"
      final partialMatchNoPhone = MockPlaceEntity(
        id: '2',
        name: 'Pizza Hut', // Match parcial (empieza con)
        phoneNumber: null, // Sin teléfono
      );

      // 3. Act: Calcular scores usando la lógica copiada
      // 'pizza' == 'pizza' -> 50 (exact)
      // 'pizza hut'.startsWith('pizza') -> 30 (starts with)
      // 'pizza hut'.contains('pizza') -> 20 (contains)
      // TOTAL:
      // Score A (Pizza) = 50 (exact) + 30 (starts) + 20 (contains) + 15 (phone) = 115
      final scoreA = calculateTestRelevanceScore(exactMatchPhone, keyword);

      // Score B (Pizza Hut) = 30 (starts) + 20 (contains) + 0 (no phone) = 50
      final scoreB = calculateTestRelevanceScore(partialMatchNoPhone, keyword);

      // 4. Assert
      print('Score Match Exacto + Teléfono: $scoreA'); // 115
      print('Score Match Parcial + Sin Teléfono: $scoreB'); // 50
      expect(scoreA, greaterThan(scoreB));
    });

    test('debe priorizar "starts with" sobre "contains"', () {
      final startsWith = MockPlaceEntity(
        id: '1',
        name: 'Pizza House', // Starts with
        phoneNumber: null, // Mismo teléfono (null)
      );

      final contains = MockPlaceEntity(
        id: '2',
        name: 'La Mejor Pizza', // Contains
        phoneNumber: null, // Mismo teléfono (null)
      );

      // Score A (Pizza House) = 30 (starts) + 20 (contains) = 50
      final scoreA = calculateTestRelevanceScore(startsWith, keyword);

      // Score B (La Mejor Pizza) = 20 (contains) = 20
      final scoreB = calculateTestRelevanceScore(contains, keyword);

      print('Score Starts With: $scoreA'); // 50
      print('Score Contains: $scoreB'); // 20
      expect(scoreA, greaterThan(scoreB));
    });

    test('debe añadir 15 puntos por tener cualquier teléfono', () {
      final withPhone = MockPlaceEntity(
        id: '1',
        name: 'Lugar',
        phoneNumber: '1', // Tiene teléfono
      );

      final withoutPhone = MockPlaceEntity(
        id: '2',
        name: 'Lugar',
        phoneNumber: null, // Sin teléfono
      );

      // (Keyword está vacía, así que solo cuenta el teléfono)
      final scoreA = calculateTestRelevanceScore(withPhone, '');
      final scoreB = calculateTestRelevanceScore(withoutPhone, '');

      print('Score Con Teléfono: $scoreA'); // 15
      print('Score Sin Teléfono: $scoreB'); // 0
      expect(scoreA, scoreB + 15);
    });
  });
}
