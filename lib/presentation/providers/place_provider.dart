import 'package:flutter/material.dart';
import 'package:contact_map/domain/entities/place_entity.dart';
import 'package:contact_map/domain/repositories/places_repository.dart';
import 'package:location/location.dart';
import 'package:contact_map/core/constants/strings.dart';
import 'package:contact_map/core/utils/location_utils.dart';
import 'package:contact_map/core/errors/failures.dart';
import 'package:contact_map/data/datasources/local_storage.dart';

enum ProviderState { uninitialized, loading, error, success }

class PlaceProvider with ChangeNotifier {
  final PlacesRepository placesRepository;
  final LocalStorage _localStorage = LocalStorage();

  PlaceProvider(this.placesRepository);

  List<PlaceEntity> _places = [];
  bool _isLoading = false;
  String _error = '';
  double _searchRadius = 5.0;
  LocationData? _currentLocation;

  bool _isInitialized = false;
  bool _hasLocationPermission = false;
  bool _isLocationLoading = false;
  bool _hasSearched = false;
  String _lastSearchQuery = '';

  List<PlaceEntity> get places => _places;
  bool get isLoading => _isLoading;
  String get error => _error;
  double get searchRadius => _searchRadius;
  LocationData? get currentLocation => _currentLocation;

  bool get isInitialized => _isInitialized;
  bool get hasLocationPermission => _hasLocationPermission;
  bool get isLocationLoading => _isLocationLoading;
  bool get hasSearched => _hasSearched;

  // Se llama una vez al inicio desde main.dart
  Future<void> initialize() async {
    // Cargar radio guardado
    _searchRadius = _localStorage.getSearchRadius();

    // Comprobar permisos
    _isLocationLoading = true;
    notifyListeners();

    try {
      _hasLocationPermission = await LocationUtils.checkLocationPermission();
      if (_hasLocationPermission) {
        _currentLocation = await LocationUtils.getCurrentLocation();
        _localStorage.saveLastLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
      }
    } catch (e) {
      if (e.toString().contains('Permiso')) {
        _error = Strings.permissionDenied;
      } else {
        _error = 'Error al obtener ubicación: $e';
      }
      _hasLocationPermission = false;
    }

    _isLocationLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  void setSearchRadius(double radius) {
    _searchRadius = radius;
    _localStorage.saveSearchRadius(radius);
    notifyListeners();
  }

  Future<void> searchPlaces(String keyword) async {
    // Guardar query para reintentos
    _lastSearchQuery = keyword;
    _hasSearched = true;

    if (_currentLocation == null) {
      _error = 'No se pudo obtener la ubicación actual.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await placesRepository.searchPlaces(
      lat: _currentLocation!.latitude!,
      lng: _currentLocation!.longitude!,
      radius: _searchRadius,
      keyword: keyword,
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _places = [];
      },
      (placesList) {
        _places = placesList;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void retryLastAction() {
    if (_error.isNotEmpty && _lastSearchQuery.isNotEmpty) {
      // Si el error ocurrió durante una búsqueda, reintentar la búsqueda
      searchPlaces(_lastSearchQuery);
    } else if (!_hasLocationPermission) {
      // Si el error fue de permisos, reintentar la inicialización
      initialize();
    }
  }

  void clearResults() {
    _places.clear();
    _error = '';
    _hasSearched = false;
    _lastSearchQuery = '';
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Error de red. Revisa tu conexión a internet.';
    } else if (failure is LocationFailure) {
      return 'Error al obtener la ubicación: ${failure.message}';
    } else if (failure is PermissionFailure) {
      return Strings.permissionDenied;
    } else {
      return Strings.errorMessage;
    }
  }
}