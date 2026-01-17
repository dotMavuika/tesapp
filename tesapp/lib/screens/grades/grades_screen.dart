import 'package:flutter/material.dart';
import '../../controllers/grades_controller.dart';
import '../../model/grades_data.dart';
import '../schedule/components/loading_indicator.dart';
import '../schedule/components/error_message.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

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

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);
  static const Color _background = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeGradesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Primero intenta caché, si no hay, consulta API real
  void _initializeGradesData() {
    final cachedData = _gradesController.getGradesData();

    if (cachedData != null && cachedData.materias.isNotEmpty) {
      setState(() {
        _gradesData = cachedData;
        _isLoading = false;
      });
    } else {
      _loadGradesData();
    }
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
        appBar: _buildAppBar(false),
        body: const LoadingIndicator(message: 'Cargando calificaciones...'),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: _buildAppBar(false),
        body: ErrorMessage(
          message: _errorMessage,
          onRetry: _loadGradesData,
        ),
      );
    }

    if (_gradesData == null || _gradesData!.materias.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(false),
        body: const Center(
          child: Text('No hay materias disponibles'),
        ),
      );
    }

    final promedio = _gradesData!.promedioGeneral;
    final materiasEnCurso = _gradesData!.materiasEnCurso;
    final materiasAprobadas = _gradesData!.materiasAprobadas;

    return Scaffold(
      appBar: _buildAppBar(true),
      backgroundColor: _background,
      body: Column(
        children: [
          _buildSummaryPanel(
            promedio,
            materiasEnCurso.length,
            materiasAprobadas.length,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubjectsList(materiasEnCurso),
                _buildSubjectsList(materiasAprobadas),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool withTabs) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        'Materias y Calificaciones',
        style: TextStyle(
          color: _primaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      foregroundColor: _primaryPurple,
      bottom: withTabs
          ? TabBar(
        controller: _tabController,
        labelColor: _primaryYellow,
        unselectedLabelColor: _primaryPurple,
        indicatorColor: _primaryYellow,
        indicatorWeight: 4,
        tabs: const [
          Tab(text: 'En Curso'),
          Tab(text: 'Aprobadas'),
        ],
      )
          : null,
    );
  }

  Widget _buildSummaryPanel(double promedio, int enCurso, int aprobadas) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_primaryPurple, _secondaryPurple],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Icons.school,
            "Promedio",
            promedio.toStringAsFixed(2),
          ),
          _buildSummaryItem(Icons.book, "En Curso", enCurso.toString()),
          _buildSummaryItem(Icons.check_circle, "Aprobadas", aprobadas.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 28, color: _primaryYellow),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsList(List<SubjectGrade> subjects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryPurple, _secondaryPurple],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.nombreCorto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...subject.parciales.map(
                      (p) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        p.grade.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Nota Final",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subject.notaFinal.toStringAsFixed(1),
                      style: const TextStyle(
                        color: _primaryYellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
