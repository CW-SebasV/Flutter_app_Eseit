import 'package:flutter_test/flutter_test.dart';
import 'package:contact_map/core/utils/helpers.dart'; // Asegúrate que la ruta sea correcta
import 'package:contact_map/core/constants/strings.dart'; // Necesario para 'km'

void main() {
  group('Helpers.formatDistance', () {
    test('should return "N/A" for null distance', () {
      // Act
      final result = Helpers.formatDistance(null);
      // Assert
      expect(result, 'N/A');
    });

    test('should return meters for distance < 1 km', () {
      // Act
      final result = Helpers.formatDistance(0.5);
      // Assert
      expect(result, '500 m');
    });

    test('should round meters correctly', () {
      // Act
      final result = Helpers.formatDistance(0.8765);
      // Assert
      expect(result, '877 m'); // (0.8765 * 1000).round() = 877
    });

    test('should return kilometers for distance = 1 km', () {
      // Act
      final result = Helpers.formatDistance(1.0);
      // Assert
      expect(result, '1.0 ${Strings.km}');
    });

    test('should return kilometers with one decimal for distance > 1 km', () {
      // Act
      final result = Helpers.formatDistance(2.3);
      // Assert
      expect(result, '2.3 ${Strings.km}');
    });

    test('should format and round kilometers correctly', () {
      // Act
      final result = Helpers.formatDistance(5.48);
      // Assert
      expect(result, '5.5 ${Strings.km}'); // .toStringAsFixed(1) redondea
    });
  });

  group('Helpers.formatPhoneNumber', () {
    test('should clean non-digit characters and keep +', () {
      // Act
      final result = Helpers.formatPhoneNumber('+1 (800) 555-1234');
      // Assert
      expect(result, '+18005551234');
    });

    test('should add +52 prefix for 10-digit numbers (Mexico default)', () {
      // Act
      final result = Helpers.formatPhoneNumber('5512345678');
      // Assert
      expect(result, '+525512345678');
    });

    test('should just add + if not starting with + and not 10 digits', () {
      // Act
      final result = Helpers.formatPhoneNumber('1234567'); // Ej. número corto
      // Assert
      expect(result, '+1234567');
    });

    test('should return cleaned number if it already starts with +', () {
      // Act
      final result = Helpers.formatPhoneNumber('+34 911 23 45 67');
      // Assert
      expect(result, '+34911234567');
    });

    test('should handle empty or weird formats', () {
      // Act
      final result = Helpers.formatPhoneNumber('tel: (123)-456');
      // Assert
      expect(result, '+123456'); // 'tel:' es limpiado, '()' y '-' también
    });
  });
}
