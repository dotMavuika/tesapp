import 'package:flutter/material.dart';

import '../../controllers/schedule_controller.dart';
import '../../model/schedule_data.dart';
import 'components/loading_indicator.dart';
import 'components/error_message.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleController _controller = ScheduleController();

  bool _isLoading = true;
  String _errorMessage = '';

  List<ScheduleItem> _items = [];
  Map<String, List<ScheduleItem>> _byDay = {};

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    final cached = _controller.getScheduleData();

    if (cached != null && cached.horario.isNotEmpty) {
      _applySchedule(cached.horario);
      setState(() => _isLoading = false);
    } else {
      _loadSchedule();
    }
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _controller.refreshScheduleData();

    if (result['success']) {
      final data = _controller.getScheduleData();
      if (data != null && data.horario.isNotEmpty) {
        _applySchedule(data.horario);
      }
      setState(() => _isLoading = false);
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  void _applySchedule(List<ScheduleItem> list) {
    _items = list;
    _byDay.clear();

    for (final item in list) {
      _byDay.putIfAbsent(item.dia, () => []).add(item);
    }

    for (final day in _byDay.keys) {
      _byDay[day]!.sort(
            (a, b) => a.horaInicio.compareTo(b.horaInicio),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const LoadingIndicator(message: 'Cargando horario...'),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: ErrorMessage(
          message: _errorMessage,
          onRetry: _loadSchedule,
        ),
      );
    }

    if (_byDay.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Text('No hay horario disponible'),
        ),
      );
    }

    final days = _byDay.keys.toList();

    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: _buildAppBar(
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelColor: _primaryPurple,
            indicatorColor: _primaryPurple,
            tabs: days.map((d) => Tab(text: d)).toList(),
          ),
        ),
        body: TabBarView(
          children: days.map((day) {
            final classes = _byDay[day]!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (_, i) => _buildCard(classes[i]),
            );
          }).toList(),
        ),
      ),
    );
  }

  AppBar _buildAppBar({PreferredSizeWidget? bottom}) {
    return AppBar(
      title: const Text(
        'Horario de Clases',
        style: TextStyle(
          color: _primaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: _primaryPurple,
      elevation: 1,
      bottom: bottom,
    );
  }

  Widget _buildCard(ScheduleItem item) {
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
          border: Border.all(color: _primaryYellow, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.horaInicio} - ${item.horaFin}',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.materia,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(Icons.location_on, item.aula),
                _chip(Icons.person, item.profesor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
