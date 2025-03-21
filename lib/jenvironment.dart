library jenvironment;

/// Librería sencilla y ligera para cargar variables de entorno en proyectos Flutter.
///
/// Esta librería permite cargar variables de entorno desde un archivo `.env`
/// ubicado en tu directorio `assets` o desde un contenido de cadena proporcionado.
/// Proporciona métodos para acceder a estas variables como cadenas, enteros, dobles o booleanos,
/// con valores de respaldo opcionales.
///
/// ## Características
///
/// *   **Fácil de usar:** API simple para cargar y acceder a variables de entorno.
/// *   **Carga de archivos `.env`:** Carga variables desde un archivo `.env` en tus assets.
/// *   **Carga de contenido de cadena:** Soporta la carga de variables directamente desde una cadena.
/// *   **Acceso con tipo seguro:** Proporciona métodos para obtener variables como String, int, double y bool.
/// *   **Valores de respaldo:** Opción para proporcionar valores de respaldo si una variable no se encuentra.
/// *   **Manejo de errores:** Incluye excepciones personalizadas para fallos de carga y acceso antes de la carga.
/// *   **Ligera:** Dependencias mínimas y tamaño reducido.

export 'jenvironment/exceptions.dart';
export 'jenvironment/environment.dart';
