// lib/controllers/login_controller.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/global_vars.dart';
import '../model/profile_data.dart';
import '/services/session_manager.dart';
import '/services/credential_storage.dart';
import 'auth_controller.dart';

// 👉 nuevos imports de controladores que vamos a prefetchear
import 'user_panel_controller.dart';
import 'schedule_controller.dart';
import 'grades_controller.dart';
import 'finance_controller.dart';
import 'record_academico_controller.dart';

class LoginController {
  static const String _sessionCookieKey = 'sessionCookie';

  /// Realiza la validación del login
  ///
  /// [rememberSession] controla si:
  ///  - se guardan credenciales en Hive (CredentialsStorage)
  ///  - se marca la sesión como "recordada" para futuros arranques
  Future<Map<String, dynamic>> login(
      String user,
      String password, {
        bool rememberSession = false,
      }) async {
    try {
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


        // Intentar extraer la cookie de sesión SIEMPRE
        final String? sessionCookie = _extractSessionCookie(response);

        if (response.statusCode != 200) {
          // HTTP error → limpiar sesión
          await SessionManager().clearSession();

          return {
            'success': false,
            'message': 'Error de autenticación (${response.statusCode})',
          };
        }

        final data = json.decode(response.body);

        if (data['result'] != 'ok') {
          // Login rechazado → limpiar sesión + credenciales
          await SessionManager().clearSession();
          await CredentialsStorage.clear();
             return {
            'success': false,
            'message': data['message'] ?? 'Usuario o contraseña incorrectos',
          };
        }

        // --------------------------
        //  ✅ Login exitoso
        // --------------------------

        // 1) Construimos ProfileDataStudent desde el JSON de /login
        final profileData = ProfileDataStudent.fromJson(data);

        // 2) Guardamos en GlobalVars (compatibilidad con el resto de la app)
        GlobalVars().set('profileData', profileData);
        GlobalVars().set('activeProfile', profileData.perfilActivo);

        if (profileData.auth != null && profileData.auth!.isNotEmpty) {
          GlobalVars().set('authToken', profileData.auth);
        }

        // 3) Guardar cookie de sesión en GlobalVars si existe
        if (sessionCookie != null && sessionCookie.isNotEmpty) {
          GlobalVars().set(_sessionCookieKey, sessionCookie);
          GlobalVars().set('sessionCookie', sessionCookie);
        } else {
        }

        // 4) Guardar credenciales sólo si el usuario marcó "Guardar sesión"
        if (rememberSession) {
          await CredentialsStorage.save(user, password);
        } else {
          await CredentialsStorage.clear();
        }

        final token = profileData.auth ?? '';

        // 5) Actualizar SessionManager (memoria + archivo sólo si rememberSession=true)
        await SessionManager().saveSession(
          token: token,
          remember: rememberSession,
          sessionCookie: sessionCookie,
        );

        // 6) Sincronizar AuthController (memoria + Hive + flag isLoggedIn)
        await AuthController.instance.persistCurrentSession(
          rememberSession: rememberSession,
        );

        // 7) Prefetch de datos importantes para que el menú y las vistas
        //    ya tengan info sin depender de entrar a "Récord académico".
        if (token.isNotEmpty) {
          _prefetchAfterLogin(token);
        }

        return {
          'success': true,
          'message': 'Inicio de sesión exitoso',
          'token': token,
        };
      } finally {
        client.close();
      }
    } catch (e) {

      await SessionManager().clearSession();
      await CredentialsStorage.clear();

      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Prefetch en segundo plano de los módulos clave:
  /// - user_panel (dashboard/principal)
  /// - horario
  /// - materias/notas
  /// - finanzas
  /// - récord académico
  void _prefetchAfterLogin(String token) async {
    try {

      await Future.wait([
        UserPanelController().fetchUserPanelData(token),
        ScheduleController().fetchScheduleData(token),
        GradesController().fetchGradesData(token),
        FinanceController().fetchFinanceData(token),
        RecordAcademicoController().fetchRecordAcademico(token),
      ]);

    } catch (e) {
    }
  }

  /// Extrae la cookie de sesión de los headers de respuesta
  String? _extractSessionCookie(http.Response response) {
    final cookies = response.headers['set-cookie'];
    if (cookies == null) return null;

    final cookiesList = cookies.split(',');

    for (var cookie in cookiesList) {
      if (cookie.trim().startsWith('sessionid=')) {
        final parts = cookie.split(';')[0].trim().split('=');
        if (parts.length == 2) {
          return parts[1];
        }
      }
    }

    return null;
  }
}
