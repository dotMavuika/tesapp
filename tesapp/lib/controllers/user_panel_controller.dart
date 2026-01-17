// lib/controllers/user_panel_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user_panel_data.dart';
import '../services/local_storage_service.dart';
import 'auth_controller.dart';

class UserPanelController {
  // Singleton instance
  static final UserPanelController _instance = UserPanelController._internal();

  // Factory constructor
  factory UserPanelController() => _instance;

  // Private constructor
  UserPanelController._internal();

  /// Obtiene los datos de /apimobile/user_panel desde el servidor
  ///
  /// Recibe el [authToken] y devuelve un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  /// Además, si es exitoso, guarda el UserPanelData en LocalStorageService.
  Future<Map<String, dynamic>> fetchUserPanelData(String authToken) async {
    try {
      final String? sessionCookie = AuthController.instance.getSessionCookie();

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
          Uri.parse('https://tesa.academicok.com/apimobile/user_panel'),
          body: {
            'token': authToken,
            // Si en Postman NO envías "action", puedes borrar esta línea del body.
            'action': 'user_panel',
          },
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'Cookie': 'sessionid=$sessionCookie',
          },
        );

        // Manejar redirección igual que en horario
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

  /// Procesa la respuesta HTTP para user_panel
  ///
  /// Si es exitosa:
  ///  - Crea un `UserPanelData`
  ///  - Lo guarda en LocalStorageService (cache)
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
            final panelData = UserPanelData.fromJson(data);

            // Guardar en Hive (cache local)
            LocalStorageService.instance.saveUserPanelData(panelData);

            return {
              'success': true,
              'message': 'Datos de panel obtenidos correctamente',
            };
          } catch (e) {
            return {
              'success': false,
              'message':
              'Error al procesar los datos de panel: ${e.toString()}',
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Error al obtener datos de panel',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message':
          'Error al procesar la respuesta (user_panel): ${e.toString()}',
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

  /// Obtiene los datos de user_panel desde el cache local (Hive)
  ///
  /// 👉 Esto es lo que estás usando en `GeneralProfile`:
  ///    `final cachedPanelData = userPanelController.getUserPanelData();`
  UserPanelData? getUserPanelData() {
    return LocalStorageService.instance.getUserPanelDataSync();
  }

  /// Actualiza los datos de user_panel desde el servidor
  ///
  /// Usa el token actual a través de AuthController.
  Future<Map<String, dynamic>> refreshUserPanelData() async {
    final String? authToken = AuthController.instance.getAuthToken();

    if (authToken == null || authToken.isEmpty) {
      return {
        'success': false,
        'message': 'No hay datos de autenticación disponibles',
      };
    }

    return await fetchUserPanelData(authToken);
  }
}
