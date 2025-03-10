import 'dart:async';
import '../model/global_vars.dart';
import '../model/profile_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController {
  /// Realiza la validación del login
  /// 
  /// Recibe [user] y [password] y devuelve un Map con:
  /// - 'success': true si la autenticación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> login(String user, String password) async {
    try {
      // Simulando una petición a un servidor
      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/login'),
        body: {
          'user': user,
          'pass': password,
          'action'  : 'login',
        },
      );

      print('Respuesta recibida. Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Si el servidor devuelve una respuesta OK, parseamos el JSON
        final data = json.decode(response.body);
        print('Respuesta recibida. Data: $data');
        
        // Si el JSON contiene un campo 'result' diferente de "ok", la autenticación fue exitosa
        // Note: Esta lógica parece estar invertida en el código original, verificar si es correcto
        if (data['result'] == "ok") {
          // Guardar los datos del usuario en variables globales
          final profileData = ProfileDataStudent.fromJson(data);
          GlobalVars().set('profileData', profileData);
          
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
    } catch (e) {
      print('Error durante la autenticación: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }
}