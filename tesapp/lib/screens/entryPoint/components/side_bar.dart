import 'package:flutter/material.dart';
import '../../../model/menu.dart';
import '../../../utils/rive_utils.dart';
import '../../../controllers/profile_controller.dart';
import '../../../model/profile_data.dart'; // Importar para acceder a los tipos
import 'info_card.dart';
import 'side_menu.dart';
import '../../../model/global_vars.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;
  late ProfileController profileController;
  
  @override
  void initState() {
    super.initState();
    profileController = ProfileController();
  }
  
  // Función local para formatear nombre
  String formatFullName(String fullName) {
    if (fullName.isEmpty) return "Usuario";
    
    final titleCaseName = fullName.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() +
          (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
    
    final nameParts = titleCaseName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0]} ${nameParts[1]}';
    }
    
    return titleCaseName;
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtén el objeto completo de tipo ProfileDataStudent desde GlobalVars
    final profileDataStudent =
        GlobalVars().get('profileData') as ProfileDataStudent?;
    
    // Usa la propiedad 'persona' de ProfileDataStudent
    final formattedName = profileDataStudent != null 
        ? formatFullName(profileDataStudent.persona) 
        : "Usuario";
    
    // Para el campo carrera, se verifica primero en el objeto activo (Perfile)
    // obteniendo el perfil activo y, a partir de él, el campo carrera o carrerarep
    final activeProfile = profileController.getActiveProfile();
    String carreraText = "Estudiante";
    if (activeProfile != null) {
      if (activeProfile.carrerarep.isNotEmpty) {
        carreraText = activeProfile.carrerarep;
      } else if (activeProfile.carrera.isNotEmpty) {
        carreraText = activeProfile.carrera;
      }
    }
    
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usar los datos formateados en InfoCard
              InfoCard(
                name: formattedName,
                bio: carreraText,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "BROWSE",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              // ... Resto del código o widgets adicionales
            ],
          ),
        ),
      ),
    );
  }
}
