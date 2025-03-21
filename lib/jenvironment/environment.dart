import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'exceptions.dart';

/// Proporciona métodos para cargar y acceder a variables de entorno.
///
/// `JEnvironment` ofrece una manera sencilla de gestionar la configuración del entorno en aplicaciones Flutter.
/// Carga variables desde un archivo `.env` ubicado en tus assets o desde un contenido de cadena proporcionado.
///
/// **Uso:**
///
/// 1.  **Añade el archivo `.env` a los assets:** Crea un archivo `.env` (por ejemplo, en `assets/.env`) y añade tus variables de entorno.
///    Asegúrate de declarar la carpeta de assets en tu archivo `pubspec.yaml`:
///
///    ```yaml
///    assets:
///      - assets/.env
///    ```
///
/// 2.  **Carga las variables de entorno:** Llama a `JEnvironment.load()` al inicio de tu aplicación, típicamente en tu función `main()`, antes de acceder a cualquier variable de entorno.
///
///    ```dart
///    void main() async {
///      WidgetsFlutterBinding.ensureInitialized(); // Requerido para rootBundle
///      await JEnvironment.load();
///      runApp(MyApp());
///    }
///    ```
///
/// 3.  **Accede a las variables de entorno:** Utiliza el getter `JEnvironment.env` para acceder a todas las variables cargadas como un `Map<String, String>`, o utiliza getters con tipo seguro como `JEnvironment.get()`, `JEnvironment.getInt()`, `JEnvironment.getDouble()`, `JEnvironment.getBool()` y `JEnvironment.getString()` para recuperar variables específicas.
///
///    ```dart
///    String? apiKey = JEnvironment.getString('API_KEY');
///    int? port = JEnvironment.getInt('SERVER_PORT', fallback: 8080);
///    ```
///
/// **Consideraciones importantes:**
///
/// *   **Ubicación del archivo:** Por defecto, `JEnvironment.load()` busca `.env` en `assets/.env`. Puedes especificar una ruta diferente utilizando el parámetro `filePath`.
/// *   **Inmutabilidad:** El getter `JEnvironment.env` devuelve un mapa inmutable para evitar cambios accidentales a las variables de entorno en tiempo de ejecución.
/// *   **Manejo de errores:** Asegúrate de manejar `EnvFileLoadException` al llamar a `JEnvironment.load()` para gestionar con elegancia los escenarios donde el archivo `.env` no se puede cargar.
/// *   **Seguridad de tipos:** Utiliza los getters específicos de tipo (`getInt`, `getDouble`, `getBool`) para un acceso más seguro y conversión automática de tipo con valores de respaldo opcionales.
class JEnvironment {
  static bool _isLoaded = false;
  static final Map<String, String?> _envVars = {};

  /// Carga variables de entorno desde un archivo `.env` o desde un contenido de cadena proporcionado.
  ///
  /// Este método debe ser llamado antes de acceder a cualquier variable de entorno. Parsea el archivo `.env`
  /// (o el contenido proporcionado) y hace que las variables sean accesibles a través de `JEnvironment.env` y otros getters.
  ///
  /// [filePath] (opcional): La ruta al archivo `.env` en tus assets. Por defecto `assets/.env`.
  /// [content] (opcional): Una cadena que contiene el contenido del archivo `.env`. Si se proporciona, la ruta del archivo se ignora y las variables se cargan desde este contenido.
  ///
  /// Lanza [EnvFileLoadException] si hay un error al cargar o parsear el archivo `.env`.
  static Future<void> load(
      {String filePath = 'assets/.env', String? content}) async {
    try {
      String envContentToParse;
      if (content != null) {
        envContentToParse = content;
      } else {
        envContentToParse = await rootBundle.loadString(filePath);
      }
      _envVars.clear();
      _envVars.addAll(_parseEnvFile(envContentToParse));
      _isLoaded = true;
    } catch (e) {
      final errorMessage = 'Error loading .env file from $filePath: $e';
      log(errorMessage, name: 'JEnvironment');
      _envVars.clear();
      _isLoaded = false;
      throw EnvFileLoadException(errorMessage);
    }
  }

  /// Devuelve un mapa inmutable de todas las variables de entorno cargadas.
  ///
  /// Las claves y los valores en el mapa son cadenas, representando los nombres de las variables y sus valores, respectivamente.
  ///
  /// Lanza una [EnvNotLoadedException] si `JEnvironment.load()` no ha sido llamado todavía.
  static Map<String, String?> get env {
    _ensureLoaded();
    return Map.unmodifiable(_envVars);
  }

  /// Recupera el valor de una variable de entorno como String.
  ///
  /// [name]: El nombre de la variable de entorno a recuperar.
  /// [fallback] (opcional): Un valor a devolver si la variable de entorno no se encuentra o está vacía. Si no se proporciona un fallback y la variable no se encuentra, devuelve `null`.
  ///
  /// Devuelve el valor String de la variable de entorno, o el valor [fallback] si la variable no se encuentra o está vacía y se proporciona un fallback, en caso contrario `null`.
  ///
  /// Lanza una [EnvNotLoadedException] si `JEnvironment.load()` no ha sido llamado todavía.
  static String? get(String name, {String? fallback}) {
    _ensureLoaded();
    final value = _envVars[name];
    if (value == null || (value.isEmpty && fallback != null)) {
      return fallback;
    }
    return value;
  }

  /// Recupera el valor de una variable de entorno como un entero.
  ///
  /// [name]: El nombre de la variable de entorno a recuperar.
  /// [fallback] (opcional): Un valor a devolver si la variable de entorno no se encuentra, está vacía o no se puede parsear como un entero. Si no se proporciona un fallback y la variable no se puede parsear, devuelve `null`.
  ///
  /// Devuelve el valor entero de la variable de entorno, o el valor [fallback] si el parseo falla o la variable no se encuentra o está vacía y se proporciona un fallback, en caso contrario `null`.
  ///
  /// Lanza una [EnvNotLoadedException] si `JEnvironment.load()` no ha sido llamado todavía.
  static int? getInt(String name, {int? fallback}) {
    _ensureLoaded();
    final valueStr = get(name);
    if (valueStr == null || valueStr.isEmpty) {
      return fallback;
    }
    return int.tryParse(valueStr) ?? fallback;
  }

  /// Recupera el valor de una variable de entorno como un double.
  ///
  /// [name]: El nombre de la variable de entorno a recuperar.
  /// [fallback] (opcional): Un valor a devolver si la variable de entorno no se encuentra, está vacía o no se puede parsear como un double. Si no se proporciona un fallback y la variable no se puede parsear, devuelve `null`.
  ///
  /// Devuelve el valor double de la variable de entorno, o el valor [fallback] si el parseo falla o la variable no se encuentra o está vacía y se proporciona un fallback, en caso contrario `null`.
  ///
  /// Lanza una [EnvNotLoadedException] si `JEnvironment.load()` no ha sido llamado todavía.
  static double? getDouble(String name, {double? fallback}) {
    _ensureLoaded();
    final valueStr = get(name);
    if (valueStr == null || valueStr.isEmpty) {
      return fallback;
    }
    return double.tryParse(valueStr) ?? fallback;
  }

  /// Recupera el valor de una variable de entorno como un booleano.
  ///
  /// Reconoce 'true', '1' (insensible a mayúsculas y minúsculas) como `true`, y 'false', '0' (insensible a mayúsculas y minúsculas) como `false`.
  /// Devuelve el valor booleano si se reconoce, en caso contrario, devuelve el valor [fallback] (si se proporciona), o `null`.
  ///
  /// Lanza una [EnvNotLoadedException] si `JEnvironment.load()` no ha sido llamado todavía.
  ///
  /// [name]: El nombre de la variable de entorno a recuperar.
  /// [fallback] (opcional): Un valor booleano de respaldo opcional a devolver si la variable no se encuentra o no se puede parsear como un booleano.
  ///
  /// Devuelve el valor booleano de la variable de entorno, o el valor [fallback] si el parseo falla o la variable no se encuentra o está vacía y se proporciona un fallback, en caso contrario `null`.
  static bool? getBool(String name, {bool? fallback}) {
    _ensureLoaded();
    final valueStr = get(name);
    if (valueStr == null || valueStr.isEmpty) {
      return fallback;
    }
    final lowerValue = valueStr.toLowerCase();
    if (lowerValue == 'true' || lowerValue == '1') {
      return true;
    }
    if (lowerValue == 'false' || lowerValue == '0') {
      return false;
    }
    return fallback;
  }

  /// Recupera el valor de una variable de entorno como un String.
  ///
  /// Este es un alias para el método [get], y se comporta de manera idéntica.
  /// Devuelve el valor String de la variable si se encuentra, en caso contrario, devuelve el valor [fallback] (si se proporciona), o `null`.
  ///
  /// Lanza una [EnvNotLoadedException] si `JEnvironment.load()` no ha sido llamado todavía.
  ///
  /// [name]: El nombre de la variable de entorno a recuperar.
  /// [fallback] (opcional): Un valor String de respaldo opcional a devolver si la variable no se encuentra.
  ///
  /// Devuelve el valor String de la variable de entorno, o el valor [fallback], o `null`.
  static String? getString(String name, {String? fallback}) {
    _ensureLoaded();
    return get(name, fallback: fallback);
  }

  /// Asegura que las variables de entorno han sido cargadas antes de proceder.
  ///
  /// Lanza [EnvNotLoadedException] si `JEnvironment.load()` no ha sido llamado todavía.
  static void _ensureLoaded() {
    if (!_isLoaded) {
      throw EnvNotLoadedException();
    }
  }

  // Expresión regular para detectar comillas envolventes
  static final _surroundQuotesRegex = RegExp(r'''^(["'])(.*)\1$''');

  /// Comprueba si una cadena está rodeada de comillas (simples o dobles).
  ///
  /// Devuelve el carácter de comilla si la cadena está rodeada de comillas, en caso contrario `null`.
  static String? _surroundingQuote(String val) {
    if (!_surroundQuotesRegex.hasMatch(val)) return null;
    return _surroundQuotesRegex.firstMatch(val)!.group(1);
  }

  /// Elimina las comillas envolventes (simples o dobles) de una cadena si existen.
  ///
  /// Si la cadena no está rodeada de comillas, devuelve la cadena sin cambios.
  static String _unquote(String val) {
    final quoteChar = _surroundingQuote(val);
    if (quoteChar == null) {
      return val;
    }
    return _surroundQuotesRegex.firstMatch(val)!.group(2)!;
  }

  /// Parsea el contenido de un archivo `.env` y devuelve un mapa de variables de entorno.
  ///
  /// Ignora las líneas que comienzan con `#` (comentarios) y las líneas vacías.
  /// Elimina los espacios en blanco de las claves y los valores.
  /// Elimina las comillas envolventes de los valores.
  ///
  /// [content]: El contenido de cadena del archivo `.env` a parsear.
  ///
  /// Devuelve un mapa donde las claves son nombres de variables de entorno (Strings) y los valores son valores de variables de entorno (String o null).
  static Map<String, String?> _parseEnvFile(String content) {
    final envMap = <String, String?>{};
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('#') || trimmedLine.isEmpty) {
        continue;
      }
      String lineWithoutComment = trimmedLine;
      if (trimmedLine.contains('#')) {
        lineWithoutComment = trimmedLine.split('#')[0].trim();
      }
      if (lineWithoutComment.isEmpty) {
        continue;
      }
      final parts = lineWithoutComment.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        String value = parts.sublist(1).join('=').trim();
        value = _unquote(value);
        envMap[key] = value;
      }
    }
    return envMap;
  }

  /// Setter para '_isLoaded' para propósitos de prueba únicamente.
  ///
  /// Permite a las pruebas controlar manualmente el estado de carga de `JEnvironment`.
  @visibleForTesting
  static set isLoadedForTest(bool value) {
    _isLoaded = value;
  }
}
