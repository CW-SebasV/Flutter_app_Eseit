import 'package:contact_map/domain/entities/place_entity.dart';
import 'package:contact_map/domain/repositories/places_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:contact_map/main.dart';
import 'package:contact_map/core/errors/failures.dart';

// Solución: Crear una implementación "Mock" (falsa) del repositorio para usarla en el test.
class MockPlacesRepository implements PlacesRepository {
  @override
  Future<Either<Failure, List<PlaceEntity>>> searchPlaces({
    required double lat,
    required double lng,
    required double radius,
    required String keyword,
  }) async {
    // Devuelve una lista vacía exitosa por defecto para el test
    return const Right([]);
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Solución: Instanciar el Mock
    final mockRepository = MockPlacesRepository();
    // Solución: Inyectar el Mock en MyApp
    await tester.pumpWidget(MyApp(placesRepository: mockRepository));

    // El resto de tu test (que parece ser el test de ejemplo de Flutter)
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
