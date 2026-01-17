// lib/controllers/record_academico_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/record_academico_data.dart';
import '../services/local_storage_service.dart';
import 'auth_controller.dart';

class RecordAcademicoController {
  // Singleton
  static final RecordAcademicoController _instance =
  RecordAcademicoController._internal();

  factory RecordAcademicoController() => _instance;

  RecordAcademicoController._internal();

  /// Llama a /apimobile/recordacademico con el [authToken].
  ///
  /// - Usa la cookie actual desde AuthController.
  /// - Si es exitoso, guarda RecordAcademicoData en LocalStorage (Hive).
  Future<Map<String, dynamic>> fetchRecordAcademico(String authToken) async {
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
          Uri.parse('https://tesa.academicok.com/apimobile/recordacademico'),
          body: {
            'token': authToken,
            'action': 'recordacademico',
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

  /// Procesa la respuesta HTTP y guarda el record en Hive si todo va bien.
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

        if (data['result'] == 'ok') {
          try {
            final recordData =
            RecordAcademicoData.fromJson(data as Map<String, dynamic>);

            // Cache local en Hive
            LocalStorageService.instance.saveRecordAcademicoData(recordData);

            return {
              'success': true,
              'message': 'Registro académico obtenido correctamente',
            };
          } catch (e) {
            return {
              'success': false,
              'message':
              'Error al procesar el registro académico: ${e.toString()}',
            };
          }
        } else {
          return {
            'success': false,
            'message':
            data['message'] ?? 'Error al obtener registro académico',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message':
          'Error al procesar la respuesta (recordacademico): ${e.toString()}',
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

  /// Devuelve el record académico cacheado desde Hive.
  RecordAcademicoData? getRecordAcademicoData() {
    return LocalStorageService.instance.getRecordAcademicoDataSync();
  }

  /// Fuerza refresco del record académico desde la API usando el token actual.
  Future<Map<String, dynamic>> refreshRecordAcademicoData() async {
    final String? authToken = AuthController.instance.getAuthToken();

    if (authToken == null || authToken.isEmpty) {
      return {
        'success': false,
        'message': 'No hay token de autenticación disponible',
      };
    }

    return await fetchRecordAcademico(authToken);
  }
}
