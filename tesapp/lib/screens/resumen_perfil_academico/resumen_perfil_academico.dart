import 'package:flutter/material.dart';

import 'package:tesapp/controllers/profile_controller.dart';
import 'package:tesapp/controllers/user_data_controller.dart';
import 'package:tesapp/controllers/user_panel_controller.dart';

import 'package:tesapp/model/profile_data.dart';
import 'package:tesapp/model/user_data.dart';
import 'package:tesapp/model/user_panel_data.dart';

class ResumenAcademicoScreen extends StatefulWidget {
  const ResumenAcademicoScreen({super.key});

  @override
  State<ResumenAcademicoScreen> createState() => _ResumenAcademicoScreenState();
}

class _ResumenAcademicoScreenState extends State<ResumenAcademicoScreen> {
  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);
  static const Color _background = Colors.white;

  UserData? _userData;
  UserPanelData? _userPanelData;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Cache → API
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

  @override
  Widget build(BuildContext context) {
    final profileController = ProfileController();
    final ProfileDataStudent? profileDataStudent = profileController.getProfileData();

    if (profileDataStudent == null) {
      return const Scaffold(
        body: Center(child: Text('No hay datos de perfil disponibles')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen académico'),
        backgroundColor: _background,
        foregroundColor: _primaryPurple,
        elevation: 1,
      ),
      backgroundColor: _background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AcademicSummaryCard(
          userData: _userData,
          panelData: _userPanelData,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Card con TODO el resumen académico
/// ─────────────────────────────────────────────────────────────
class AcademicSummaryCard extends StatelessWidget {
  final UserData? userData;
  final UserPanelData? panelData;

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);

  const AcademicSummaryCard({
    super.key,
    required this.userData,
    required this.panelData,
  });

  @override
  Widget build(BuildContext context) {
    final profileController = ProfileController();

    final carrera = userData?.carrera ?? profileController.getActiveCareerName();
    final modalidad = userData?.modalidad;
    final sesion = userData?.sesion;

    final progreso = panelData?.progreso;
    final periodo = panelData?.periodo;
    final clasesHoy = panelData?.clasesHoy;
    final dia = panelData?.dia;
    final prestamos = panelData?.prestamosBiblioteca;

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
    final tienePrestamos = prestamos != null && prestamos.isNotEmpty;

    return Card(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Información académica'),
            const SizedBox(height: 6),
            KeyValueRow(label: 'Carrera', value: carrera),
            KeyValueRow(label: 'Modalidad', value: modalidad),
            KeyValueRow(label: 'Sesión', value: sesion),

            if (tieneProgreso) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1, thickness: 0.3),
              const SizedBox(height: 10),
              const SectionTitle('Progreso en la malla'),
              const SizedBox(height: 6),
              KeyValueRow(
                label: 'Créditos malla',
                value: progreso?.creditosMalla?.toStringAsFixed(1),
              ),
              KeyValueRow(
                label: 'Materias malla',
                value: progreso?.materiasMalla?.toString(),
              ),
              KeyValueRow(
                label: 'Aprobadas',
                value: progreso?.materiasAprobadas?.toString(),
              ),
              KeyValueRow(
                label: 'Créditos aprobados',
                value: progreso?.creditosAprobados?.toStringAsFixed(1),
              ),
            ],

            if (tienePeriodo) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1, thickness: 0.3),
              const SizedBox(height: 10),
              const SectionTitle('Periodo actual'),
              const SizedBox(height: 6),
              KeyValueRow(label: 'Nombre', value: periodo?.nombre),
              KeyValueRow(label: 'Tipo', value: periodo?.tipo),
              KeyValueRow(
                label: 'Matriculado',
                value: periodo?.matriculado == null
                    ? null
                    : (periodo!.matriculado! ? 'Sí' : 'No'),
              ),
              KeyValueRow(label: 'Inicia', value: periodo?.inicia),
              KeyValueRow(label: 'Termina', value: periodo?.termina),
            ],

            if (tieneClasesHoy) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1, thickness: 0.3),
              const SizedBox(height: 10),
              SectionTitle('Clases de hoy (${dia ?? ""})'),
              const SizedBox(height: 6),
              KeyValueRow(label: 'Número de clases', value: clasesHoy!.length.toString()),
            ],

            if (tienePrestamos) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1, thickness: 0.3),
              const SizedBox(height: 10),
              const SectionTitle('Préstamos de biblioteca'),
              const SizedBox(height: 6),
              KeyValueRow(label: 'Préstamos activos', value: prestamos!.length.toString()),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  final String label;
  final String? value;

  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 6,
            child: Text(
              value!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
