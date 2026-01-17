// lib/controllers/user_data_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user_data.dart';
import '../services/local_storage_service.dart';
import '../services/session_manager.dart';
import 'auth_controller.dart';

class UserDataController {
  // Singleton instance
  static final UserDataController _instance = UserDataController._internal();

  // Factory constructor
  factory UserDataController() => _instance;

  // Private constructor
  UserDataController._internal();

  /// Llama a la API /apimobile/user_data con token + cookie
  Future<Map<String, dynamic>> fetchUserData(String authToken) async {
    try {
      final String? sessionCookie = _getSessionCookie();

      if (sessionCookie == null || sessionCookie.isEmpty) {
        return {
          'success': false,
          'message':
          'No hay cookie de sesión disponible. Debes iniciar sesión nuevamente.',
        };
      }

      final client = http.Client();

      try {

        final response = await client.post(
          Uri.parse('https://tesa.academicok.com/apimobile/user_data'),
          body: {
            'token': authToken,
            'action': 'user_data',
          },
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'Cookie': 'sessionid=$sessionCookie',
          },
        );

        // Manejo de posible redirección 302 (por si acaso)
        if (response.statusCode == 302) {
          final redirectUrl = response.headers['location'];
          if (redirectUrl != null) {
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
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Procesa la respuesta HTTP, decodifica JSON y guarda en cache
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {

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
            final userData = UserData.fromJson(data);

            // 👉 Guardar en cache persistente (Hive a través de LocalStorageService)
            LocalStorageService.instance.saveUserData(userData);

            return {
              'success': true,
              'message': 'Datos de usuario obtenidos correctamente',
            };
          } catch (e) {
            return {
              'success': false,
              'message':
              'Error al procesar los datos de usuario: ${e.toString()}',
            };
          }
        } else {
          return {
            'success': false,
            'message':
            data['message'] ?? 'Error al obtener datos de usuario',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message':
          'Error al procesar la respuesta (user_data): ${e.toString()}',
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

  /// Devuelve los datos de usuario desde cache (Hive) si existen
  UserData? getUserData() {
    return LocalStorageService.instance.getUserDataSync();
  }

  /// Fuerza recarga de datos desde la API usando el token actual
  Future<Map<String, dynamic>> refreshUserData() async {
    final String? authToken = _getAuthToken();

    if (authToken == null || authToken.isEmpty) {
      return {
        'success': false,
        'message': 'No hay datos de autenticación disponibles',
      };
    }

    return await fetchUserData(authToken);
  }

  /// Orden de prioridad para obtener el token:
  /// 1) AuthController (fuente de verdad actual)
  /// 2) SessionManager (legacy / fallback)
  String? _getAuthToken() {
    final fromAuth = AuthController.instance.getAuthToken();
    if (fromAuth != null && fromAuth.isNotEmpty) {
      return fromAuth;
    }

    final sm = SessionManager();
    if (sm.isLoggedIn && sm.authToken != null && sm.authToken!.isNotEmpty) {
      return sm.authToken;
    }

    return null;
  }

  /// Orden de prioridad para obtener la cookie de sesión:
  /// 1) AuthController
  /// 2) SessionManager (fallback)
  String? _getSessionCookie() {
    final fromAuth = AuthController.instance.getSessionCookie();
    if (fromAuth != null && fromAuth.isNotEmpty) {
      return fromAuth;
    }

    final sm = SessionManager();
    if (sm.sessionCookie != null && sm.sessionCookie!.isNotEmpty) {
      return sm.sessionCookie;
    }

    return null;
  }
}
