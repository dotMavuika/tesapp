import 'package:flutter/material.dart';
import '../../../controllers/profile_controller.dart';
// 👇 importa el PhotoImporter (ajusta la ruta si tu estructura es distinta)
import '../../../screens/profile/components/photo_importer.dart';

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

  // 🔧 En vez de late, lo inicializamos aquí directamente
  final ProfileController profileController = ProfileController();

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
        // "PEREZ JUAN SEBASTIAN"
        givenStart = 1;
      }
    } else {
      // >= 4 tokens → típico: APELLIDO1 APELLIDO2 NOMBRE1 NOMBRE2
      givenStart = firstSurnameLen + 1; // saltamos 2 apellidos
    }

    if (givenStart >= parts.length) {
      givenStart = parts.length - 1;
    }

    final lastNameTokens =
    parts.sublist(0, firstSurnameLen); // solo primer apellido (compuesto)
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
        words[i] = w; // partículas en minúsculas
      } else {
        words[i] = w[0].toUpperCase() + w.substring(1); // capitalizar
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

  // 👇 Igual que en GeneralProfile, para manejar rutas relativas de la foto
  String _buildAbsoluteUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://tesa.academicok.com${path.startsWith('/') ? '' : '/'}$path';
  }

  @override
  Widget build(BuildContext context) {
    final profileDataStudent = profileController.getProfileData();

    final rawName = profileDataStudent?.persona;
    final formattedName = toNiceCase(formatFullName(rawName));
    final carreraText = getCarreraDisplay();
    final fotoUrl = _buildAbsoluteUrl(profileDataStudent?.foto);


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
                    // 👇 Aquí usamos PhotoImporter en vez de CircleAvatar+NetworkImage
                    PhotoImporter().buildCircularProfileImage(
                      imageUrl: fotoUrl,
                      referer: 'https://tesa.academicok.com/',
                      size: 60, // equivalente a radius 30
                      borderColor: Colors.white,
                      borderWidth: 2,
                      backgroundColor: Colors.white24,
                      iconColor: Colors.white,
                      iconSize: 30,
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
                                  fontSize: 18,
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
