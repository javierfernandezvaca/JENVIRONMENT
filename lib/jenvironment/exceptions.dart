/// Excepción lanzada al intentar acceder a variables de entorno antes de que se haya llamado a `JEnvironment.load()`.
///
/// Esta excepción indica que estás intentando recuperar variables de entorno
/// utilizando métodos como `JEnvironment.get()`, `JEnvironment.env`, etc., antes de que el archivo `.env`
/// haya sido cargado y parseado. Debes llamar a `JEnvironment.load()` al inicio de tu aplicación
/// para inicializar las variables de entorno.
class EnvNotLoadedException implements Exception {
  final String message;
  EnvNotLoadedException(
      [this.message =
          'JEnvironment has not been loaded. Call JEnvironment.load() first.']);

  @override
  String toString() {
    return 'EnvNotLoadedException: $message';
  }
}

/// Excepción lanzada cuando hay un error al cargar el archivo `.env`.
///
/// Esta excepción es típicamente lanzada por `JEnvironment.load()` cuando encuentra problemas
/// al intentar leer o parsear el archivo `.env`. Las causas comunes incluyen que el archivo no se encuentre,
/// o problemas con los permisos del archivo.
class EnvFileLoadException implements Exception {
  final String message;
  EnvFileLoadException([this.message = 'Error loading .env file.']);

  @override
  String toString() {
    return 'EnvFileLoadException: $message';
  }
}
