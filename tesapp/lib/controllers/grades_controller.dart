// lib/controllers/grades_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/grades_data.dart';
import '../model/global_vars.dart';
import '../services/local_storage_service.dart';
import 'auth_controller.dart';

class GradesController {
  static final GradesController _instance = GradesController._internal();
  factory GradesController() => _instance;
  GradesController._internal();

  static const String _gradesDataKey = 'gradesData';

  Future<Map<String, dynamic>> fetchGradesData(String authToken) async {
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
          Uri.parse('https://tesa.academicok.com/apimobile/materias'),
          body: {
            'token': authToken,
            'action': 'materias',
          },
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'Cookie': 'sessionid=$sessionCookie',
          },
        );

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

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode != 200) {
      return {
        'success': false,
        'message':
        'Error en la solicitud (${response.statusCode}): ${response.reasonPhrase}',
      };
    }

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

      if (data['result'] == 'ok') {
        try {
          final gradesData =
          GradesData.fromJson(data as Map<String, dynamic>);

          // Compatibilidad: guardar en GlobalVars
          GlobalVars().set(_gradesDataKey, gradesData);

          // Cache local: Hive
          LocalStorageService.instance.saveGradesData(gradesData);


          return {
            'success': true,
            'message': 'Datos de materias obtenidos correctamente',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
            'Error al procesar los datos de materias: ${e.toString()}',
          };
        }
      } else {
        return {
          'success': false,
          'message':
          data['message'] ?? 'Error al obtener datos de materias',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message':
        'Error al procesar la respuesta: ${e.toString()}',
      };
    }
  }

  GradesData? getGradesData() {
    // 1) GlobalVars si ya está en memoria
    if (GlobalVars().has(_gradesDataKey)) {
      return GlobalVars().get(_gradesDataKey) as GradesData;
    }

    // 2) Fallback a Hive
    return LocalStorageService.instance.getGradesDataSync();
  }

  Future<Map<String, dynamic>> refreshGradesData() async {
    final String? authToken = AuthController.instance.getAuthToken();

    if (authToken == null || authToken.isEmpty) {
      return {
        'success': false,
        'message': 'No hay datos de autenticación disponibles',
      };
    }

    return await fetchGradesData(authToken);
  }
}
