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
          };
        } else {
          return {
            'success': false,
            'message': 'Error al obtener datos del perfil',
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
    if (profileData.perfiles.isEmpty) {
      return;
    }

    // Buscar el perfil que coincide con el perfilactivoid
    Perfile? activeProfile;
    
    for (var profile in profileData.perfiles) {
      if (profile.idpu == profileData.perfilactivoid) {
        activeProfile = profile;
        break;
      }
    }

    // Si no se encontró un perfil coincidente, usar el que tenga principal = 1
    if (activeProfile == null) {
      for (var profile in profileData.perfiles) {
        if (profile.principal == 1) {
          activeProfile = profile;
          break;
        }
      }
    }

    // Si aún no se ha encontrado un perfil, usar el primero de la lista
    if (activeProfile == null && profileData.perfiles.isNotEmpty) {
      activeProfile = profileData.perfiles.first;
    }

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
      final profileData = GlobalVars().get('profileData') as ProfileDataStudent?;
      
      if (profileData == null) {
        return {
          'success': false,
          'message': 'No hay datos de perfil disponibles',
        };
      }

      // Verificar si el idpu existe en la lista de perfiles
      bool profileExists = false;
      for (var profile in profileData.perfiles) {
        if (profile.idpu == idpu) {
          profileExists = true;
          break;
        }
      }

      if (!profileExists) {
        return {
          'success': false,
          'message': 'El perfil seleccionado no existe',
        };
      }

      // Actualizar el perfil activo en el servidor
      final authToken = profileData.auth;
      final response = await http.post(
        Uri.parse('https://tesa.academicok.com/apimobile/change_profile'),
        body: {
          'auth': authToken,
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
          };
        } else {
          return {
            'success': false,
            'message': 'Error al cambiar el perfil',
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
    
    if (profileData == null || activeProfile == null) {
      return false;
    }
    
    return profileData.resumen.idpu == activeProfile.idpu;
  }

  /// Actualiza los datos del perfil desde el servidor
  /// 
  /// Retorna un Map con:
  /// - 'success': true si la operación fue exitosa, false en caso contrario
  /// - 'message': mensaje de éxito o error
  Future<Map<String, dynamic>> refreshProfileData() async {
    final profileData = GlobalVars().get('profileData') as ProfileDataStudent?;
    
    if (profileData == null) {
      return {
        'success': false,
        'message': 'No hay datos de perfil disponibles',
      };
    }
    
    return await fetchProfileData(profileData.auth);
  }

  getProfileData() {}
}