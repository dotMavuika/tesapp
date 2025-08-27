import 'package:flutter/material.dart';
import '../../../model/menu.dart';
import '../../../controllers/profile_controller.dart';

class SideBar extends StatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onHomeTap;
  final VoidCallback onLogoutTap; // Nuevo callback para logout
  // Puedes añadir más callbacks según necesites

  const SideBar({
    super.key,
    required this.onProfileTap,
    required this.onHomeTap,
    required this.onLogoutTap, // Agregar el nuevo parámetro requerido
  });

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

  // Método para formatear el nombre completo si necesitas mostrar info del perfil
  String formatFullName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return fullName;
  }

  @override
  Widget build(BuildContext context) {
    // Intentar obtener datos del perfil si están disponibles
    final profileDataStudent = profileController.getProfileData();

    // Formatear el nombre y carrera si hay datos disponibles
    final formattedName = profileDataStudent != null
        ? formatFullName(profileDataStudent.persona)
        : 'Usuario';

    // Obtener carrera si hay un perfil activo
    final activeProfile = profileController.getActiveProfile();
    final carreraText = activeProfile?.carrerarep.isNotEmpty == true
        ? activeProfile!.carrerarep
        : (activeProfile?.carrera ?? 'Estudiante');

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
              // Información de perfil en el encabezado
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar o foto de perfil
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 30,
                      backgroundImage: profileDataStudent?.foto != null
                          ? NetworkImage(profileDataStudent!.foto)
                          : null,
                      child: profileDataStudent?.foto == null
                          ? const Icon(Icons.person, color: Colors.white, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Información textual
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            carreraText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Colors.white24),
              ),

              // Sección de navegación
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "NAVEGACIÓN",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),

              // Elementos del menú
              _buildMenuItem(
                icon: Icons.home_outlined,
                title: 'Inicio',
                isSelected: selectedSideMenu.title == "Home",
                onTap: widget.onHomeTap,
              ),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Perfil',
                isSelected: selectedSideMenu.title == "Profile",
                onTap: widget.onProfileTap,
              ),

              _buildMenuItem(
                icon: Icons.calendar_today_outlined,
                title: 'Horario',
                isSelected: selectedSideMenu.title == "Calendar",
                onTap: () {
                  // Puedes agregar más callbacks aquí según necesites
                },
              ),

              _buildMenuItem(
                icon: Icons.school_outlined,
                title: 'Calificaciones',
                isSelected: selectedSideMenu.title == "Grades",
                onTap: () {
                  // Callback para calificaciones
                },
              ),

              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Pagos',
                isSelected: selectedSideMenu.title == "Payments",
                onTap: () {
                  // Callback para pagos
                },
              ),

              const Spacer(),

              // Sección inferior
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "CONFIGURACIÓN",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Ajustes',
                isSelected: selectedSideMenu.title == "Settings",
                onTap: () {
                  // Callback para ajustes
                },
              ),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Ayuda',
                isSelected: selectedSideMenu.title == "Help",
                onTap: () {
                  // Callback para ayuda
                },
              ),

              // Botón de logout
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                isSelected: selectedSideMenu.title == "Logout",
                onTap: widget.onLogoutTap,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Widget personalizado para los ítems del menú
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6792FF) : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}