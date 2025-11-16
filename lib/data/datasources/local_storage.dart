import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Search History
  Future<void> saveSearchQuery(String query) async {
    if (query.isEmpty) return;
    final searches = getSearchHistory();
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) {
      searches.removeLast();
    }
    await _prefs?.setStringList('search_history', searches);
  }

  List<String> getSearchHistory() {
    return _prefs?.getStringList('search_history') ?? [];
  }

  Future<void> clearSearchHistory() async {
    await _prefs?.remove('search_history');
  }

  // Settings
  Future<void> saveSearchRadius(double radius) async {
    await _prefs?.setDouble('search_radius', radius);
  }

  double getSearchRadius() {
    return _prefs?.getDouble('search_radius') ?? 5.0;
  }

  // Last Location
  Future<void> saveLastLocation(double lat, double lng) async {
    await _prefs?.setDouble('last_lat', lat);
    await _prefs?.setDouble('last_lng', lng);
  }

  Map<String, double> getLastLocation() {
    final lat = _prefs?.getDouble('last_lat');
    final lng = _prefs?.getDouble('last_lng');
    if (lat != null && lng != null) {
      return {'lat': lat, 'lng': lng};
    }
    return {};
  }

  // Generic methods
  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}