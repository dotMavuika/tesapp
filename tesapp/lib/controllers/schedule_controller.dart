// lib/controllers/schedule_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/schedule_data.dart';
import '../services/local_storage_service.dart';
import 'auth_controller.dart';

class ScheduleController {
  // Singleton instance
  static final ScheduleController _instance = ScheduleController._internal();

  // Factory constructor
  factory ScheduleController() => _instance;

  // Private constructor
  ScheduleController._internal();

  /// Llama a /apimobile/horario con el [authToken].
  ///
  /// - Usa la cookie actual desde AuthController.
  /// - Si es exitoso, guarda el ScheduleData en LocalStorageService.
  Future<Map<String, dynamic>> fetchScheduleData(String authToken) async {
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

        // Manejo de redirección (por si el backend hace 302)
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

  /// Procesa la respuesta HTTP y, si es correcta,
  /// guarda el horario en Hive mediante LocalStorageService.
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
            final scheduleData = ScheduleData.fromJson(data);

            // Cache local: Hive
            LocalStorageService.instance.saveScheduleData(scheduleData);

            return {
              'success': true,
              'message': 'Datos de horario obtenidos correctamente',
            };
          } catch (e) {
            return {
              'success': false,
              'message':
              'Error al procesar los datos de horario: ${e.toString()}',
            };
          }
        } else {
          return {
            'success': false,
            'message':
            data['message'] ?? 'Error al obtener datos del horario',
          };
        }
      } catch (e) {
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

  /// Obtiene el horario desde el cache local (Hive).
  ///
  /// 👉 Esto es lo que usa tu `ScheduleScreen._initializeScheduleData()`
  ///    cuando llama a `getScheduleData()`.
  ScheduleData? getScheduleData() {
    return LocalStorageService.instance.getScheduleDataSync();
  }

  /// Fuerza refresco de horario desde la API usando el token actual.
  Future<Map<String, dynamic>> refreshScheduleData() async {
    final String? authToken = AuthController.instance.getAuthToken();

    if (authToken == null || authToken.isEmpty) {
      return {
        'success': false,
        'message': 'No hay datos de autenticación disponibles',
      };
    }

    return await fetchScheduleData(authToken);
  }
}
