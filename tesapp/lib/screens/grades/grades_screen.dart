import 'package:flutter/material.dart';
import '../../controllers/grades_controller.dart';
import '../../model/grades_data.dart';
import '../schedule/components/loading_indicator.dart';
import '../schedule/components/error_message.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with SingleTickerProviderStateMixin {
  final GradesController _gradesController = GradesController();
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  GradesData? _gradesData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGradesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGradesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _gradesController.refreshGradesData();

    if (result['success']) {
      setState(() {
        _gradesData = _gradesController.getGradesData();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Materias y Calificaciones'),
        ),
        body: const LoadingIndicator(message: 'Cargando calificaciones...'),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Materias y Calificaciones'),
        ),
        body: ErrorMessage(
          message: _errorMessage,
          onRetry: _loadGradesData,
        ),
      );
    }

    if (_gradesData == null || _gradesData!.materias.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Materias y Calificaciones'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadGradesData,
              tooltip: 'Actualizar calificaciones',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay materias disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No se encontraron materias o calificaciones para mostrar',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadGradesData,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      );
    }

    // Calcular el promedio general para mostrarlo
    final promedio = _gradesData!.promedioGeneral;
    final materiasEnCurso = _gradesData!.materiasEnCurso;
    final materiasAprobadas = _gradesData!.materiasAprobadas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias y Calificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGradesData,
            tooltip: 'Actualizar calificaciones',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En Curso'),
            Tab(text: 'Aprobadas'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Panel de resumen
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.school,
                  title: 'Promedio General',
                  value: promedio.toStringAsFixed(2),
                ),
                _buildSummaryItem(
                  icon: Icons.book,
                  title: 'Materias En Curso',
                  value: materiasEnCurso.length.toString(),
                ),
                _buildSummaryItem(
                  icon: Icons.check_circle,
                  title: 'Materias Aprobadas',
                  value: materiasAprobadas.length.toString(),
                ),
              ],
            ),
          ),

          // TabBarView con las listas de materias
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab de materias en curso
                _buildSubjectsList(materiasEnCurso),

                // Tab de materias aprobadas
                _buildSubjectsList(materiasAprobadas),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsList(List<SubjectGrade> subjects) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay materias ${_tabController.index == 0 ? 'en curso' : 'aprobadas'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGradesData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];

          // Determinar color basado en el estado
          Color statusColor;
          try {
            final colorHex = subject.colorEstado.replaceFirst('#', '');
            statusColor = Color(int.parse('FF$colorHex', radix: 16));
          } catch (e) {
            statusColor = subject.isAprobada ? Colors.green : Colors.blue;
          }

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: statusColor.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subject.nombreCorto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          subject.estado,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Información del profesor
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subject.profesores.isNotEmpty
                              ? subject.profesores.first
                              : 'Sin profesor',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Información de asistencia
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Asistencia: ${subject.asistencia.toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notas parciales
                  if (subject.parciales.isNotEmpty) ...[
                    const Text(
                      'Calificaciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Lista de notas parciales
                    ...subject.parciales
                        .map((parcial) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(parcial.name),
                                  Text(
                                    parcial.grade.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),

                    const Divider(),

                    // Nota final
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nota Final',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          subject.notaFinal.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: subject.isAprobada ? Colors.green : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
