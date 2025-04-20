import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jenvironment/jenvironment.dart';

Future<void> main() async {
  // Asegura la inicialización para rootBundle
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Cargar el archivo .env
    await JEnvironment.load(filePath: 'assets/.env');
  } on EnvFileLoadException catch (e) {
    // Errores de carga del archivo .env
    debugPrint('Error al cargar el archivo .env: ${e.message}');
  } catch (e) {
    // Otros tipos de excepciones
    debugPrint('Ocurrió un error inesperado: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JEnvironment',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JEnvironment'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Variables de entorno cargadas:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Builder(builder: (context) {
                var encoder = JsonEncoder.withIndent(' ' * 2);
                var formattedJson = encoder.convert(JEnvironment.env);
                return Text(
                  formattedJson, // Muestra todas las variables de entorno
                  style: const TextStyle(fontFamily: 'monospace'),
                );
              }),
              const Divider(thickness: 2, height: 30),
              Text(
                'APP_NAME:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                JEnvironment.get('APP_NAME') ??
                    'No definida', // Obtiene APP_NAME
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'API_KEY:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                JEnvironment.get('API_KEY') ?? 'No definida', // Obtiene API_KEY
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'DEBUG_MODE',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                JEnvironment.get('DEBUG_MODE') ??
                    'No definida', // Obtiene DEBUG_MODE
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'PORT:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                JEnvironment.get('PORT') ?? 'No definida', // Obtiene PORT
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 2, height: 30),
              Text(
                'Variable no definida (con fallback):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                JEnvironment.get('NON_EXISTENT_VAR',
                    fallback:
                        'Valor por defecto')!, // Variable inexistente con fallback
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 2, height: 30),
              Text(
                'Contenido original del archivo .env desde (assets/.env)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: rootBundle.loadString(
                    'assets/.env'), // Carga el contenido del archivo .env directamente
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot
                          .data!, // Muestra el contenido original del archivo
                      style: const TextStyle(
                          fontFamily: 'monospace'), // Fuente monoespaciada
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        'Error al cargar el archivo .env: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator(); // Muestra un indicador de carga mientras se carga el archivo
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
