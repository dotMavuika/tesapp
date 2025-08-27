import 'dart:async';
import '../model/global_vars.dart';
import '../model/profile_data.dart';
import 'package:http/http.dart' as http;

class LogoutController {
  /// Realiza el logout del usuario
  ///
  /// Envía el token de autenticación a la API y limpia los datos de sesión
  /// Retorna un Map con:
  /// - 'success': true si el logout fue exitoso, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> logout() async {
    try {
      // Obtener el token de autenticación de las variables globales
      final profileData = GlobalVars().get('profileData') as ProfileDataStudent?;

      if (profileData == null) {
        // Si no hay datos de perfil, consideramos que ya está deslogueado
        _clearSessionData();
        return {
          'success': true,
          'message': 'Sesión cerrada',
        };
      }

      // Obtener el token de autenticación
      final authToken = profileData.auth;

      // Crear un cliente HTTP
      final client = http.Client();

      try {
        // Enviar solicitud a la API de logout
        await client.post(
          Uri.parse('https://tesa.academicok.com/apimobile/logout'),
          body: {
            'token': authToken,
          },
        );

        // No es necesario esperar a una respuesta específica
        // Limpiamos los datos de sesión independientemente
        _clearSessionData();

        return {
          'success': true,
          'message': 'Sesión cerrada correctamente',
        };
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error durante el cierre de sesión: $e');

      // Aún si hay error, intentamos limpiar los datos localmente
      _clearSessionData();

      return {
        'success': false,
        'message': 'Error durante el cierre de sesión: ${e.toString()}',
      };
    }
  }

  /// Limpia todos los datos de sesión almacenados
  void _clearSessionData() {
    // Eliminar los datos de perfil
    GlobalVars().remove('profileData');

    // Eliminar la cookie de sesión si existe
    GlobalVars().remove('sessionCookie');

    // Puedes agregar aquí la limpieza de cualquier otro dato relacionado con la sesión
    print('Datos de sesión eliminados');
  }
}