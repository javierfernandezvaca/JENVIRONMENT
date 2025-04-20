# Ejemplo de JEnvironment

Este es un proyecto de ejemplo que demuestra cómo implementar y utilizar JEnvironment en una aplicación Flutter.

## Descripción

Este proyecto muestra cómo integrar y utilizar JEnvironment para gestionar variables de entorno en una aplicación Flutter. Incluye ejemplos prácticos de configuración y uso de diferentes tipos de variables de entorno.

## Características

- Implementación completa de JEnvironment
- Ejemplos de carga de variables desde archivo .env
- Demostración de acceso a variables con tipo seguro
- Manejo de errores y valores de respaldo
- Ejemplos de uso en un contexto real

## Configuración del Proyecto

### Archivo .env

El proyecto incluye un archivo `.env` en la carpeta `assets` con ejemplos de variables:

```env
API_KEY=tu_api_key_aqui
BASE_URL=https://api.ejemplo.com
DEBUG_MODE=true
SERVER_PORT=8080
```

### Implementación

El archivo `main.dart` muestra cómo inicializar y usar JEnvironment:

```dart
import 'package:flutter/material.dart';
import 'package:jenvironment/jenvironment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await JEnvironment.load();
  
  // Acceder a las variables
  final apiKey = JEnvironment.getString('API_KEY');
  final baseUrl = JEnvironment.getString('BASE_URL');
  final debugMode = JEnvironment.getBool('DEBUG_MODE');
  final serverPort = JEnvironment.getInt('SERVER_PORT');
  
  runApp(MyApp());
}
```