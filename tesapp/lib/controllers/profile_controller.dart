import 'dart:convert';
import '../model/profile_data.dart';
import '../model/global_vars.dart';
import 'package:http/http.dart' as http;

class ProfileController {
  // Singleton instance
  static final ProfileController _instance = ProfileController._internal();

  // Factory constructor
  factory ProfileController() {
    return _instance;
  }

  // Private constructor
  ProfileController._internal();

  /// Obtiene los datos del perfil desde el servidor
  ///
  /// Recibe el [authToken] y devuelve un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  /// - 'data': ProfileDataStudent si fue exitoso
  Future<Map<String, dynamic>> fetchProfileData(String authToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/profile'),
        body: {
          'auth': authToken,
          'action': 'profile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] == "ok") {
          // Crear objeto ProfileDataStudent
          final profileData = ProfileDataStudent.fromJson(data);

          // Guardar en GlobalVars
          GlobalVars().set('profileData', profileData);

          // Guardar perfil activo en GlobalVars
          setActiveProfile(profileData);

          return {
            'success': true,
            'message': 'Datos de perfil obtenidos correctamente',
            'data': profileData,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Error al obtener datos del perfil',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Error en la solicitud (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Establece el perfil activo del estudiante
  ///
  /// Busca el perfil que coincide con el perfilactivoid en la lista de perfiles
  /// y lo guarda en GlobalVars como 'activeProfile'
  void setActiveProfile(ProfileDataStudent profileData) {
    // Verificar si hay perfiles disponibles
    if (profileData.perfiles == null || profileData.perfiles!.isEmpty) {
      return;
    }

    // Usar el helper perfilActivo del modelo
    final activeProfile = profileData.perfilActivo;

    // Guardar el perfil activo en GlobalVars
    if (activeProfile != null) {
      GlobalVars().set('activeProfile', activeProfile);
    }
  }

  /// Cambia el perfil activo del estudiante
  ///
  /// Recibe el [idpu] del perfil que se quiere activar y devuelve un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> changeActiveProfile(int idpu) async {
    try {
      // Obtener datos del perfil de GlobalVars
      final profileData =
          GlobalVars().get('profileData') as ProfileDataStudent?;

      if (profileData == null) {
        return {
          'success': false,
          'message': 'No hay datos de perfil disponibles',
        };
      }

      // Verificar si hay perfiles disponibles
      if (profileData.perfiles == null || profileData.perfiles!.isEmpty) {
        return {
          'success': false,
          'message': 'No hay perfiles disponibles',
        };
      }

      // Verificar si el idpu existe en la lista de perfiles
      final profileExists = profileData.perfiles!.any((p) => p.idpu == idpu);

      if (!profileExists) {
        return {
          'success': false,
          'message': 'El perfil seleccionado no existe',
        };
      }

      // Verificar que hay auth token
      if (profileData.auth == null) {
        return {
          'success': false,
          'message': 'No hay token de autenticación disponible',
        };
      }

      // Actualizar el perfil activo en el servidor
      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/change_profile'),
        body: {
          'auth': profileData.auth!,
          'idpu': idpu.toString(),
          'action': 'change_profile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] == "ok") {
          // Actualizar datos con la nueva respuesta
          final updatedProfileData = ProfileDataStudent.fromJson(data);

          // Guardar en GlobalVars
          GlobalVars().set('profileData', updatedProfileData);

          // Actualizar el perfil activo
          setActiveProfile(updatedProfileData);

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
      } else {
        return {
          'success': false,
          'message': 'Error en la solicitud (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtiene el perfil activo actualmente
  ///
  /// Retorna el perfil activo o null si no hay ninguno
  Perfile? getActiveProfile() {
    return GlobalVars().get('activeProfile') as Perfile?;
  }

  /// Obtiene todos los datos del perfil (ProfileDataStudent)
  ///
  /// Retorna ProfileDataStudent o null si no hay datos disponibles
  ProfileDataStudent? getProfileData() {
    return GlobalVars().get('profileData') as ProfileDataStudent?;
  }

  /// Obtiene el resumen del perfil activo
  ///
  /// Retorna el resumen del perfil o null si no hay datos disponibles
  Resumen? getProfileSummary() {
    final profileData = GlobalVars().get('profileData') as ProfileDataStudent?;
    return profileData?.resumen;
  }

  /// Verifica si el resumen del perfil y el perfil activo tienen el mismo idpu
  ///
  /// Retorna true si coinciden, false en caso contrario
  bool isProfileSummaryMatching() {
    final profileData = GlobalVars().get('profileData') as ProfileDataStudent?;
    final activeProfile = getActiveProfile();

    if (profileData?.resumen == null || activeProfile == null) {
      return false;
    }

    return profileData!.resumen!.idpu == activeProfile.idpu;
  }

  /// Actualiza los datos del perfil desde el servidor
  ///
  /// Retorna un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> refreshProfileData() async {
    final profileData = GlobalVars().get('profileData') as ProfileDataStudent?;

    if (profileData == null || profileData.auth == null) {
      return {
        'success': false,
        'message': 'No hay datos de perfil disponibles',
      };
    }

    return await fetchProfileData(profileData.auth!);
  }

  /// Obtiene la lista de perfiles disponibles
  ///
  /// Retorna una lista de Perfile o una lista vacía si no hay perfiles
  List<Perfile> getAvailableProfiles() {
    final profileData = GlobalVars().get('profileData') as ProfileDataStudent?;
    return profileData?.perfiles ?? [];
  }

  /// Verifica si el usuario tiene múltiples perfiles
  ///
  /// Retorna true si hay más de un perfil disponible
  bool hasMultipleProfiles() {
    final profiles = getAvailableProfiles();
    return profiles.length > 1;
  }

  /// Obtiene el perfil por idpu
  ///
  /// Retorna el Perfile correspondiente o null si no se encuentra
  Perfile? getProfileById(int idpu) {
    final profiles = getAvailableProfiles();
    try {
      return profiles.firstWhere((p) => p.idpu == idpu);
    } catch (e) {
      return null;
    }
  }

  /// Limpia todos los datos del perfil de GlobalVars
  ///
  /// Útil para el logout
  void clearProfileData() {
    GlobalVars().remove('profileData');
    GlobalVars().remove('activeProfile');
  }

  /// Verifica si hay datos de perfil cargados
  ///
  /// Retorna true si hay datos disponibles
  bool hasProfileData() {
    return GlobalVars().get('profileData') != null;
  }

  /// Obtiene información básica del usuario
  ///
  /// Retorna un Map con los datos básicos o null si no hay datos
  Map<String, String?>? getUserBasicInfo() {
    final profileData = getProfileData();
    if (profileData == null) return null;

    return {
      'nombre': profileData.persona,
      'email': profileData.email,
      'genero': profileData.genero,
      'identificacion': profileData.identificacion,
      'foto': profileData.foto,
    };
  }

  /// Verifica si el perfil activo es de estudiante
  ///
  /// Retorna true si es perfil de estudiante
  bool isActiveProfileStudent() {
    final activeProfile = getActiveProfile();
    return activeProfile?.isStudent ?? false;
  }

  /// Verifica si el perfil activo es administrativo
  ///
  /// Retorna true si es perfil administrativo
  bool isActiveProfileAdministrative() {
    final activeProfile = getActiveProfile();
    return activeProfile?.isAdministrative ?? false;
  }

  /// Obtiene el color de texto sobre color de fondo
  ///
  /// Retorna una lista [R, G, B] o null si no está definido
  List<int>? getTextColorOverBackground() {
    final activeProfile = getActiveProfile();
    final colorString = activeProfile?.colortextosobrecolor;

    if (colorString == null || colorString.isEmpty) return null;

    try {
      final parts =
          colorString.split(',').map((s) => int.parse(s.trim())).toList();
      if (parts.length == 3) return parts;
    } catch (e) {
      // Silenciar error de parseo
    }

    return null;
  }
}
