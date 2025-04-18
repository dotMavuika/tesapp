import 'dart:convert';
import '../model/schedule_data.dart';
import '../model/global_vars.dart';
import 'package:http/http.dart' as http;

class ScheduleController {
  // Singleton instance
  static final ScheduleController _instance = ScheduleController._internal();

  // Factory constructor
  factory ScheduleController() {
    return _instance;
  }

  // Private constructor
  ScheduleController._internal();

  // Claves para almacenar los datos en GlobalVars
  static const String _scheduleDataKey = 'scheduleData';
  static const String _sessionCookieKey = 'sessionCookie';

  /// Obtiene los datos del horario desde el servidor
  ///
  /// Recibe el [authToken] y devuelve un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> fetchScheduleData(String authToken) async {
    try {
      // Obtener la cookie de sesión
      final String? sessionCookie = _getSessionCookie();

      if (sessionCookie == null) {
        return {
          'success': false,
          'message':
              'No hay cookie de sesión disponible. Debes iniciar sesión nuevamente.',
        };
      }

      // Configurar el cliente HTTP
      final client = http.Client();

      try {
        print('Enviando solicitud de horario con token: $authToken');
        print('Cookie de sesión: $sessionCookie');

        final response = await client.post(
          Uri.parse('https://tesa.academicok.com/apimobile/horario'),
          body: {
            'token': authToken,
            'action': 'horario',
          },
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'Cookie': 'sessionid=$sessionCookie',
          },
        );

        // Verificar si hubo redirección (código 302)
        if (response.statusCode == 302) {
          // Extraer la URL de redirección
          final redirectUrl = response.headers['location'];
          if (redirectUrl != null) {
            print('Siguiendo redirección a: $redirectUrl');
            // Seguir la redirección manualmente con la misma cookie
            final redirectResponse = await client.get(
              Uri.parse(redirectUrl),
              headers: {
                'Cookie': 'sessionid=$sessionCookie',
              },
            );
            return _processResponse(redirectResponse);
          }
        }

        return _processResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error de conexión: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Procesa la respuesta HTTP
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        // Imprimir la respuesta para depuración
        print('Respuesta del servidor (horario): ${response.body}');

        // Verificar si la respuesta está vacía
        if (response.body.isEmpty) {
          return {
            'success': false,
            'message': 'El servidor devolvió una respuesta vacía',
          };
        }

        final data = json.decode(response.body);

        if (data == null) {
          return {
            'success': false,
            'message': 'Error al decodificar la respuesta JSON',
          };
        }

        if (data['result'] == "ok") {
          try {
            // Crear objeto ScheduleData
            final scheduleData = ScheduleData.fromJson(data);

            // Guardar en GlobalVars
            GlobalVars().set(_scheduleDataKey, scheduleData);

            return {
              'success': true,
              'message': 'Datos de horario obtenidos correctamente',
            };
          } catch (e) {
            print('Error al convertir datos de horario: $e');
            return {
              'success': false,
              'message':
                  'Error al procesar los datos de horario: ${e.toString()}',
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Error al obtener datos del horario',
          };
        }
      } catch (e) {
        print('Error al procesar la respuesta: $e');
        return {
          'success': false,
          'message': 'Error al procesar la respuesta: ${e.toString()}',
        };
      }
    } else {
      return {
        'success': false,
        'message':
            'Error en la solicitud (${response.statusCode}): ${response.reasonPhrase}',
      };
    }
  }

  /// Obtiene los datos del horario
  ///
  /// Retorna los datos del horario o null si no hay datos disponibles
  ScheduleData? getScheduleData() {
    return GlobalVars().has(_scheduleDataKey)
        ? GlobalVars().get(_scheduleDataKey) as ScheduleData
        : null;
  }

  /// Actualiza los datos del horario desde el servidor
  ///
  /// Retorna un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> refreshScheduleData() async {
    // Verificar si hay un token de autenticación disponible
    final String? authToken = _getAuthToken();

    if (authToken == null) {
      return {
        'success': false,
        'message': 'No hay datos de autenticación disponibles',
      };
    }

    return await fetchScheduleData(authToken);
  }

  /// Obtiene el token de autenticación actual
  ///
  /// Retorna el token o null si no está disponible
  String? _getAuthToken() {
    // Verificar si hay datos de perfil disponibles
    if (GlobalVars().has('profileData')) {
      final profileData = GlobalVars().get('profileData');
      if (profileData != null) {
        return profileData
            .auth; // auth es el token según tu modelo ProfileDataStudent
      }
    }

    // Si no hay datos de perfil, buscar el token directamente
    if (GlobalVars().has('authToken')) {
      return GlobalVars().get('authToken') as String?;
    }

    return null;
  }

  /// Obtiene la cookie de sesión actual
  ///
  /// Retorna la cookie o null si no está disponible
  String? _getSessionCookie() {
    // Buscar la cookie de sesión en GlobalVars
    if (GlobalVars().has(_sessionCookieKey)) {
      return GlobalVars().get(_sessionCookieKey) as String?;
    }

    return null;
  }
}
