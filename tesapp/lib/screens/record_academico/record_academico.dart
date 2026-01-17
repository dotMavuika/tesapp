// lib/screens/record_academico/record_academico.dart
import 'package:flutter/material.dart';

import 'package:tesapp/controllers/record_academico_controller.dart';
import 'package:tesapp/model/record_academico_data.dart';

import '../schedule/components/loading_indicator.dart';
import '../schedule/components/error_message.dart';

class RecordAcademicoScreen extends StatefulWidget {
  const RecordAcademicoScreen({super.key});

  @override
  State<RecordAcademicoScreen> createState() => _RecordAcademicoScreenState();
}

enum RecordOrder { nivel, fecha }

class _RecordAcademicoScreenState extends State<RecordAcademicoScreen> {
  final RecordAcademicoController _controller = RecordAcademicoController();

  RecordAcademicoData? _data;
  bool _isLoading = true;
  String _errorMessage = '';

  RecordOrder _currentOrder = RecordOrder.nivel;

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);
  static const Color _background = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final cached = _controller.getRecordAcademicoData();
    if (cached != null) {
      setState(() {
        _data = cached;
        _isLoading = false;
      });

    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _controller.refreshRecordAcademicoData();
    if (result['success'] == true) {
      setState(() {
        _data = _controller.getRecordAcademicoData();
        _isLoading = false;
      });

    } else {
      setState(() {
        _errorMessage =
            result['message'] ?? 'Error al obtener el registro académico';
        _isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: _background,
        body: const LoadingIndicator(
          message: 'Cargando registro académico...',
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: _background,
        body: ErrorMessage(
          message: _errorMessage,
          onRetry: _loadData,
        ),
      );
    }

    if (_data == null || _data!.records.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: _background,
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: _background,
      body: RefreshIndicator(
        color: _primaryPurple,
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOrderChips(),
            const SizedBox(height: 12),
            _buildGroupedRecords(),
            const SizedBox(height: 20),
            _buildPracticasVinculacionSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        'Récord Académico',
        style: TextStyle(
          color: _primaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      foregroundColor: _primaryPurple,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_edu_outlined,
              size: 80, color: _primaryPurple),
          const SizedBox(height: 16),
          const Text(
            'No hay registro académico disponible',
            style: TextStyle(
              color: _primaryPurple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryYellow,
              foregroundColor: _primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Ordenar por nivel'),
            selected: _currentOrder == RecordOrder.nivel,
            selectedColor: _primaryPurple,
            labelStyle: TextStyle(
              color: _currentOrder == RecordOrder.nivel
                  ? Colors.white
                  : _primaryPurple,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() {
                _currentOrder = RecordOrder.nivel;
              });
            },
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('Ordenar por fecha'),
            selected: _currentOrder == RecordOrder.fecha,
            selectedColor: _primaryYellow,
            labelStyle: TextStyle(
              color: _currentOrder == RecordOrder.fecha
                  ? Colors.white
                  : _primaryPurple,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() {
                _currentOrder = RecordOrder.fecha;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedRecords() {
    final records = _data?.records ?? [];
    if (records.isEmpty) return const SizedBox.shrink();

    if (_currentOrder == RecordOrder.nivel) {
      final grouped = _groupByNivel(records);
      return Column(
        children: grouped.entries
            .map((entry) => _buildNivelGroupCard(entry.key, entry.value))
            .toList(),
      );
    } else {
      final grouped = _groupByFecha(records);
      return Column(
        children: grouped.entries
            .map((entry) => _buildFechaGroupCard(entry.key, entry.value))
            .toList(),
      );
    }
  }

  Map<int, List<SubjectRecord>> _groupByNivel(
      List<SubjectRecord> records) {
    final Map<int, List<SubjectRecord>> map = {};
    for (final r in records) {
      final nivel = r.nivel ?? 0;
      map.putIfAbsent(nivel, () => []).add(r);
    }

    final sortedKeys = map.keys.toList()..sort();
    final sortedMap = <int, List<SubjectRecord>>{};
    for (final k in sortedKeys) {
      sortedMap[k] = map[k]!;
    }
    return sortedMap;
  }

  Map<String, List<SubjectRecord>> _groupByFecha(
      List<SubjectRecord> records) {
    final Map<String, List<SubjectRecord>> map = {};
    for (final r in records) {
      final fecha = (r.fecha ?? 'Sin fecha').trim();
      map.putIfAbsent(fecha, () => []).add(r);
    }

    final keys = map.keys.toList()
      ..sort((a, b) => _parseDate(a).compareTo(_parseDate(b)));

    final sortedMap = <String, List<SubjectRecord>>{};
    for (final k in keys) {
      sortedMap[k] = map[k]!;
    }
    return sortedMap;
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]) ?? 1;
      final m = int.tryParse(parts[1]) ?? 1;
      final y = int.tryParse(parts[2]) ?? 1900;
      return DateTime(y, m, d);
    }
    return DateTime(1900);
  }

  Widget _buildNivelGroupCard(int nivel, List<SubjectRecord> records) {
    records.sort((a, b) =>
        _parseDate(a.fecha ?? '').compareTo(_parseDate(b.fecha ?? '')));

    final subtitle =
        '${records.length} materia${records.length == 1 ? "" : "s"}';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryPurple, _secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _primaryYellow,
            width: 1.5,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.white24,
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.white,
              textColor: Colors.white,
            ),
          ),
          child: ExpansionTile(
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              'Nivel $nivel',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            trailing: const Icon(
              Icons.expand_more,
              color: Colors.white,
            ),
            children: records.map(_buildRecordRow).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFechaGroupCard(String fecha, List<SubjectRecord> records) {
    records.sort(
            (a, b) => (a.nivel ?? 0).compareTo(b.nivel ?? 0));

    final subtitle =
        '${records.length} materia${records.length == 1 ? "" : "s"}';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryPurple, _secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _primaryYellow,
            width: 1.5,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.white24,
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.white,
              textColor: Colors.white,
            ),
          ),
          child: ExpansionTile(
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              'Fecha: $fecha',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            trailing: const Icon(
              Icons.expand_more,
              color: Colors.white,
            ),
            children: records.map(_buildRecordRow).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordRow(SubjectRecord r) {
    final nota = r.nota;
    final asistencia = r.asistencia;
    final nivel = r.nivel;
    final aprobada = r.aprobada == true;
    final valida = r.valida == true;

    Color pillColor;
    String pillText;

    if (aprobada) {
      pillColor = Colors.greenAccent.shade400;
      pillText = 'Aprobada';
    } else if (!valida) {
      pillColor = Colors.redAccent;
      pillText = 'No válida';
    } else {
      pillColor = Colors.orangeAccent;
      pillText = 'Reprobada';
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asignatura + nota
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  r.asignatura ?? 'Sin nombre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (nota != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _primaryYellow,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    nota.toStringAsFixed(2),
                    style: const TextStyle(
                      color: _primaryYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (nivel != null)
                _buildInfoChip(
                  icon: Icons.layers,
                  label: 'Nivel $nivel',
                ),
              if (asistencia != null)
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: 'Asistencia ${asistencia.toStringAsFixed(1)}%',
                ),
              _buildStatusChip(pillText, pillColor),
              if (r.convalidada == true)
                _buildInfoChip(
                  icon: Icons.swap_horiz,
                  label: 'Convalidada',
                ),
              if (r.homologada == true)
                _buildInfoChip(
                  icon: Icons.verified,
                  label: 'Homologada',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// PRASEM y SECOM
  Widget _buildPracticasVinculacionSection() {
    final practicas = _data?.practicas ?? [];
    final vinculacion = _data?.vinculacion;

    double horasPrasem = 0;
    String? empresaPrasem;
    String? fechaPrasem;

    if (practicas.isNotEmpty) {
      horasPrasem = practicas.fold(
          0, (sum, p) => sum + (p.horas ?? 0).toDouble());
      empresaPrasem = practicas.first.empresa;
      fechaPrasem = practicas.first.fecha;
    }

    double horasSecom = 0;
    String? proyectoSecom;
    String? fechaSecom;

    final cumplimiento = vinculacion?.cumplimiento ?? [];
    if (cumplimiento.isNotEmpty) {
      horasSecom = cumplimiento.fold(
          0, (sum, c) => sum + (c.horas ?? 0).toDouble());
      proyectoSecom = cumplimiento.first.nombre;
      fechaSecom = cumplimiento.first.fecha;
    }

    if (horasPrasem == 0 && horasSecom == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prácticas y Vinculación',
          style: TextStyle(
            color: _primaryPurple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (horasPrasem > 0)
          _buildSummaryCard(
            title: 'Horas pasantías PRASEM',
            hours: horasPrasem,
            subtitle: empresaPrasem,
            date: fechaPrasem,
            icon: Icons.business_center,
          ),
        if (horasSecom > 0)
          _buildSummaryCard(
            title: 'Horas prácticas SECOM',
            hours: horasSecom,
            subtitle: proyectoSecom,
            date: fechaSecom,
            icon: Icons.volunteer_activism,
          ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double hours,
    String? subtitle,
    String? date,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryPurple, _secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _primaryYellow,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _primaryYellow),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  if (date != null && date.isNotEmpty)
                    Text(
                      'Fecha: $date',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${hours.toStringAsFixed(1)} h',
              style: const TextStyle(
                color: _primaryYellow,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
