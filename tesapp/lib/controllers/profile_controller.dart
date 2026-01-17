// lib/controllers/profile_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/profile_data.dart';
import '../model/global_vars.dart';
import '../services/local_storage_service.dart';
import 'auth_controller.dart';

class ProfileController {
  // Singleton instance
  static final ProfileController _instance = ProfileController._internal();
  factory ProfileController() => _instance;
  ProfileController._internal();

  final LocalStorageService _storage = LocalStorageService.instance;

  // ─────────────────────────────────────────────────────────────
  // Helpers privados
  // ─────────────────────────────────────────────────────────────

  /// Resuelve el token de auth a usar:
  /// 1) AuthController
  /// 2) auth dentro del perfil cacheado
  String? _resolveAuthToken(ProfileDataStudent? cachedProfile) {
    final fromAuth = AuthController.instance.getAuthToken();
    if (fromAuth != null && fromAuth.isNotEmpty) {
      return fromAuth;
    }

    final fromProfile = cachedProfile?.auth;
    if (fromProfile != null && fromProfile.isNotEmpty) {
      return fromProfile;
    }

    return null;
  }

  /// Sincroniza el perfil cacheado con GlobalVars (solo en memoria).
  void _syncGlobal(ProfileDataStudent profile) {
    GlobalVars().set('profileData', profile);
    GlobalVars().set('activeProfile', profile.perfilActivo);
  }

  // ─────────────────────────────────────────────────────────────
  // Llamadas a API que SÍ necesitamos
  // ─────────────────────────────────────────────────────────────

  /// Cambia el perfil activo en la API y actualiza el perfil cacheado.
  ///
  /// OJO: aquí NO volvemos a loguear. Sólo usamos /change_profile.
  Future<Map<String, dynamic>> changeActiveProfile(int idpu) async {
    try {
      // Preferimos el perfil desde Hive (fuente persistente)
      final profileData = _storage.getProfileDataSync();

      if (profileData == null) {
        return {
          'success': false,
          'message': 'No hay datos de perfil disponibles',
        };
      }

      if (profileData.perfiles == null || profileData.perfiles!.isEmpty) {
        return {
          'success': false,
          'message': 'No hay perfiles disponibles',
        };
      }

      final profileExists =
      profileData.perfiles!.any((p) => p.idpu == idpu);

      if (!profileExists) {
        return {
          'success': false,
          'message': 'El perfil seleccionado no existe',
        };
      }

      final authToken = _resolveAuthToken(profileData);
      if (authToken == null || authToken.isEmpty) {
        return {
          'success': false,
          'message': 'No hay token de autenticación disponible',
        };
      }

      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/change_profile'),
        body: {
          'auth': authToken,
          'idpu': idpu.toString(),
          'action': 'change_profile',
        },
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Error en la solicitud (${response.statusCode})',
        };
      }

      final data = json.decode(response.body);

      if (data['result'] == "ok") {
        final updatedProfileData = ProfileDataStudent.fromJson(data);

        // 👉 Persistir nuevo perfil en Hive
        await _storage.saveProfileData(updatedProfileData);

        // 👉 Sync en memoria para vistas legacy (side_bar, etc.)
        _syncGlobal(updatedProfileData);

        return {
          'success': true,
          'message': 'Perfil actualizado correctamente',
          'data': updatedProfileData,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al cambiar el perfil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Refresca los datos de perfil.
  ///
  /// De momento:
  ///  - NO llama a /profile (porque tu backend ya da todo en /login).
  ///  - Sólo devuelve lo que haya en caché (Hive) y sincroniza GlobalVars.
  Future<Map<String, dynamic>> refreshProfileData() async {
    final profile = _storage.getProfileDataSync();

    if (profile == null) {
      return {
        'success': false,
        'message': 'No hay datos de perfil cacheados',
      };
    }

    // Sincronizamos a GlobalVars por si vistas viejas siguen leyendo de ahí
    _syncGlobal(profile);

    return {
      'success': true,
      'message': 'Perfil cargado desde caché',
      'data': profile,
    };
  }

  // ─────────────────────────────────────────────────────────────
  // Getters sobre cache persistente (Hive + GlobalVars fallback)
  // ─────────────────────────────────────────────────────────────

  /// Perfil completo cacheado (o null si no existe).
  ///
  /// 1) Intenta desde GlobalVars (si ya está en memoria).
  /// 2) Si no, lo trae de Hive y lo sincroniza a GlobalVars.
  ProfileDataStudent? getProfileData() {
    final fromGV = GlobalVars().get('profileData') as ProfileDataStudent?;
    if (fromGV != null) return fromGV;

    final stored = _storage.getProfileDataSync();
    if (stored != null) {
      _syncGlobal(stored);
    }
    return stored;
  }

  /// Perfil activo (`perfilActivo`) o null.
  Perfile? getActiveProfile() {
    // 1) Si GlobalVars ya tiene activeProfile, usarlo
    final active = GlobalVars().get('activeProfile') as Perfile?;
    if (active != null) return active;

    // 2) Fallback: sacar del perfil cacheado
    final profileData = getProfileData();
    return profileData?.perfilActivo;
  }

  /// Nombre de la carrera del perfil activo
  String? getActiveCareerName() {
    final active = getActiveProfile();
    // Normalmente viene en `carrera` o en `carrerarep`
    return active?.carrera ?? active?.carrerarep;
  }

  Resumen? getProfileSummary() {
    final profileData = getProfileData();
    return profileData?.resumen;
  }

  bool isProfileSummaryMatching() {
    final profileData = getProfileData();
    final activeProfile = getActiveProfile();

    if (profileData?.resumen == null || activeProfile == null) {
      return false;
    }

    return profileData!.resumen!.idpu == activeProfile.idpu;
  }

  List<Perfile> getAvailableProfiles() {
    final profileData = getProfileData();
    return profileData?.perfiles ?? [];
  }

  bool hasMultipleProfiles() {
    final profiles = getAvailableProfiles();
    return profiles.length > 1;
  }

  Perfile? getProfileById(int idpu) {
    final profiles = getAvailableProfiles();
    try {
      return profiles.firstWhere((p) => p.idpu == idpu);
    } catch (_) {
      return null;
    }
  }

  bool hasProfileData() {
    return getProfileData() != null;
  }

  Map<String, String?>? getUserBasicInfo() {
    final profileData = getProfileData();
    if (profileData == null) return null;

    final activeProfile = getActiveProfile();

    return {
      'nombre': profileData.persona,
      'email': profileData.email,
      'genero': profileData.genero,
      'identificacion': profileData.identificacion,
      'foto': profileData.foto,
      // 🔹 nuevo: carrera basada en el perfil activo
      'carrera': activeProfile?.carrera ?? activeProfile?.carrerarep,
    };
  }

  bool isActiveProfileStudent() {
    final activeProfile = getActiveProfile();
    return activeProfile?.isStudent ?? false;
  }

  bool isActiveProfileAdministrative() {
    final activeProfile = getActiveProfile();
    return activeProfile?.isAdministrative ?? false;
  }

  /// Devuelve el color de texto recomendado sobre el color de fondo,
  /// en formato [R, G, B], o null si no está disponible/bien formateado.
  List<int>? getTextColorOverBackground() {
    final activeProfile = getActiveProfile();
    final colorString = activeProfile?.colortextosobrecolor;

    if (colorString == null || colorString.isEmpty) return null;

    try {
      final parts = colorString
          .split(',')
          .map((s) => int.parse(s.trim()))
          .toList();
      if (parts.length == 3) return parts;
    } catch (_) {}

    return null;
  }

  /// Legacy: ya no hace nada. Lo dejo sólo para que no truene código viejo
  /// si en algún sitio todavía se llama.
  @deprecated
  void setActiveProfile(ProfileDataStudent profileData) {
    // Ya no se usa; la fuente real es Hive + _syncGlobal()
  }
}