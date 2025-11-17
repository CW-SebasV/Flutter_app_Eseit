import 'package:flutter_test/flutter_test.dart';
import 'package:contact_map/core/utils/validators.dart'; // Asegúrate que la ruta sea correcta

void main() {
  group('group name', () {});
  (
    'Validators.validateSearchQuery',
    () {
      test('should return error message for null value', () {
        // Act
        final result = Validators.validateSearchQuery(null);
        // Assert
        expect(result, isNotNull);
        expect(result, 'Por favor ingresa un término de búsqueda');
      });

      test('should return error message for empty value', () {
        // Act
        final result = Validators.validateSearchQuery('');
        // Assert
        expect(result, isNotNull);
        expect(result, 'Por favor ingresa un término de búsqueda');
      });

      test('should return error message for short value (1 char)', () {
        // Act
        final result = Validators.validateSearchQuery('a');
        // Assert
        expect(result, isNotNull);
        expect(result, 'La búsqueda debe tener al menos 2 caracteres');
      });

      test('should return null for a valid value', () {
        // Act
        final result = Validators.validateSearchQuery('pizza');
        // Assert
        expect(result, isNull);
      });

      test('should return null for a valid value with spaces', () {
        // Act
        final result = Validators.validateSearchQuery('tacos al pastor');
        // Assert
        expect(result, isNull);
      });
    }
  );

  // Puedes añadir más groups aquí para 'validatePhoneNumber' y 'isValidLocation'
  // si también necesitas cobertura para ellos.
}
