# JEnvironment

Una librería Dart ligera y sencilla para cargar variables de entorno en proyectos Flutter.

## Características

* Fácil de usar: API simple para cargar y acceder a variables de entorno.
* Carga de archivos .env: Carga variables desde un archivo .env en tus assets.
* Carga de contenido de cadena: Soporta la carga de variables directamente desde una cadena.
* Acceso con tipo seguro: Proporciona métodos para obtener variables como String, int, double y bool.
* Valores de respaldo: Opción para proporcionar valores de respaldo si una variable no se encuentra o está vacía.
* Manejo de errores: Incluye excepciones personalizadas para fallos de carga y acceso antes de la carga.
* Ligera: Dependencias mínimas y tamaño reducido.

## Empezando

### 1. Añadir la dependencia

Añade `jenvironment` a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  jsm:
    git:
      url: https://github.com/javierfernandezvaca/JENVIRONMENT
      ref: master
```

### 2. Añadir el archivo `.env` a los assets

Crea un archivo `.env` en tu directorio `assets` (por ejemplo, `assets/.env`) y añade tus variables de entorno en el formato `CLAVE=VALOR`:

```
API_KEY=tu_api_key
BASE_URL=https://api.example.com
DEBUG_MODE=true
SERVER_PORT=8080
```

Asegúrate de declarar la carpeta de assets en tu archivo `pubspec.yaml`:

```yaml
assets:
  - assets/.env
```

### 3. Cargar las variables de entorno

Carga las variables de entorno al inicio de tu aplicación, típicamente en tu función `main()`, antes de que necesites acceder a cualquier variable de entorno.

```dart
import 'package:flutter/material.dart';
import 'package:jenvironment/jenvironment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Requerido
  await JEnvironment.load(); // Carga las variables desde assets/.env por defecto
  runApp(MyApp());
}
```

También puedes cargar variables desde una ruta de archivo específica o directamente desde un contenido de cadena:

```dart
// Cargar desde una ruta de archivo personalizada
await JEnvironment.load(filePath: 'assets/config/.env.staging');
```

```dart
// Cargar desde un contenido de cadena
String envContent = '''
API_KEY=otra_api_key
DEBUG_MODE=false
''';
await JEnvironment.load(content: envContent);
```

## Uso
Puedes acceder a las variables de entorno cargadas de varias maneras:

### 1. Usando el getter `env` (Acceso al Map)
Esto proporciona un `Map<String, String>` inmutable que contiene todas las variables cargadas.

```dart
Map<String, String> environment = JEnvironment.env;
String? apiKey = environment['API_KEY'];
String? baseUrl = environment['BASE_URL'];
```

### 2. Usando getters con tipo seguro (`get`, `getInt`, `getDouble`, `getBool`, `getString`)

Estos métodos proporcionan acceso con tipo seguro y valores de respaldo opcionales.

```dart
// Obtener como String
String? apiKey = JEnvironment.getString('API_KEY'); // Devuelve String?
String apiUrl = JEnvironment.getString('API_URL', fallback: 'default_url')!; // Devuelve String, el fallback asegura no nulo

// Obtener como Entero
int? serverPort = JEnvironment.getInt('SERVER_PORT'); // Devuelve int?
int port = JEnvironment.getInt('PORT', fallback: 3000)!; // Devuelve int, el fallback asegura no nulo

// Obtener como Double
double? versionNumber = JEnvironment.getDouble('VERSION_NUMBER'); // Devuelve double?

// Obtener como Booleano
bool? debugMode = JEnvironment.getBool('DEBUG_MODE'); // Devuelve bool?
bool isDebug = JEnvironment.getBool('DEBUG_MODE', fallback: false)!; // Devuelve bool, el fallback asegura no nulo

// Get genérico como String? (igual que getString)
String? appName = JEnvironment.get('APP_NAME'); // Devuelve String?
```

Usando Valores de Respaldo:

Todos los getters con tipo seguro (`get`, `getInt`, `getDouble`, `getBool`, `getString`) aceptan un parámetro `fallback` opcional. Este valor se devolverá si la variable de entorno no se encuentra, está vacía o no se puede parsear al tipo deseado.

```dart
String appName = JEnvironment.getString('APP_NAME', fallback: 'Mi App')!;
int port = JEnvironment.getInt('PORT', fallback: 8080)!;
bool isDebugMode = JEnvironment.getBool('DEBUG_MODE', fallback: false)!;
```

## Manejo de Errores

`jenvironment` lanza excepciones específicas para ayudarte a gestionar los errores de forma elegante:

* `EnvNotLoadedException`: Lanzada cuando intentas acceder a las variables de entorno (usando `JEnvironment.env` o cualquier método getter) antes de llamar a `JEnvironment.load()`. Asegúrate de llamar a `JEnvironment.load()` al inicio de tu aplicación.

```dart
try {
  String? apiKey = JEnvironment.getString('API_KEY'); // Accediendo antes de load
} catch (e) {
  if (e is EnvNotLoadedException) {
    print('Error: Variables de entorno no cargadas. Llama a JEnvironment.load() primero.');
  }
}
```

* `EnvFileLoadException`: Lanzada por `JEnvironment.load()` si hay un error al cargar o parsear el archivo `.env` (por ejemplo, archivo no encontrado, ruta de archivo incorrecta, errores de parseo).

```dart
try {
  await JEnvironment.load(filePath: 'assets/non_existent_env');
} catch (e) {
  if (e is EnvFileLoadException) {
    print('Error al cargar el archivo .env: ${e.message}');
  }
}
```
## Licencia

Licencia MIT - [enlace al archivo LICENSE]