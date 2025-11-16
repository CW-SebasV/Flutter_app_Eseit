import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contact_map/presentation/pages/home_page.dart';
import 'package:contact_map/presentation/providers/place_provider.dart';
import 'package:contact_map/presentation/styles/app_theme.dart';
import 'package:contact_map/data/datasources/local_storage.dart';
import 'package:contact_map/data/datasources/overpass_api_datasource.dart'; // CAMBIADO
import 'package:contact_map/data/repositories/places_repository_impl.dart'; // CAMBIADO
import 'package:contact_map/domain/repositories/places_repository.dart';
import 'package:http/http.dart' as http; // Importar http

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No necesitamos dotenv.load()

  // Inicializar almacenamiento local
  await LocalStorage().init();

  // --- Configuración de Inyección de Dependencias (Ruta B) ---

  // 1. Creamos el cliente HTTP
  final httpClient = http.Client();

  // 2. Creamos el Datasource de Overpass
  final overpassApi = OverpassApiDatasource(httpClient);

  // 3. Creamos la implementación del repositorio, inyectando el Datasource
  final PlacesRepository placesRepository = PlacesRepositoryImpl(
    apiDatasource: overpassApi,
    // Puedes añadir otros datasources (como el local) aquí si es necesario
  );

  runApp(MyApp(
    // 4. Pasamos el repositorio al widget de la App
    placesRepository: placesRepository,
  ));
}

class MyApp extends StatelessWidget {
  final PlacesRepository placesRepository;

  const MyApp({super.key, required this.placesRepository});

  @override
  Widget build(BuildContext context) {
    /*
     * Usamos el 'placesRepository' inyectado para crear el PlaceProvider.
     */
    return ChangeNotifierProvider(
      create: (context) => PlaceProvider(placesRepository)..initialize(),
      child: MaterialApp(
        title: 'WhatsApp Business Finder',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}