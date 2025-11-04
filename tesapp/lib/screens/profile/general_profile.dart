import 'package:flutter/material.dart';
import 'package:tesapp/controllers/profile_controller.dart';
import './components/photo_importer.dart';
import 'package:tesapp/model/global_vars.dart';
import 'package:tesapp/model/profile_data.dart';

class GeneralProfile extends StatefulWidget {
  const GeneralProfile({super.key});

  @override
  State<GeneralProfile> createState() => _GeneralProfileState();
}

class _GeneralProfileState extends State<GeneralProfile> {
  late ProfileController profileController;
  
  @override
  void initState() {
    super.initState();
    profileController = ProfileController();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener datos del perfil desde GlobalVars
    final profileDataStudent = GlobalVars().get('profileData') as ProfileDataStudent?;
    
    if (profileDataStudent == null) {
      return const Scaffold(
        body: Center(
          child: Text('No hay datos de perfil disponibles'),
        ),
      );
    }

    // Obtener perfil activo
    final activeProfile = profileController.getActiveProfile();
    final resumen = profileDataStudent.resumen;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xF5F5F5FF),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,

      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de perfil principal
              ProfileCard(profileDataStudent: profileDataStudent, activeProfile: activeProfile),
              
              const SizedBox(height: 20),
              
              // Tarjeta de resumen académico
              AcademicSummaryCard(resumen: resumen),
              
              const SizedBox(height: 20),
              
              // Tarjeta de deudas
              DebtCard(resumen: resumen),
              
              const SizedBox(height: 20),
              
              // Tarjeta de estado de matriculación
              if (activeProfile != null)
                EnrollmentStatusCard(activeProfile: activeProfile),
            ],
          ),
        ),
      ),
    );
  }
}



class ProfileCard extends StatelessWidget {
  final ProfileDataStudent profileDataStudent;
  final Perfile? activeProfile;

  const ProfileCard({
    super.key,
    required this.profileDataStudent,
    required this.activeProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17203A), Color(0xFF7553F6)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            // Foto de perfil mejorada usando PhotoImporter
            PhotoImporter().buildCircularProfileImage(
              imageUrl: profileDataStudent.foto,
              size: 100,
              borderColor: Colors.white,
              borderWidth: 2,
              backgroundColor: Colors.grey[300] ?? Colors.grey,
              iconColor: Colors.white,
              iconSize: 50,
              referer: 'https://tesa.academicok.com/',
            ),
            const SizedBox(height: 15),
            
            // Nombre
            Text(
              profileDataStudent.persona,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            
            // Carrera
            Text(
              activeProfile?.carrerarep.isNotEmpty == true
                  ? activeProfile!.carrerarep
                  : (activeProfile?.carrera ?? 'No disponible'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            
            // Datos de identificación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(context, 'ID', profileDataStudent.identificacion),
                _buildInfoItem(context, 'Email', profileDataStudent.email),
              ],
            ),
            const SizedBox(height: 15),
            
            // Nivel y sesión
            if (activeProfile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(context, 'Nivel', activeProfile!.nivel),
                  _buildInfoItem(context, 'Sesión', activeProfile!.sesion),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicSummaryCard extends StatelessWidget {
  final Resumen resumen;

  const AcademicSummaryCard({
    super.key,
    required this.resumen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF7553F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Académico',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Fila 1: Materias y Promedio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                icon: Icons.school,
                value: '${resumen.materiasaprobadas}/${resumen.materiasmalla}',
                label: 'Materias',
              ),
              _buildMetricItem(
                icon: Icons.star,
                value: resumen.promedio.toStringAsFixed(2),
                label: 'Promedio',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Fila 2: Horas de Pasantías y Prácticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                icon: Icons.work,
                value: resumen.horaspasantias.toStringAsFixed(0),
                label: 'Horas Pasantías',
              ),
              _buildMetricItem(
                icon: Icons.science,
                value: resumen.horaspracticas.toString(),
                label: 'Horas Prácticas',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Fila 3: Talleres y Viajes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                icon: Icons.group_work,
                value: resumen.talleres.toString(),
                label: 'Talleres',
              ),
              _buildMetricItem(
                icon: Icons.flight,
                value: resumen.viajes.toString(),
                label: 'Viajes',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Última Matrícula
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Última Matrícula',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    resumen.ultimamatricula,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DebtCard extends StatelessWidget {
  final Resumen resumen;

  const DebtCard({
    super.key,
    required this.resumen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF3E4685),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado Financiero',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Deuda Vigente
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deuda Vigente',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${resumen.deudavigente.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Deuda Vencida
          Row(
            children: [
              Icon(
                Icons.warning,
                color: resumen.deudavencida > 0 ? Colors.red[300] : Colors.green[300],
                size: 24,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deuda Vencida',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${resumen.deudavencida.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: resumen.deudavencida > 0 ? Colors.red[300] : Colors.green[300],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EnrollmentStatusCard extends StatelessWidget {
  final Perfile activeProfile;

  const EnrollmentStatusCard({
    super.key,
    required this.activeProfile,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnrolled = activeProfile.matriculado;
    final String statusText = isEnrolled ? 'Matriculado' : 'No Matriculado';
    final Color statusColor = isEnrolled ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF17203A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado de Matrícula',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Periodo
          Row(
            children: [
              const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Periodo Actual',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    activeProfile.periodo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // QR Code Placeholder
          if (activeProfile.qrimage.isNotEmpty)
            Center(
              child: Column(
                children: [
                  const Text(
                    'Código QR de Verificación',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Image.network(
                        activeProfile.qrimage,
                        width: 130,
                        height: 130,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.qr_code,
                            size: 100,
                            color: Colors.black54,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}