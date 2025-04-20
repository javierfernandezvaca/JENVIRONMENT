import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jenvironment/jenvironment.dart';

void main() {
  group('JEnvironment Tests', () {
    setUp(() async {
      String content = await File('test/.env').readAsString();
      await JEnvironment.load(content: content);
    });

    group('Loading and Basic String Values', () {
      // ...
      test('Environment variables are loaded', () {
        expect(JEnvironment.env.isNotEmpty, true,
            reason: 'Environment should be loaded.');
      });
      // ...
      test('Loads simple string values', () {
        expect(JEnvironment.env['SIMPLE_STRING'], 'valor_simple');
        expect(JEnvironment.env['SPACED_STRING'], 'valor con espacios');
        expect(JEnvironment.env['EMPTY_STRING'], '');
        expect(JEnvironment.env['VALUE_WITH_EQUALS'], 'parte1=parte2=parte3');
      });
      // ...
      test('Handles quoted string values', () {
        expect(JEnvironment.env['SINGLE_QUOTES'], 'valor con comillas simples');
        expect(JEnvironment.env['DOUBLE_QUOTES'], 'valor con comillas dobles');
      });
      // ...
      test(
          'Carga correctamente cadenas vacías explícitas (comillas simples y dobles)',
          () {
        expect(JEnvironment.env['EXPLICIT_EMPTY_STRING_SINGLE_QUOTES'], '');
        expect(JEnvironment.env['EXPLICIT_EMPTY_STRING_DOUBLE_QUOTES'], '');
      });
      // ...
      test(
          'Carga correctamente cadenas vacías implícitas (sin valor después del igual) como cadena vacía',
          () {
        expect(JEnvironment.env['IMPLICIT_EMPTY_STRING'], '',
            reason:
                'Cadena vacía implícita debe cargarse como cadena vacía, no null.');
      });
    });

    group('Comment Handling', () {
      // ...
      test('Comment lines are ignored', () {
        expect(JEnvironment.env['COMMENT_LINE'], '');
      });
      // ...
      test('Inline comments are part of the value', () {
        expect(JEnvironment.env['INLINE_COMMENT'], 'valor con');
      });
    });

    group('Data Type Getters', () {
      // ...
      test('getInt()', () {
        expect(JEnvironment.getInt('INT_VALUE'), 123);
        expect(JEnvironment.getInt('NEGATIVE_INT'), -45);
        expect(JEnvironment.getInt('SIMPLE_STRING'), null);
        expect(JEnvironment.getInt('MISSING_VARIABLE', fallback: 0), 0);
        expect(JEnvironment.getInt('MISSING_VARIABLE'), null);
      });
      // ...
      test('getDouble()', () {
        // ...
        expect(JEnvironment.getDouble('DOUBLE_VALUE'), 3.14);
        expect(JEnvironment.getDouble('NEGATIVE_DOUBLE'), -0.5);
        expect(JEnvironment.getDouble('SIMPLE_STRING'), null);
        expect(JEnvironment.getDouble('MISSING_VARIABLE', fallback: 1.0), 1.0);
        expect(JEnvironment.getDouble('MISSING_VARIABLE'), null);
      });
      // ...
      test('getBool()', () {
        expect(JEnvironment.getBool('BOOL_TRUE'), true);
        expect(JEnvironment.getBool('BOOL_FALSE'), false);
        expect(JEnvironment.getBool('BOOL_ONE'), true);
        expect(JEnvironment.getBool('BOOL_ZERO'), false);
        expect(JEnvironment.getBool('SIMPLE_STRING'), null);
        expect(JEnvironment.getBool('MISSING_VARIABLE', fallback: true), true);
        expect(
            JEnvironment.getBool('MISSING_VARIABLE', fallback: false), false);
        expect(JEnvironment.getBool('MISSING_VARIABLE'), null);
      });
      // ...
      test('getString()', () {
        expect(JEnvironment.getString('SIMPLE_STRING'), 'valor_simple');
        expect(JEnvironment.getString('INT_VALUE'), '123');
        expect(JEnvironment.getString('MISSING_VARIABLE'), '');
        expect(JEnvironment.getString('MISSING_VARIABLE', fallback: 'default'),
            'default');
      });
    });

    group('Error Handling', () {
      // ...
      test(
          'EnvNotLoadedException is thrown when trying to access env before load',
          () {
        JEnvironment.isLoadedForTest = false;
        expect(() => JEnvironment.env, throwsA(isA<EnvNotLoadedException>()));
        JEnvironment.isLoadedForTest = true;
      });
      // ...
      test('EnvFileLoadException is thrown on load failure', () async {
        expect(
            () async =>
                await JEnvironment.load(filePath: 'non_existent_file.env'),
            throwsA(isA<EnvFileLoadException>()));
      });
    });
  });
}
