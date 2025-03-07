// login_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/profile_data_student.dart';
import '../models/global_vars.dart'; // Use only ONE import path for GlobalVars
import 'dart:collection';
import 'package:logger/logger.dart';

class LoginController {
  // Singleton pattern
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  LoginController._internal();

  // Logger instance
  final Logger _logger = Logger();

  // Flag para indicar si el login ya ha sido procesado
  bool _loginProcessed = false;

  // Getter para verificar si el login ya ha sido procesado
  bool get loginProcessed => _loginProcessed;

  // Método para iniciar sesión
  Future<bool> login(String username, String password) async {
    try {
      _logger.i('Iniciando proceso de login para usuario: $username');

      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/login'),
        body: {'username': username, 'password': password},
      );

      _logger.i('Respuesta recibida. Status code: ${response.statusCode}');

      // Imprimir datos para debug (solo primeros 200 caracteres para no saturar logs)
      String previewBody =
          response.body.length > 200
              ? response.body.substring(0, 200) + '...'
              : response.body;
      _logger.d('Preview de respuesta: $previewBody');

      if (response.statusCode == 200) {
        // Procesa y guarda los datos
        bool result = await processLoginResponse(response.body);
        if (result) {
          _loginProcessed = true;
          // Verificar contenido de GlobalVars después de procesamiento
          printGlobalVarsState();
        }
        return result;
      } else {
        // Manejo de error
        _logger.e('Error en la solicitud: ${response.statusCode}');
        _logger.e('Cuerpo del error: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e('Error de conexión: ', error: e);
      return false;
    }
  }

  // Procesa la respuesta del login y guarda los datos
  Future<bool> processLoginResponse(String responseBody) async {
    try {
      _logger.d('Procesando respuesta de login...');

      // Decodifica el JSON
      final data = json.decode(responseBody);

      // Verifica si la respuesta es exitosa
      if (data['result'] == 'ok') {
        _logger.i('Resultado del login: OK. Procesando datos...');

        try {
          // Convierte los datos a objetos usando los modelos
          final ProfileDataStudent userData = ProfileDataStudent.fromJson(data);
          _logger.i('Datos de usuario convertidos correctamente');
          _logger.i('Nombre de usuario: ${userData.persona}');
          _logger.i('Email: ${userData.email}');
          _logger.i('Número de perfiles: ${userData.perfiles.length}');

          // Obtiene la instancia del singleton GlobalVars
          final globals = GlobalVars();
          _logger.d(
            'Instancia GlobalVars en LoginController: ${globals.hashCode}',
          );

          // Limpiamos cualquier dato anterior para evitar conflictos
          globals.clear();
          _logger.i('GlobalVars limpiado');

          // Guarda los datos principales
          globals.set('auth', userData.auth);
          globals.set('perfilactivoid', userData.perfilactivoid);
          globals.set('persona', userData.persona);
          globals.set('genero', userData.genero);
          globals.set('email', userData.email);
          globals.set('foto', userData.foto);
          globals.set('usuario', userData.usuario);
          globals.set('identificacion', userData.identificacion);
          globals.set('nacimiento', userData.nacimiento);

          // Guarda los datos completos en un solo objeto
          globals.set('userData', userData);
          _logger.i('Datos básicos guardados en GlobalVars');

          // LÓGICA DE SELECCIÓN DE PERFIL
          Perfile? perfilActivo;

          if (userData.perfiles.isEmpty) {
            _logger.w('ADVERTENCIA: No hay perfiles disponibles');
          } else {
            // 1. Primero intentamos utilizar el perfilactivoid como criterio principal
            perfilActivo = userData.perfiles.firstWhere(
              (perfil) => perfil.idpu == userData.perfilactivoid,
              orElse: () => userData.perfiles[0],
            );

            _logger.i(
              'Perfil seleccionado por perfilactivoid: ${perfilActivo.carrera}',
            );

            // 2. Si el perfil no está matriculado, intentamos con resumen.idpu
            if (!perfilActivo.matriculado) {
              final perfilPorResumen = userData.perfiles.firstWhere(
                (perfil) =>
                    perfil.idpu == userData.resumen.idpu && perfil.matriculado,
                orElse: () => userData.perfiles[0],
              );

              if (perfilPorResumen.matriculado) {
                perfilActivo = perfilPorResumen;
                _logger.i(
                  'Perfil actualizado por resumen.idpu: ${perfilActivo.carrera}',
                );
              }
            }

            // 3. Si aún no tenemos un perfil matriculado, buscamos cualquiera
            if (!perfilActivo.matriculado) {
              final perfilMatriculado = userData.perfiles.firstWhere(
                (perfil) => perfil.matriculado,
                orElse: () => userData.perfiles[0],
              );

              if (perfilMatriculado.matriculado) {
                perfilActivo = perfilMatriculado;
                _logger.i(
                  'Perfil actualizado a un perfil matriculado: ${perfilActivo.carrera}',
                );
              }
            }
          }

          // Guardamos el perfil seleccionado
          if (perfilActivo != null) {
            globals.set('perfilActivo', perfilActivo);
            _logger.i('Perfil activo establecido: ${perfilActivo.carrera}');

            // Para compatibilidad con código existente
            globals.set('perfilCoincidente', perfilActivo);
            globals.set(
              'perfilActivoID',
              perfilActivo.idpu,
            ); // Guarda solo el ID, no el objeto completo
          } else {
            _logger.w('ADVERTENCIA: No se pudo establecer un perfil activo');
          }

          // Guarda el resumen
          globals.set('resumen', userData.resumen);

          // Indicador de sesión iniciada
          globals.set('isLoggedIn', true);

          // Verificamos que los datos se hayan guardado correctamente
          await Future.delayed(
            Duration(milliseconds: 100),
          ); // Pequeña pausa para asegurar que los datos se guarden

          _logger.i('Verificación de datos guardados:');
          _logger.i('Persona: ${globals.get('persona')}');
          _logger.i('Email: ${globals.get('email')}');
          _logger.i(
            'Perfil activo: ${globals.get('perfilActivo')?.carrera ?? "No disponible"}',
          );
          _logger.i('isLoggedIn: ${globals.get('isLoggedIn')}');
          _logger.i('Claves disponibles: ${globals.keys}');

          return true;
        } catch (e) {
          _logger.e('Error procesando datos de usuario: ', error: e);
          return false;
        }
      } else {
        _logger.e('Error en la respuesta: ${data['result']}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error procesando respuesta: ',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Método para cerrar sesión
  void logout() {
    final globals = GlobalVars();
    globals.clear();
    globals.set('isLoggedIn', false);
    _loginProcessed = false;
    _logger.i('Sesión cerrada correctamente');
  }

  // Comprueba si el usuario está autenticado
  bool isAuthenticated() {
    final globals = GlobalVars();
    bool isLoggedIn = globals.get('isLoggedIn') == true;
    _logger.i('Estado de autenticación: $isLoggedIn');
    return isLoggedIn;
  }

  // Método para debug - imprime el estado actual de GlobalVars
  void printGlobalVarsState() {
    final globals = GlobalVars();
    _logger.i('''
====== ESTADO DE GLOBALVARS ======
Claves disponibles: ${globals.keys}
Total de claves: ${globals.count}
Autenticado: ${globals.get('isLoggedIn')}
Persona: ${globals.get('persona')}
Email: ${globals.get('email')}
Perfil activo: ${globals.get('perfilActivo')?.carrera ?? "No disponible"}
Resumen: ${globals.get('resumen') != null ? "Disponible" : "null"}
==================================''');
  }
}
