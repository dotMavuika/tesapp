// lib/controllers/logout_controller.dart
import 'dart:async';

import '../model/global_vars.dart';
import '../model/profile_data.dart';
import 'package:http/http.dart' as http;

import '/services/session_manager.dart';
import '/services/local_storage_service.dart';
import '/services/credential_storage.dart';

class LogoutController {
  /// Realiza el logout del usuario
  ///
  /// Envía el token de autenticación a la API y limpia los datos de sesión
  /// Retorna un Map con:
  /// - 'success': true si el logout fue exitoso, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> logout() async {
    try {
      final profileData =
      GlobalVars().get('profileData') as ProfileDataStudent?;

      final authToken = profileData?.auth;

      final client = http.Client();

      try {
        if (authToken != null && authToken.isNotEmpty) {
          // Enviar solicitud a la API de logout (best effort)
          await client.post(
            Uri.parse('https://tesa.academicok.com/apimobile/logout'),
            body: {
              'token': authToken,
            },
          );
        }

        // Siempre limpiamos sesión local, aunque la API falle
        await _clearSessionData();

        return {
          'success': true,
          'message': 'Sesión cerrada correctamente',
        };
      } finally {
        client.close();
      }
    } catch (e) {

      // Aún si hay error, intentamos limpiar los datos localmente
      await _clearSessionData();

      return {
        'success': false,
        'message': 'Error durante el cierre de sesión: ${e.toString()}',
      };
    }
  }

  /// Limpia todos los datos de sesión almacenados (memoria + archivo + Hive)
  Future<void> _clearSessionData() async {
    // 1) Limpiar en memoria (GlobalVars)
    GlobalVars().clear();

    // 2) Limpiar SessionManager (archivo + memoria + rememberMe)
    final sessionManager = SessionManager();
    sessionManager.rememberMe = false;
    await sessionManager.clearSession();

    // 3) Limpiar credenciales recordadas ("guardar sesión")
    await CredentialsStorage.clear();

    // 4) Limpiar datos persistidos en Hive (perfil, flags, etc.)
    final storage = LocalStorageService.instance;
    await storage.clearSessionData();
    // Si quieres explicitar el flag:
    await storage.setIsLoggedIn(false);

  }
}
