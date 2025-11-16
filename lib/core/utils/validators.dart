class Validators {
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un término de búsqueda';
    }
    if (value.length < 2) {
      return 'La búsqueda debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Número de teléfono inválido';
    }
    return null;
  }

  static bool isValidLocation(double? lat, double? lng) {
    return lat != null &&
        lng != null &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }
}