import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:tesapp/model/profile_data.dart';
import 'package:tesapp/model/user_data.dart';
import 'package:tesapp/model/user_panel_data.dart';
import 'package:tesapp/controllers/user_data_controller.dart';
import 'package:tesapp/controllers/user_panel_controller.dart';
import 'package:tesapp/controllers/profile_controller.dart';

import 'components/photo_importer.dart';

class GeneralProfile extends StatefulWidget {
  const GeneralProfile({super.key});

  @override
  State<GeneralProfile> createState() => _GeneralProfileState();
}

class _GeneralProfileState extends State<GeneralProfile> {
  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _background = Colors.white;

  @override
  Widget build(BuildContext context) {
    final profileController = ProfileController();
    final ProfileDataStudent? profileDataStudent =
    profileController.getProfileData();

    if (profileDataStudent == null) {
      return const Scaffold(
        body: Center(
          child: Text('No hay datos de perfil disponibles'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        toolbarHeight: 64,
        backgroundColor: Colors.white,
        foregroundColor: _primaryPurple,
        automaticallyImplyLeading: false,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: _primaryPurple,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      backgroundColor: _background,
      body: Container(
        color: _background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              UserOverviewCard(profileDataStudent: profileDataStudent),
            ],
          ),
        ),
      ),
    );
  }
}

class UserOverviewCard extends StatefulWidget {
  final ProfileDataStudent profileDataStudent;

  const UserOverviewCard({
    super.key,
    required this.profileDataStudent,
  });

  @override
  State<UserOverviewCard> createState() => _UserOverviewCardState();
}

class _UserOverviewCardState extends State<UserOverviewCard> {
  UserData? _userData;
  UserPanelData? _userPanelData;
  bool _loading = true;
  String? _error;

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userDataController = UserDataController();
      final userPanelController = UserPanelController();

      final cachedUserData = userDataController.getUserData();
      final cachedPanelData = userPanelController.getUserPanelData();

      if (cachedUserData != null || cachedPanelData != null) {
        setState(() {
          _userData = cachedUserData;
          _userPanelData = cachedPanelData;
          _loading = false;
        });
        return;
      }

      await Future.wait([
        userDataController.refreshUserData(),
        userPanelController.refreshUserPanelData(),
      ]);

      setState(() {
        _userData = userDataController.getUserData();
        _userPanelData = userPanelController.getUserPanelData();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error al cargar datos: $e';
      });
    }
  }

  String _buildAbsoluteUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://tesa.academicok.com${path.startsWith('/') ? '' : '/'}$path';
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profileDataStudent;
    final profileController = ProfileController();

    final email = profile.email ?? '-';
    final identificacion = profile.identificacion ?? '-';
    final nombre = _userData?.nombre ?? profile.persona ?? 'Sin nombre';
    final carrera = _userData?.carrera ?? profileController.getActiveCareerName();
    final modalidad = _userData?.modalidad;
    final sesion = _userData?.sesion;

    final generoRaw = _userData?.genero;
    String? genero;
    if (generoRaw != null) {
      if (generoRaw == 1) {
        genero = "Femenino";
      } else if (generoRaw == 2) {
        genero = "Masculino";
      }
    }

    final fotoUrl = _buildAbsoluteUrl(_userData?.foto ?? profile.foto);

    final panel = _userPanelData;
    final progreso = panel?.progreso;
    final periodo = panel?.periodo;
    final clasesHoy = panel?.clasesHoy;
    final dia = panel?.dia;
    final prestamosBiblioteca = panel?.prestamosBiblioteca;

    final tieneProgreso = progreso != null &&
        ((progreso.creditosMalla ?? 0) > 0 ||
            (progreso.materiasMalla ?? 0) > 0 ||
            (progreso.materiasAprobadas ?? 0) > 0 ||
            (progreso.creditosAprobados ?? 0) > 0);

    final tienePeriodo = periodo != null &&
        ((periodo.nombre?.isNotEmpty ?? false) ||
            (periodo.tipo?.isNotEmpty ?? false) ||
            periodo.matriculado != null);

    final tieneClasesHoy = clasesHoy != null && clasesHoy.isNotEmpty;
    final tienePrestamos = prestamosBiblioteca != null && prestamosBiblioteca.isNotEmpty;

    if (_loading) return _buildLoadingCard();
    if (_error != null) return _buildErrorCard();

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryPurple, _secondaryPurple],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryYellow, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                if (fotoUrl.isNotEmpty)
                  FutureBuilder<Uint8List?>(
                    future: PhotoImporter().fetchImageWithHeaders(
                      fotoUrl,
                      referer: 'https://tesa.academicok.com/',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _avatarPlaceholder(child: const CircularProgressIndicator(strokeWidth: 2, color: _primaryYellow));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(snapshot.data!, width: 120, height: 120, fit: BoxFit.cover),
                        );
                      } else {
                        return _avatarPlaceholder(child: const Icon(Icons.person, size: 60, color: _primaryYellow));
                      }
                    },
                  )
                else
                  _avatarPlaceholder(child: const Icon(Icons.person, size: 60, color: _primaryYellow)),
                const SizedBox(height: 14),
                Text(nombre, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _iconText(Icons.email, email, centered: true),
                const SizedBox(height: 4),
                _iconText(Icons.badge, identificacion, centered: true),
                if (genero != null) ...[
                  const SizedBox(height: 4),
                  _iconText(Icons.person, genero!, centered: true),
                ],
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1, thickness: 0.3),
            const SizedBox(height: 10),
            if ((carrera != null && carrera.isNotEmpty) || (modalidad != null && modalidad.isNotEmpty) || (sesion != null && sesion.isNotEmpty)) ...[
              _sectionTitle('Información académica'),
              const SizedBox(height: 6),
              _buildKeyValueRow('Carrera', carrera),
              _buildKeyValueRow('Modalidad', modalidad),
              _buildKeyValueRow('Sesión', sesion),
              const SizedBox(height: 10),
            ],
            if (tieneProgreso && progreso != null) ...[
              _sectionTitle('Progreso en la malla'),
              const SizedBox(height: 6),
              _buildKeyValueRow('Créditos malla', progreso.creditosMalla?.toStringAsFixed(1)),
              _buildKeyValueRow('Materias malla', progreso.materiasMalla?.toString()),
              _buildKeyValueRow('Aprobadas', progreso.materiasAprobadas?.toString()),
              _buildKeyValueRow('Créditos aprobados', progreso.creditosAprobados?.toStringAsFixed(1)),
              const SizedBox(height: 10),
            ],
            if (tienePeriodo && periodo != null) ...[
              _sectionTitle('Periodo actual'),
              const SizedBox(height: 6),
              _buildKeyValueRow('Nombre', periodo.nombre),
              _buildKeyValueRow('Tipo', periodo.tipo),
              _buildKeyValueRow('Matriculado', periodo.matriculado == null ? null : (periodo.matriculado! ? 'Sí' : 'No')),
              _buildKeyValueRow('Inicia', periodo.inicia),
              _buildKeyValueRow('Termina', periodo.termina),
              const SizedBox(height: 10),
            ],
            if (tieneClasesHoy) ...[
              _sectionTitle('Clases de hoy (${dia ?? ""})'),
              const SizedBox(height: 6),
              _buildKeyValueRow('Número de clases', clasesHoy!.length.toString()),
              const SizedBox(height: 10),
            ],
            if (tienePrestamos) ...[
              _sectionTitle('Préstamos de biblioteca'),
              const SizedBox(height: 6),
              _buildKeyValueRow('Préstamos activos', prestamosBiblioteca!.length.toString()),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder({required Widget child}) {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
      child: Center(child: child),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_primaryPurple, _secondaryPurple]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _primaryYellow, width: 1.5),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_primaryPurple, _secondaryPurple]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _primaryYellow, width: 1.5),
        ),
        child: Text(_error ?? 'Error desconocido', style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

  Widget _iconText(IconData icon, String text, {bool centered = false}) {
    return Row(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _primaryYellow),
        const SizedBox(width: 4),
        Flexible(child: Text(text, textAlign: centered ? TextAlign.center : TextAlign.left, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)));
  }

  Widget _buildKeyValueRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600))),
          const SizedBox(width: 6),
          Expanded(flex: 6, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }
}