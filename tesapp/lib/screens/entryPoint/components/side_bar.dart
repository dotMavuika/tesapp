import 'package:flutter/material.dart';
import '../../../model/menu.dart';
import '../../../controllers/profile_controller.dart';

class SideBar extends StatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onHomeTap;
  final VoidCallback onFinanceTap;
  final VoidCallback onLogoutTap;

  const SideBar({
    super.key,
    required this.onProfileTap,
    required this.onHomeTap,
    required this.onFinanceTap,
    required this.onLogoutTap,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String selectedMenuItem = 'Inicio'; // Cambiado a String para más control
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = ProfileController();
  }

  String formatFullName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return fullName;
  }

  // Método helper para manejar la selección
  void _selectMenuItem(String itemName, VoidCallback callback) {
    setState(() {
      selectedMenuItem = itemName;
    });
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final profileDataStudent = profileController.getProfileData();

    final formattedName = profileDataStudent != null
        ? formatFullName(profileDataStudent.persona)
        : 'Usuario';

    final activeProfile = profileController.getActiveProfile();
    final carreraText = activeProfile?.carrerarep.isNotEmpty == true
        ? activeProfile!.carrerarep
        : (activeProfile?.carrera ?? 'Estudiante');

    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF7C3E8E),
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

              // Elementos del menú con selección actualizada
              _buildMenuItem(
                icon: Icons.home_outlined,
                title: 'Inicio',
                isSelected: selectedMenuItem == 'Inicio',
                onTap: () => _selectMenuItem('Inicio', widget.onHomeTap),
              ),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Perfil',
                isSelected: selectedMenuItem == 'Perfil',
                onTap: () => _selectMenuItem('Perfil', widget.onProfileTap),
              ),

              _buildMenuItem(
                icon: Icons.calendar_today_outlined,
                title: 'Horario',
                isSelected: selectedMenuItem == 'Horario',
                onTap: () => _selectMenuItem('Horario', () {
                  // Lógica de horario
                }),
              ),

              _buildMenuItem(
                icon: Icons.school_outlined,
                title: 'Calificaciones',
                isSelected: selectedMenuItem == 'Calificaciones',
                onTap: () => _selectMenuItem('Calificaciones', () {
                  // Lógica de calificaciones
                }),
              ),

              // ✅ CORREGIDO - Ahora usa el callback del EntryPoint
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Finanzas', // ✅ Corregido el nombre (sin "SS")
                isSelected: selectedMenuItem == 'Finanzas',
                onTap: () => _selectMenuItem('Finanzas', widget.onFinanceTap), // ✅ Usa el callback
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
                isSelected: selectedMenuItem == 'Ajustes',
                onTap: () => _selectMenuItem('Ajustes', () {
                  // Lógica de ajustes
                }),
              ),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Ayuda',
                isSelected: selectedMenuItem == 'Ayuda',
                onTap: () => _selectMenuItem('Ayuda', () {
                  // Lógica de ayuda
                }),
              ),

              _buildMenuItem(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                isSelected: selectedMenuItem == 'Cerrar Sesión',
                onTap: () => _selectMenuItem('Cerrar Sesión', widget.onLogoutTap),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

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
          color: isSelected ? const Color(0xFFE6B420) : Colors.transparent,
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