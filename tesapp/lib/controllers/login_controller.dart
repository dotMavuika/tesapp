import 'dart:async';
import '../model/global_vars.dart';
import '../model/profile_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController {
  // Clave para almacenar la cookie de sesión
  static const String _sessionCookieKey = 'sessionCookie';

  /// Realiza la validación del login
  ///
  /// Recibe [user] y [password] y devuelve un Map con:
  /// - 'success': true si la autenticación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> login(String user, String password) async {
    try {
      // Crear un cliente HTTP para manejar cookies
      final client = http.Client();

      try {
        final response = await client.post(
          Uri.parse('https://tesa.academicok.com/apimobile/login'),
          body: {
            'user': user,
            'pass': password,
            'action': 'login',
          },
        );

        print('Respuesta recibida. Status code: ${response.statusCode}');

        // Extraer la cookie de sesión de los headers
        String? sessionCookie = _extractSessionCookie(response);

        if (response.statusCode == 200) {
          // Si el servidor devuelve una respuesta OK, parseamos el JSON
          final data = json.decode(response.body);
          print('Respuesta recibida. Data: $data');

          if (data['result'] == "ok") {
            // Guardar los datos del usuario en variables globales
            final profileData = ProfileDataStudent.fromJson(data);
            GlobalVars().set('profileData', profileData);

            // Guardar la cookie de sesión si existe
            if (sessionCookie != null) {
              print('Cookie de sesión guardada: $sessionCookie');
              GlobalVars().set(_sessionCookieKey, sessionCookie);
            } else {
              print(
                  'Advertencia: No se encontró cookie de sesión en la respuesta');
            }

            return {
              'success': true,
              'message': 'Inicio de sesión exitoso',
            };
          } else {
            return {
              'success': false,
              'message': 'Usuario o contraseña incorrectos',
            };
          }
        } else {
          // Si el servidor devuelve un error, retornamos un mensaje genérico
          return {
            'success': false,
            'message': 'Error de autenticación (${response.statusCode})',
          };
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error durante la autenticación: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Extrae la cookie de sesión de los headers de respuesta
  ///
  /// Retorna la cookie de sesión o null si no se encuentra
  String? _extractSessionCookie(http.Response response) {
    // Obtener todos los headers de Set-Cookie
    final cookies = response.headers['set-cookie'];

    if (cookies == null) {
      return null;
    }

    // Dividir múltiples cookies si existen
    final cookiesList = cookies.split(',');

    // Buscar la cookie 'sessionid'
    for (var cookie in cookiesList) {
      if (cookie.trim().startsWith('sessionid=')) {
        // Extraer el valor de la cookie
        final parts = cookie.split(';')[0].trim().split('=');
        if (parts.length == 2) {
          return parts[1];
        }
      }
    }

    return null;
  }
}
