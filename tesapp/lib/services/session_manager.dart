// lib/services/session_manager.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SessionManager {
  // Singleton clásico
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  /// Token de autenticación actual (profileData.auth)
  String? authToken;

  /// Cookie de sesión (sessionid=...)
  String? sessionCookie;

  /// Si el usuario marcó "Guardar sesión"
  bool rememberMe = false;

  bool get isLoggedIn => authToken != null && authToken!.isNotEmpty;

  static const String _sessionFileName = '.tesa_session.json';

  Future<File> _getSessionFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_sessionFileName');
  }

  /// Cargar sesión desde archivo (se usa al arrancar la app)
  Future<void> loadSession() async {
    try {
      final file = await _getSessionFile();
      if (!await file.exists()) {
        authToken = null;
        sessionCookie = null;
        rememberMe = false;
        return;
      }

      final content = await file.readAsString();
      final data = jsonDecode(content);

      if (data is Map) {
        final remember = data['rememberMe'] == true;
        final token = data['token'] as String?;
        final cookie = data['sessionCookie'] as String?;

        if (remember && token != null && token.isNotEmpty) {
          authToken = token;
          sessionCookie = cookie;
          rememberMe = true;

        } else {
          authToken = null;
          sessionCookie = null;
          rememberMe = false;
        }
      } else {
        authToken = null;
        sessionCookie = null;
        rememberMe = false;
      }
    } catch (e) {

      authToken = null;
      sessionCookie = null;
      rememberMe = false;
    }
  }

  /// Guardar sesión EN MEMORIA y opcionalmente en archivo
  Future<void> saveSession({
    required String token,
    required bool remember,
    String? sessionCookie,
  }) async {
    authToken = token;
    rememberMe = remember;
    this.sessionCookie = sessionCookie;

    final file = await _getSessionFile();

    if (!remember) {
      // El usuario NO quiere guardar sesión → borrar archivo si existe
      if (await file.exists()) {
        await file.delete();
      }

      return;
    }

    final data = <String, dynamic>{
      'token': token,
      'rememberMe': true,
    };

    if (sessionCookie != null && sessionCookie.isNotEmpty) {
      data['sessionCookie'] = sessionCookie;
    }

    await file.writeAsString(jsonEncode(data));

  }

  /// Limpiar sesión tanto en memoria como en disco (logout real)
  Future<void> clearSession() async {
    authToken = null;
    sessionCookie = null;
    rememberMe = false;

    try {
      final file = await _getSessionFile();
      if (await file.exists()) {
        await file.delete();
      }

    } catch (e) {

    }
  }

  /// Valida el token+cookie contra la API.
  ///
  /// - Devuelve `false` sólo si el servidor dice claramente que es inválido (401/403 o result != ok).
  /// - En errores de red u otros códigos (500, timeout, etc.) devuelve `true`
  ///   para permitir modo offline con los últimos datos cacheados.
  Future<bool> validateSession() async {
    if (authToken == null || authToken!.isEmpty) {

      return false;
    }
    if (sessionCookie == null || sessionCookie!.isEmpty) {

      return false;
    }

    try {

      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/user_data'),
        body: {
          'token': authToken!,
          'action': 'user_data',
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Cookie': 'sessionid=$sessionCookie',
        },
      );



      if (response.statusCode == 200) {
        if (response.body.isEmpty) {

          return false;
        }
        final data = jsonDecode(response.body);
        if (data is Map && data['result'] == 'ok') {

          return true;
        }

        return false;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {

        return false;
      }

      // Otros códigos (500, 502, etc.) → asumimos que puede ser problema
      // del servidor o de red y permitimos entrar en modo offline.

      return true;
    } catch (e) {
      // Errores de red, timeout, sin conexión → asumimos válida para modo offline

      return true;
    }
  }
}
