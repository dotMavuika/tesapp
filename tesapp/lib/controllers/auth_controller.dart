// lib/controllers/auth_controller.dart
import 'package:flutter/foundation.dart';

import '../model/global_vars.dart';
import '../model/profile_data.dart';
import '../model/user_data.dart';
import '../model/user_panel_data.dart';
import '../model/schedule_data.dart';
import '../model/grades_data.dart';
import '../model/finance_data.dart';

import '../services/local_storage_service.dart';
import '../services/session_manager.dart';
import 'logout_controller.dart';

class AuthController with ChangeNotifier {
  AuthController._internal();

  /// 🔹 Constructor especial para tests
  /// No toca el singleton `instance`, se usa solo en widget_test.dart
  @visibleForTesting
  AuthController.test({
    bool isInitialized = true,
    bool isLoggedIn = false,
  })  : _isInitialized = isInitialized,
        _isLoggedIn = isLoggedIn;

  static final AuthController _instance = AuthController._internal();
  static AuthController get instance => _instance;

  bool _isInitialized = false;
  bool _isLoggedIn = false;

  /// 👉 cache en memoria (sombra de SessionManager)
  String? _authToken;
  String? _sessionCookie;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;

  /// Atajos públicos
  String? get authToken => getAuthToken();
  String? get sessionCookie => getSessionCookie();

  /// 🔹 Se llama en main() para levantar sesión desde disco (Hive + archivo)
  Future<void> init() async {
    final storage = LocalStorageService.instance;
    final sessionManager = SessionManager();

    // Nos aseguramos de cargar lo que haya en el archivo de sesión
    await sessionManager.loadSession();

    final isLogged = await storage.getIsLoggedIn();
    final profile = storage.getProfileDataSync();

    final storedAuthToken = sessionManager.authToken;
    final storedSessionCookie = sessionManager.sessionCookie;

    if (isLogged &&
        profile != null &&
        storedAuthToken != null &&
        storedSessionCookie != null) {
      // Actualizar estado en memoria
      _authToken = storedAuthToken;
      _sessionCookie = storedSessionCookie;

      // Compatibilidad con el código existente que sigue usando GlobalVars
      GlobalVars().set('profileData', profile);
      GlobalVars().set('activeProfile', profile.perfilActivo);
      GlobalVars().set('authToken', storedAuthToken);
      GlobalVars().set('sessionCookie', storedSessionCookie);

      // Cargar datos cacheados opcionales
      final userData = storage.getUserDataSync();
      if (userData != null) GlobalVars().set('userData', userData);

      final panelData = storage.getUserPanelDataSync();
      if (panelData != null) GlobalVars().set('userPanelData', panelData);

      final scheduleData = storage.getScheduleDataSync();
      if (scheduleData != null) GlobalVars().set('scheduleData', scheduleData);

      final gradesData = storage.getGradesDataSync();
      if (gradesData != null) GlobalVars().set('gradesData', gradesData);

      final financeData = storage.getFinanceDataSync();
      if (financeData != null) GlobalVars().set('financeData', financeData);

      _isLoggedIn = true;
    } else {
      _authToken = null;
      _sessionCookie = null;
      _isLoggedIn = false;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// 🔹 Se llama justo DESPUÉS de un login exitoso
  ///
  /// Usa los datos ya puestos en GlobalVars por el LoginController
  /// y los persiste como "sesión actual" + cache básica.
  ///
  /// 👉 AHORA respeta [rememberSession]:
  ///    - false → sólo sesión en memoria (sin auto-login futuro).
  ///    - true  → persiste en Hive + SessionManager para auto-login.
  Future<void> persistCurrentSession({
    required bool rememberSession,
  }) async {
    final storage = LocalStorageService.instance;
    final sessionManager = SessionManager();

    final profile = GlobalVars().get('profileData') as ProfileDataStudent?;
    final authTokenFromProfile = profile?.auth;

    final authTokenFromGlobal = GlobalVars().has('authToken')
        ? GlobalVars().get('authToken') as String?
        : null;

    final sessionCookieFromGlobal = GlobalVars().has('sessionCookie')
        ? GlobalVars().get('sessionCookie') as String?
        : null;

    final effectiveAuthToken = authTokenFromProfile ?? authTokenFromGlobal;
    final effectiveSessionCookie = sessionCookieFromGlobal;

    // Si falta algo crítico, no persistimos nada
    if (profile == null ||
        effectiveAuthToken == null ||
        effectiveSessionCookie == null) {
      debugPrint(
          '⚠️ persistCurrentSession → faltan datos críticos (profile/token/cookie)');
      return;
    }

    // 👉 Actualizar cache en memoria del AuthController
    _authToken = effectiveAuthToken;
    _sessionCookie = effectiveSessionCookie;

    // 👉 Mantener SessionManager coherente en MEMORIA SIEMPRE
    sessionManager.authToken = effectiveAuthToken;
    sessionManager.sessionCookie = effectiveSessionCookie;
    sessionManager.rememberMe = rememberSession;

    // 👉 SIEMPRE cacheamos datos funcionales en Hive
    await storage.saveProfileData(profile);

    final userData = GlobalVars().get('userData') as UserData?;
    if (userData != null) {
      await storage.saveUserData(userData);
    }

    final panelData = GlobalVars().get('userPanelData') as UserPanelData?;
    if (panelData != null) {
      await storage.saveUserPanelData(panelData);
    }

    final scheduleData = GlobalVars().get('scheduleData') as ScheduleData?;
    if (scheduleData != null) {
      await storage.saveScheduleData(scheduleData);
    }

    final gradesData = GlobalVars().get('gradesData') as GradesData?;
    if (gradesData != null) {
      await storage.saveGradesData(gradesData);
    }

    final financeData = GlobalVars().get('financeData') as FinanceData?;
    if (financeData != null) {
      await storage.saveFinanceData(financeData);
    }

    // 👉 ESTE flag en Hive sólo sirve para AUTOLOGIN FUTURO
    await storage.setIsLoggedIn(rememberSession);

    // ✅ Pero en ESTA ejecución, SIEMPRE estamos logueados
    _isLoggedIn = true;
    notifyListeners();

    debugPrint(
        '✅ persistCurrentSession → isLoggedIn=true (rememberSession=$rememberSession)');
  }

  /// 🔹 Cierre de sesión global
  Future<void> logout() async {
    // Hace la llamada al backend y limpia SessionManager + LocalStorageService
    await LogoutController().logout();

    GlobalVars().clear(); // compatibilidad

    _authToken = null;
    _sessionCookie = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// 🔹 Helper principal para obtener el token de auth
  ///
  /// 👉 Los demás controladores deberían usar ESTO
  /// en lugar de leer directamente de GlobalVars.
  String? getAuthToken() {
    final sessionManager = SessionManager();

    // 1. Preferir la fuente central de sesión
    if (sessionManager.authToken != null &&
        sessionManager.authToken!.isNotEmpty) {
      _authToken = sessionManager.authToken;
      return _authToken;
    }

    // 2. Cache en memoria del propio AuthController
    if (_authToken != null && _authToken!.isNotEmpty) {
      return _authToken;
    }

    // 3. Intentar derivarlo del profileData en GlobalVars (legacy)
    final profile = GlobalVars().get('profileData') as ProfileDataStudent?;
    if (profile?.auth != null && profile!.auth!.isNotEmpty) {
      _authToken = profile.auth;
      return _authToken;
    }

    // 4. Último fallback: authToken crudo en GlobalVars
    if (GlobalVars().has('authToken')) {
      final token = GlobalVars().get('authToken') as String?;
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        return _authToken;
      }
    }

    return null;
  }

  /// 🔹 Helper para obtener la cookie de sesión actual
  ///
  /// Igual idea: usar esto en vez de leer `GlobalVars().get('sessionCookie')`
  String? getSessionCookie() {
    final sessionManager = SessionManager();

    // 1. Preferir valor del SessionManager
    if (sessionManager.sessionCookie != null &&
        sessionManager.sessionCookie!.isNotEmpty) {
      _sessionCookie = sessionManager.sessionCookie;
      return _sessionCookie;
    }

    // 2. Cache en memoria del AuthController
    if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
      return _sessionCookie;
    }

    // 3. Fallback a GlobalVars (legacy)
    if (GlobalVars().has('sessionCookie')) {
      final cookie = GlobalVars().get('sessionCookie') as String?;
      if (cookie != null && cookie.isNotEmpty) {
        _sessionCookie = cookie;
        return _sessionCookie;
      }
    }

    return null;
  }

  /// 🔹 Refrescar datos de perfil
  ///
  /// Por ahora:
  /// - Relee el profile guardado en Hive (si existe)
  /// - Actualiza GlobalVars y notifica listeners
  Future<void> refreshProfile() async {
    // Primero intentamos desde LocalStorage (Hive)
    final storage = LocalStorageService.instance;
    final storedProfile = storage.getProfileDataSync();

    if (storedProfile != null) {
      GlobalVars().set('profileData', storedProfile);
      GlobalVars().set('activeProfile', storedProfile.perfilActivo);

      // Asegurarnos de tener authToken en memoria si viene en el perfil
      if (storedProfile.auth != null && storedProfile.auth!.isNotEmpty) {
        _authToken = storedProfile.auth;
      }

      notifyListeners();
      return;
    }

    // Si en algún momento decides re-activar un endpoint de perfil,
    // aquí podríamos intentar llamar a la API usando getAuthToken().
  }
}
