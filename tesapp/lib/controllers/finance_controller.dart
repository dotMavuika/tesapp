// lib/controllers/finance_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/finance_data.dart';
import '../services/local_storage_service.dart';
import 'auth_controller.dart';

class FinanceController {
  // Singleton instance
  static final FinanceController _instance = FinanceController._internal();

  // Factory constructor
  factory FinanceController() => _instance;

  // Private constructor
  FinanceController._internal();

  /// Llama a /apimobile/finanzas con el [authToken].
  ///
  /// - Usa la cookie actual desde AuthController.
  /// - Si es exitoso, guarda FinanceData en LocalStorageService.
  Future<Map<String, dynamic>> fetchFinanceData(String authToken) async {
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
          Uri.parse('https://tesa.academicok.com/apimobile/finanzas'),
          body: {
            'token': authToken,
            'action': 'finanzas',
          },
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'Cookie': 'sessionid=$sessionCookie',
          },
        );

        // Manejo de redirección (302) como en otros controladores
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

  /// Procesa la respuesta HTTP y, si es correcta, guarda los datos en Hive.
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
            final financeData = FinanceData.fromJson(data);

            // Cache local en Hive
            LocalStorageService.instance.saveFinanceData(financeData);

            return {
              'success': true,
              'message': 'Datos financieros obtenidos correctamente',
            };
          } catch (e) {
            return {
              'success': false,
              'message':
              'Error al procesar los datos financieros: ${e.toString()}',
            };
          }
        } else {
          return {
            'success': false,
            'message':
            data['message'] ?? 'Error al obtener datos financieros',
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

  /// Obtiene los datos financieros cacheados desde Hive.
  ///
  /// 👉 Esto es lo que usa `FinanceView` en `_initializeFinanceData()`.
  FinanceData? getFinanceData() {
    return LocalStorageService.instance.getFinanceDataSync();
  }

  /// Fuerza refresco de datos financieros desde la API usando el token actual.
  Future<Map<String, dynamic>> refreshFinanceData() async {
    final String? authToken = AuthController.instance.getAuthToken();

    if (authToken == null || authToken.isEmpty) {
      return {
        'success': false,
        'message': 'No hay datos de autenticación disponibles',
      };
    }

    return await fetchFinanceData(authToken);
  }
}
