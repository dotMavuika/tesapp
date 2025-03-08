// login_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/profile_data_student.dart';
import '../models/global_vars.dart';
import 'dart:collection';

class LoginController {
  // Singleton pattern
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  LoginController._internal();

  // Flag para indicar si el login ya ha sido procesado
  bool _loginProcessed = false;
  
  // Getter para verificar si el login ya ha sido procesado
  bool get loginProcessed => _loginProcessed;

  // Método para iniciar sesión
  Future<bool> login(String username, String password) async {
    try {
      print('Iniciando proceso de login para usuario: $username');
      
      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/login'),
        body: {
          'username': username,
          'password': password,
        },
      );

      print('Respuesta recibida. Status code: ${response.statusCode}');
      
      // Imprimir datos para debug (solo primeros 200 caracteres para no saturar logs)
      String previewBody = response.body.length > 200 
          ? response.body.substring(0, 200) + '...' 
          : response.body;
      print('Preview de respuesta: $previewBody');

      if (response.statusCode == 200) {
        // Procesa y guarda los datos
        bool result = await processLoginResponse(response.body);
        if (result) {
          _loginProcessed = true;
        }
        return result;
      } else {
        // Manejo de error
        print('Error en la solicitud: ${response.statusCode}');
        print('Cuerpo del error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  // Procesa la respuesta del login y guarda los datos
  Future<bool> processLoginResponse(String responseBody) async {
    try {
      print('Procesando respuesta de login...');
      
      // Decodifica el JSON
      final data = json.decode(responseBody);
      
      // Verifica si la respuesta es exitosa
      if (data['result'] == 'ok') {
        print('Resultado del login: OK. Procesando datos...');
        
        // Convierte los datos a objetos usando los modelos
        final ProfileDataStudent userData = ProfileDataStudent.fromJson(data);
        print('Datos de usuario convertidos correctamente');
        print('Nombre de usuario: ${userData.persona}');
        print('Email: ${userData.email}');
        print('Número de perfiles: ${userData.perfiles.length}');
        
        // Obtiene la instancia del singleton GlobalVars
        final globals = GlobalVars();
        
        // Limpiamos cualquier dato anterior para evitar conflictos
        globals.clear();
        print('GlobalVars limpiado');
        
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
        print('Datos básicos guardados en GlobalVars');
        
        // LÓGICA DE SELECCIÓN DE PERFIL
        Perfile? perfilActivo;
        
        if (userData.perfiles.isEmpty) {
          print('ADVERTENCIA: No hay perfiles disponibles');
        } else {
          // 1. Primero intentamos utilizar el perfilactivoid como criterio principal
          perfilActivo = userData.perfiles.firstWhere(
            (perfil) => perfil.idpu == userData.perfilactivoid,
            orElse: () => userData.perfiles[0]
          );
          
          print('Perfil seleccionado por perfilactivoid: ${perfilActivo.carrera}');
          
          // 2. Si el perfil no está matriculado, intentamos con resumen.idpu
          if (!perfilActivo.matriculado) {
            final perfilPorResumen = userData.perfiles.firstWhere(
              (perfil) => perfil.idpu == userData.resumen.idpu && perfil.matriculado,
              orElse: () => userData.perfiles[0]
            );
            
            if (perfilPorResumen.matriculado) {
              perfilActivo = perfilPorResumen;
              print('Perfil actualizado por resumen.idpu: ${perfilActivo.carrera}');
            }
          }
          
          // 3. Si aún no tenemos un perfil matriculado, buscamos cualquiera
          if (!perfilActivo.matriculado) {
            final perfilMatriculado = userData.perfiles.firstWhere(
              (perfil) => perfil.matriculado,
              orElse: () => userData.perfiles[0]
            );
            
            if (perfilMatriculado.matriculado) {
              perfilActivo = perfilMatriculado;
              print('Perfil actualizado a un perfil matriculado: ${perfilActivo.carrera}');
            }
          }
        }
        
        // Guardamos el perfil seleccionado
        if (perfilActivo != null) {
          globals.set('perfilActivo', perfilActivo);
          print('Perfil activo establecido: ${perfilActivo.carrera}');
          
          // Para compatibilidad con código existente
          globals.set('perfilCoincidente', perfilActivo);
          globals.set('perfilActivoID', perfilActivo);
        } else {
          print('ADVERTENCIA: No se pudo establecer un perfil activo');
        }
        
        // Guarda el resumen
        globals.set('resumen', userData.resumen);
        
        // Indicador de sesión iniciada
        globals.set('isLoggedIn', true);
        
        // Verificamos que los datos se hayan guardado correctamente
        await Future.delayed(Duration(milliseconds: 100)); // Pequeña pausa para asegurar que los datos se guarden
        
        print('Verificación de datos guardados:');
        print('Persona: ${globals.get('persona')}');
        print('Email: ${globals.get('email')}');
        print('Perfil activo: ${globals.get('perfilActivo')?.carrera ?? "No disponible"}');
        print('isLoggedIn: ${globals.get('isLoggedIn')}');
        print('Claves disponibles: ${globals.keys}');
        
        return true;
      } else {
        print('Error en la respuesta: ${data['result']}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Error procesando respuesta: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
  
  // Método para cerrar sesión
  void logout() {
    final globals = GlobalVars();
    globals.clear();
    globals.set('isLoggedIn', false);
    _loginProcessed = false;
    print('Sesión cerrada correctamente');
  }
  
  // Comprueba si el usuario está autenticado
  bool isAuthenticated() {
    final globals = GlobalVars();
    bool isLoggedIn = globals.get('isLoggedIn') == true;
    print('Estado de autenticación: $isLoggedIn');
    return isLoggedIn;
  }
  
  // Método para debug - imprime el estado actual de GlobalVars
  void printGlobalVarsState() {
    final globals = GlobalVars();
    print('====== ESTADO DE GLOBALVARS ======');
    print('Claves disponibles: ${globals.keys}');
    print('Total de claves: ${globals.count}');
    print('Autenticado: ${globals.get('isLoggedIn')}');
    print('Persona: ${globals.get('persona')}');
    print('Email: ${globals.get('email')}');
    
    final perfilActivo = globals.get('perfilActivo');
    if (perfilActivo != null) {
      print('Perfil activo: ${perfilActivo.carrera}');
      print('Perfil activo matriculado: ${perfilActivo.matriculado}');
    } else {
      print('Perfil activo: null');
    }
    
    final resumen = globals.get('resumen');
    if (resumen != null) {
      print('Resumen disponible: Sí');
      print('Resumen idpu: ${resumen.idpu}');
    } else {
      print('Resumen: null');
    }
    print('==================================');
  }
}

// Asegúrate de que GlobalVars.dart esté correctamente implementado:
// global_vars.dart


class GlobalVars {
  // Instancia privada estática
  static final GlobalVars _instance = GlobalVars._internal();

  // Constructor factory que devuelve la instancia
  factory GlobalVars() {
    return _instance;
  }

  // Constructor privado
  GlobalVars._internal();

  // Mapa para almacenar los valores
  final Map<String, dynamic> _values = HashMap<String, dynamic>();

  // Obtiene el valor asociado a la llave
  dynamic get(String key) {
    return _values[key];
  }

  // Establece un valor dinámico para una llave específica
  void set(String key, dynamic value) {
    _values[key] = value;
  }

  // Verifica si una llave existe
  bool has(String key) {
    return _values.containsKey(key);
  }

  // Elimina una llave y su valor asociado
  void remove(String key) {
    _values.remove(key);
  }

  // Limpia todas las variables almacenadas
  void clear() {
    _values.clear();
  }

  // Obtiene todas las llaves almacenadas
  Set<String> get keys => _values.keys.toSet();

  // Obtiene el número de variables almacenadas
  int get count => _values.length;

  // Devuelve una copia del mapa de valores
  Map<String, dynamic> getAll() {
    return Map<String, dynamic>.from(_values);
  }
}