import 'package:flutter/material.dart';
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
  String selectedMenuItem = 'Inicio';
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = ProfileController();
  }

  String formatFullName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Usuario';

    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0];

    final lower = parts.map((p) => p.toLowerCase()).toList();

    // 1) Detectar longitud del PRIMER apellido (puede ser compuesto)
    int firstSurnameLen;

    // Casos tipo: "DE LA CRUZ PEREZ JUAN SEBASTIAN"
    if (lower.length >= 3 &&
        lower[0] == 'de' &&
        (lower[1] == 'la' || lower[1] == 'los' || lower[1] == 'las')) {
      firstSurnameLen = 3; // "De la Cruz"
    }
    // Casos tipo: "DEL VALLE PEREZ JUAN", "SAN MARTIN PEREZ JUAN"
    else if (lower.length >= 2 &&
        (lower[0] == 'del' || lower[0] == 'san' || lower[0] == 'santa')) {
      firstSurnameLen = 2; // "Del Valle", "San Martín"
    } else {
      // Caso simple: "MORENO OCAMPO JUAN SEBASTIAN"
      firstSurnameLen = 1; // "MORENO"
    }

    // 2) Decidir desde dónde empiezan los nombres
    int givenStart;

    if (parts.length <= 2) {
      // Ej: "PEREZ JUAN"
      givenStart = 1;
    } else if (parts.length == 3) {
      // Ej: "DE LA CRUZ JUAN" o "PEREZ JUAN SEBASTIAN"
      if (firstSurnameLen > 1) {
        // "DE LA CRUZ JUAN"
        givenStart = firstSurnameLen;
      } else {
        // asumimos: "PEREZ JUAN SEBASTIAN" → nombres: JUAN SEBASTIAN
        givenStart = 1;
      }
    } else {
      // >= 4 tokens → típico: APELLIDO1 APELLIDO2 NOMBRE1 NOMBRE2
      // Ej: "MORENO OCAMPO JUAN SEBASTIAN"
      //     "DE LA CRUZ PEREZ JUAN SEBASTIAN"
      givenStart = firstSurnameLen + 1; // saltamos 2 apellidos
    }

    if (givenStart >= parts.length) {
      givenStart = parts.length - 1;
    }

    final lastNameTokens = parts.sublist(0, firstSurnameLen); // solo primer apellido (compuesto)
    final firstName = parts[givenStart];

    return '$firstName ${lastNameTokens.join(' ')}';
  }

  String toNiceCase(String input) {
    if (input.isEmpty) return input;

    final particles = {
      'de',
      'del',
      'la',
      'los',
      'las',
      'y',
    };

    final words = input.toLowerCase().split(' ');

    for (int i = 0; i < words.length; i++) {
      final w = words[i];

      if (particles.contains(w)) {
        // partículas en minúsculas
        words[i] = w;
      } else {
        // capitalizar
        words[i] = w[0].toUpperCase() + w.substring(1);
      }
    }

    return words.join(' ');
  }


  String getCarreraDisplay() {
    final activeProfile = profileController.getActiveProfile();
    if (activeProfile == null) return 'Estudiante';

    // Si es perfil administrativo
    if (activeProfile.isAdministrative == true) {
      if (activeProfile.coordinacion?.isNotEmpty == true) {
        return activeProfile.coordinacion!;
      }
      if (activeProfile.sede?.isNotEmpty == true) {
        return activeProfile.sede!;
      }
      return 'Administrativo';
    }

    // Si es perfil de estudiante
    if (activeProfile.carrerarep?.isNotEmpty == true) {
      return activeProfile.carrerarep!;
    }
    if (activeProfile.carrera?.isNotEmpty == true) {
      return activeProfile.carrera!;
    }

    return 'Estudiante';
  }

  void _selectMenuItem(String itemName, VoidCallback callback) {
    setState(() {
      selectedMenuItem = itemName;
    });
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final profileDataStudent = profileController.getProfileData();
    final activeProfile = profileController.getActiveProfile();

    final rawName = profileDataStudent?.persona;
    final formattedName = toNiceCase(formatFullName(rawName));
    final carreraText = getCarreraDisplay();



    // 🔍 Debug: ver qué viene del backend y qué estamos mostrando
    print("NOMBRE CRUDO: '$rawName'");
    print("NOMBRE FORMATEADO: '$formattedName'");

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
                      backgroundImage: (profileDataStudent?.foto?.isNotEmpty ?? false)
                          ? NetworkImage(profileDataStudent!.foto!)
                          : null,
                      child: (profileDataStudent?.foto?.isEmpty ?? true)
                          ? const Icon(Icons.person, color: Colors.white, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👇 Nombre adaptativo
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formattedName,
                                style: const TextStyle(
                                  fontSize: 18, // tamaño base, baja si no cabe
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 👇 Carrera, también en una línea
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                carreraText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
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
                isSelected: selectedMenuItem == 'Inicio',
                onTap: () => _selectMenuItem('Inicio', widget.onHomeTap),
              ),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Perfil',
                isSelected: selectedMenuItem == 'Perfil',
                onTap: () => _selectMenuItem('Perfil', widget.onProfileTap),
              ),

              // Solo mostrar Horario si es estudiante
              if (profileController.isActiveProfileStudent() == true)
                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Horario',
                  isSelected: selectedMenuItem == 'Horario',
                  onTap: () => _selectMenuItem('Horario', () {
                    // TODO: Implementar navegación a Horario
                  }),
                ),

              // Solo mostrar Calificaciones si es estudiante
              if (profileController.isActiveProfileStudent() == true)
                _buildMenuItem(
                  icon: Icons.school_outlined,
                  title: 'Calificaciones',
                  isSelected: selectedMenuItem == 'Calificaciones',
                  onTap: () => _selectMenuItem('Calificaciones', () {
                    // TODO: Implementar navegación a Calificaciones
                  }),
                ),

              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Finanzas',
                isSelected: selectedMenuItem == 'Finanzas',
                onTap: () => _selectMenuItem('Finanzas', widget.onFinanceTap),
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
                  // TODO: Implementar navegación a Ajustes
                }),
              ),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Ayuda',
                isSelected: selectedMenuItem == 'Ayuda',
                onTap: () => _selectMenuItem('Ayuda', () {
                  // TODO: Implementar navegación a Ayuda
                }),
              ),

              _buildMenuItem(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                isSelected: selectedMenuItem == 'Cerrar Sesión',
                onTap: () =>
                    _selectMenuItem('Cerrar Sesión', widget.onLogoutTap),
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
