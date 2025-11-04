import 'dart:convert';
import '../model/finance_data.dart';
import '../model/global_vars.dart';
import 'package:http/http.dart' as http;

class FinanceController {
  // Singleton instance
  static final FinanceController _instance = FinanceController._internal();

  // Factory constructor
  factory FinanceController() {
    return _instance;
  }

  // Private constructor
  FinanceController._internal();

  // Claves para almacenar los datos en GlobalVars
  static const String _financeDataKey = 'financeData';
  static const String _sessionCookieKey = 'sessionCookie';

  /// Obtiene los datos financieros desde el servidor
  ///
  /// Recibe el [authToken] y devuelve un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> fetchFinanceData(String authToken) async {
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
        print('Enviando solicitud de finanzas con token: $authToken');
        print('Cookie de sesión: $sessionCookie');

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
        print('Respuesta del servidor (finanzas): ${response.body}');

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
            // Crear objeto FinanceData
            final financeData = FinanceData.fromJson(data);

            // Guardar en GlobalVars
            GlobalVars().set(_financeDataKey, financeData);

            return {
              'success': true,
              'message': 'Datos financieros obtenidos correctamente',
            };
          } catch (e) {
            print('Error al convertir datos financieros: $e');
            return {
              'success': false,
              'message':
              'Error al procesar los datos financieros: ${e.toString()}',
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Error al obtener datos financieros',
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

  /// Obtiene los datos financieros
  ///
  /// Retorna los datos financieros o null si no hay datos disponibles
  FinanceData? getFinanceData() {
    return GlobalVars().has(_financeDataKey)
        ? GlobalVars().get(_financeDataKey) as FinanceData
        : null;
  }

  /// Actualiza los datos financieros desde el servidor
  ///
  /// Retorna un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> refreshFinanceData() async {
    // Verificar si hay un token de autenticación disponible
    final String? authToken = _getAuthToken();

    if (authToken == null) {
      return {
        'success': false,
        'message': 'No hay datos de autenticación disponibles',
      };
    }

    return await fetchFinanceData(authToken);
  }

  /// Limpia los datos financieros almacenados
  void clearFinanceData() {
    if (GlobalVars().has(_financeDataKey)) {
      GlobalVars().remove(_financeDataKey);
    }
  }

  /// Obtiene el token de autenticación actual
  ///
  /// Retorna el token o null si no está disponible
  String? _getAuthToken() {
    // Verificar si hay datos de perfil disponibles
    if (GlobalVars().has('profileData')) {
      final profileData = GlobalVars().get('profileData');
      if (profileData != null) {
        return profileData.auth;
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