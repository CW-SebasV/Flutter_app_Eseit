ContactMap (Proyecto Final Flutter)
ContactMap es una aplicación móvil (iOS/Android) desarrollada en Flutter. El objetivo de la aplicación es permitir a los usuarios encontrar negocios locales (ej. "restaurantes", "ferreterías") basándose en su ubicación GPS actual.
La funcionalidad clave es filtrar los resultados para priorizar aquellos con números de teléfono y permitir al usuario iniciar un chat de WhatsApp con el negocio directamente desde la app.
Este proyecto sirve utilizando la API de Overpass para consumir datos de OpenStreetMap en lugar de APIs de pago como Google Places.
1. Arquitectura y Estructura de Capas
El proyecto sigue estrictamente los principios de Arquitectura Limpia (Clean Architecture), separando el código en tres capas principales para asegurar un bajo acoplamiento y alta cohesión.   

lib/presentation: Contiene la UI (Widgets, Pages) y el manejo de estado (el PlaceProvider). Esta capa reacciona a los estados (carga, error, éxito) y delega las acciones del usuario al provider.

lib/domain: Es el núcleo de la aplicación. Contiene las entidades de negocio (PlaceEntity) y los contratos o interfaces (PlacesRepository) que la capa de presentación utiliza. No tiene dependencias de Flutter ni de las fuentes de datos.

lib/data: Contiene la implementación de la capa domain. Aquí se encuentran las fuentes de datos (OverpassApiDatasource, LocalStorage) y la implementación del repositorio (PlacesRepositoryImpl), que también contiene la lógica de negocio para filtrar, ordenar y puntuar los resultados.

Flujo de Dependencia: Presentation → Domain ← Data.
2. Patrones de Diseño Utilizados
Para cumplir con la arquitectura y los requisitos, se implementaron los siguientes patrones :   
A. Repository Pattern   
Problema que Resuelve: Desacopla la lógica de negocio (en la capa de domain y usada por presentation) de la fuente específica de donde se obtienen los datos.
Justificación: Se definió una interfaz PlacesRepository en la capa domain. La capa presentation (a través del PlaceProvider) solo conoce esta interfaz. La capa data provee la implementación concreta (PlacesRepositoryImpl) que usa Overpass.
Ventaja: Si quisiéramos cambiar la fuente de datos a Google Maps, solo necesitaríamos crear un GooglePlacesRepositoryImpl que implemente la misma interfaz, sin cambiar nada en la capa presentation.

B. Provider (Manejo de Estado)   
Problema que Resuelve: Maneja el estado de la aplicación (la lista de lugares, el estado de carga, los mensajes de error, la ubicación del usuario) de forma reactiva y eficiente, evitando el manejo manual del estado en StatefulWidgets.   
Justificación: Se eligió Provider por su simplicidad y su integración nativa con la Inyección de Dependencias. El PlaceProvider centraliza toda la lógica de la UI: solicita permisos, obtiene la ubicación, llama al repositorio para buscar lugares y notifica a la UI (como HomePage) para que se redibuje.

C. Inyección de Dependencias (Manual)   
Problema que Resuelve: Provee a las clases las dependencias que necesitan sin que ellas tengan que crearlas.
Justificación: En lib/main.dart, se instancia manualmente el OverpassApiDatasource, se inyecta en PlacesRepositoryImpl, y esa implementación se inyecta en el PlaceProvider. Esto permite que el Repository Pattern funcione y facilita las pruebas (podríamos inyectar un mock del repositorio en el provider durante un test).

3. Instrucciones de Ejecución
El proyecto no requiere claves de API (API Keys) ya que utiliza la API pública de Overpass.
Clonar el repositorio.
Asegurar que Flutter está instalado.
Ejecutar flutter pub get para instalar las dependencias.
Ejecutar flutter run para lanzar la aplicación en un emulador o dispositivo físico.
